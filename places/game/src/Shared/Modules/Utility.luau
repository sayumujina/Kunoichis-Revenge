local rep = game:GetService("ReplicatedStorage")
local Animations = rep.Assets.Animations
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
--
local _TYPES = require(rep.Shared.data_Types)
local TableUtil = require(rep.Packages.TableUtil)
local Timer = require(rep.Packages.Timer)

local Utility = {}

--- Sort the turn queue by action value
---
--- This is intentionally a two-pass sort:
--- 1. Sort the entire queue by action value so lower values always resolve first.
--- 2. Scan the sorted queue for tied action-value groups and only reorder entries
---    inside each tied group by turnId.
---
--- This keeps the turnId tiebreaker scoped to entries that are actually tied,
--- instead of letting turnId influence the order of the whole queue.
--- @param queue -- The turn queue to sort
function Utility.SortTurnQueue(queue: { _TYPES.TurnEntry })
	local sortedQueue = TableUtil.Copy(queue, true)

	-- First, sort only by action value.
	table.sort(sortedQueue, function(a, b)
		return a.actionValue < b.actionValue
	end)

	local tieStartIndex = 1
	while tieStartIndex <= #sortedQueue do
		local tieEndIndex = tieStartIndex
		local actionValue = sortedQueue[tieStartIndex].actionValue

		-- Expand this range until we reach the end of the current tied group.
		while tieEndIndex < #sortedQueue and sortedQueue[tieEndIndex + 1].actionValue == actionValue do
			tieEndIndex += 1
		end

		-- Once we have the full range of tied entries, sort only that range by turnId.
		if tieEndIndex > tieStartIndex then
			-- Copy only the tied entries into a temporary list so we can apply
			-- the turnId tiebreaker without disturbing entries outside this group.
			local tiedEntries = table.create(tieEndIndex - tieStartIndex + 1)
			for index = tieStartIndex, tieEndIndex do
				tiedEntries[index - tieStartIndex + 1] = sortedQueue[index]
			end

			-- Within a tie group, earlier turns should stay on top.
			table.sort(tiedEntries, function(a, b)
				return a.turnId < b.turnId
			end)

			-- Write the locally re-sorted tie group back into the main queue.
			for index = tieStartIndex, tieEndIndex do
				sortedQueue[index] = tiedEntries[index - tieStartIndex + 1]
			end
		end

		-- Move to the next action-value group and repeat until the queue is exhausted.
		tieStartIndex = tieEndIndex + 1
	end

	return sortedQueue :: { _TYPES.TurnEntry }
end

--- Normalise the turn queue after a turn is completed
--- This makes sure the action on top is always at 0 action value
--- @param queue -- The turn queue to normalise
--- @return The normalised turn queue
function Utility.NormaliseTurnQueue(queue: { _TYPES.TurnEntry })
	-- Deep copy the queue to avoid mutating the original
	if #queue == 0 then
		return {}
	end

	local normalisedQueue = TableUtil.Copy(queue, true)

	local topActionValue = normalisedQueue[1].actionValue
	for _, entry in pairs(normalisedQueue) do
		entry.actionValue = entry.actionValue - topActionValue
	end

	return normalisedQueue :: { _TYPES.TurnEntry }
end

--- Get the combat controller module for a character
--- @param char -- The character to get the combat controller for
--- @return The combat controller module for the character, or nil if not found
function Utility.GetCharacterCombatController(char: _TYPES.Character): any
	local combatControllerModuleName = char.Name .. "_CombatController"
	if not combatControllerModuleName then
		warn("Character", char.Name, "does not have a CombatController module")
		return nil
	end

	local combatControllerModule =
		StarterPlayerScripts.Client.Controllers.Characters[char:GetAttribute("Side")][char.Name]:FindFirstChild(
			combatControllerModuleName
		)
	if not combatControllerModule then
		warn("CombatController module", combatControllerModuleName, "not found for character", char.Name)
		return nil
	end

	return combatControllerModule
end

--- Get the move list for a character
--- @param char -- The character to get the move list for
function Utility.GetCharacterMoveList(char: _TYPES.Character): any
	local dataFolder = rep.Shared.Data.Characters[char:GetAttribute("Side")]:FindFirstChild(char.Name)
	local charMoveList = dataFolder and require(dataFolder:FindFirstChild("data_" .. char.Name .. "_Moves")) :: any

	return charMoveList
end

--- Get the animation ID for a character's attack animation
--- @param char -- The character to get the animation ID for
--- @param animationName -- The name of the animation to get the ID for
function Utility.GetPlayingAttackAnimationId(char: _TYPES.Character, animationName: string)
	local animationIdToRetrieve = Animations.Characters[char.Name].Attacks:FindFirstChild(animationName).AnimationId
	return animationIdToRetrieve or nil
end

--- Set the transparency of a character's parts
--- @param char -- The character to set the transparency for
--- @param transparency -- The transparency value to set
function Utility.ToggleCharacterVisibility(char: _TYPES.Character, shouldShow: boolean)
	-- Set the transparency of all parts in the character
	for _, part in pairs(char:GetDescendants()) do
		if (part:IsA("BasePart") or part:IsA("Decal")) and not part:GetAttribute("originallyTransparent") then
			if shouldShow then
				(part :: any).Transparency = 0
			else
				(part :: any).Transparency = 1
			end
		end
	end
end

--- Performs a raycast from the part to the end vector to visualize the knockback path.
--- @within Utility
--- @param position -- The starting position of the raycast.
--- @param endVector -- The direction and magnitude of the ray.
--- @param includeCharacters -- Whether to include characters in the raycast.
--- @param origin -- The character performing the raycast, used to ignore themselves in the results.
--- @param VELOCITY_FACTOR -- The factor to scale the velocity by (**NOTE:** Most of the time, it should be **1**, so DON'T touch this unless you know what you're doing).
--- @return RaycastResult? -- The result of the raycast, or nil if no obstruction is found.
function Utility.Raycast(
	position: Vector3,
	endVector: Vector3,
	includeCharacters: boolean?,
	origin: _TYPES.Character?,
	VELOCITY_FACTOR: number?
): RaycastResult?
	local dir = endVector.Unit
	local velDistance = endVector.Magnitude / (VELOCITY_FACTOR or 1)

	-- Prepare the raycast to check for collisions
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local filter = {}
	if includeCharacters then
		local chars = workspace:WaitForChild("Characters"):GetChildren()
		local charIndex = chars and origin and table.find(chars, origin)
		if charIndex then
			table.remove(chars, charIndex)
		end
		table.insert(filter, chars)
	end

	raycastParams.FilterDescendantsInstances = filter

	raycastParams.IgnoreWater = true

	-- Raycast to check for obstructions
	local result = workspace:Raycast(position, dir * velDistance, raycastParams)

	return result
end

--- Sets the network ownership of a part to a specific player.
--- @within Utility
--- @param part -- The part to set network ownership for.
--- @param networkOwner -- The player to set as the network owner of the part.
function Utility.SetNetworkOwner(part: BasePart, networkOwner: _TYPES.RobloxPlayerType?)
	-- Get the owner of the base part
	local parent = part.Parent

	-- If the parent does not have an attribute state, it means it's not a character, so yell the error if that's the case
	if not parent or not parent:IsA("Model") or parent:GetAttribute("Side") ~= "Playable" then
		error("Attempted to set network ownership of a non-character part.")
		return
	end

	-- If the state is "Dying", also return early
	if parent:GetAttribute("State") == "Dying" then
		warn("Attempted to set network ownership of a part whose character is dying.")
		return
	end

	-- Set the network ownership of the part to the specified player
	part:SetNetworkOwner(networkOwner)
end

--- Find a character in the workspace based on the provided index
--- @within Utility
--- @param indexToFind -- The index of the character to find
--- @param folder -- The folder to search for the character in (e.g., workspace.Char
function Utility.FindCharacterWithIndex(indexToFind: number, folder: Folder): _TYPES.Character?
	-- Loop through the children of the folder to find the character with the matching index
	for _, child in pairs(folder:GetChildren()) do
		local charIndex = child:GetAttribute("Index")
		if charIndex and charIndex == indexToFind then
			return child :: _TYPES.Character
		end
	end

	return nil
end

--- Get the default move for a character
--- @within Utility
--- @param char -- The character to get the default move for
function Utility.GetCharacterDefaultMove(char: _TYPES.Character)
	local moveList = Utility.GetCharacterMoveList(char)
	for moveName, moveData in pairs(moveList) do
		-- If the move is not default, skip it
		if not moveData.isDefault then
			continue
		end

		return moveName
	end

	return nil
end

--- Sets up a timeout that will call the provided callback function after the specified duration.
--- @within Utility
--- @param timeout -- The duration in seconds before the callback is called.
--- @param callback -- The function to call when the timeout is reached.
function Utility.SetupTimeout(timeout: number, callback: () -> ()?)
	-- Create a timer
	local timer = Timer.new(timeout or 1)

	-- Run the callback and destroy the timer once the timer ticks
	timer.Tick:Once(function()
		if callback then
			callback()
		end
		timer:Stop()
	end)

	return timer
end

-- Constants for character spawn positioning
local SPAWN_X_OFFSET_BETWEEN_CHARACTERS = 8
local SPAWN_Z_ALTERNATE_OFFSET = 1
local ENEMY_SPAWN_Z_OFFSET = 50
local BASE_ENEMY_SPAWN_POSITION = Vector3.new(0, 0, 40)
local ALLY_SPAWN_Z_OFFSET = 0
local BASE_ALLY_SPAWN_POSITION = Vector3.new(0, 0, 0)

--- Calculates the spawn position for a character based on its side, index, and total number of characters.
--- @within Utility
--- @param side -- The side the character belongs to (Playable or NPC).
--- @param characterCount -- The total number of characters on that side.
--- @param count -- The index of the character (1-based).
--- @param charHeight -- The height of the character model.
function Utility.CalculateCharacterSpawnPosition(
	side: _TYPES.Sides,
	characterCount: number,
	count: number,
	charHeight: number
): CFrame
	-- Calculate starting X position based on number of characters
	local startX
	if side == "Playable" then
		startX = BASE_ALLY_SPAWN_POSITION.X + ((characterCount - 1) * SPAWN_X_OFFSET_BETWEEN_CHARACTERS) / 2
	else
		startX = BASE_ENEMY_SPAWN_POSITION.X + ((characterCount - 1) * SPAWN_X_OFFSET_BETWEEN_CHARACTERS) / 2
	end

	-- Calculate X position for this character
	local spawnX = startX - (count * SPAWN_X_OFFSET_BETWEEN_CHARACTERS)

	-- Calculate Z offset with alternation
	local baseZOffset = side == "Playable" and ALLY_SPAWN_Z_OFFSET or ENEMY_SPAWN_Z_OFFSET
	local spawnZ
	if side == "Playable" then
		spawnZ = baseZOffset - ((count % 2 == 0) and SPAWN_Z_ALTERNATE_OFFSET or -SPAWN_Z_ALTERNATE_OFFSET)
	else
		spawnZ = baseZOffset + ((count % 2 == 0) and SPAWN_Z_ALTERNATE_OFFSET or -SPAWN_Z_ALTERNATE_OFFSET)
	end

	-- Create the final CFrame with rotation for allies
	local position
	if side == "Playable" then
		position = CFrame.new(spawnX, charHeight / 2, spawnZ) * CFrame.Angles(0, math.rad(180), 0)
	else
		position = CFrame.new(spawnX, charHeight / 2, spawnZ)
	end

	return position
end

--- Repositions all active characters of a side based on current alive count
--- @within SpawnService
--- @param side -- The side to reposition (Playable or NPC)
function Utility.RepositionCharactersOfSide(side: _TYPES.Sides)
	local sideFolder = workspace.Characters:FindFirstChild(side)
	if not sideFolder then
		warn("Side folder not found for", side)
		return
	end

	-- Get all alive characters and sort by index
	local characters = {}
	for _, char in pairs(sideFolder:GetChildren()) do
		if char:IsA("Model") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
			table.insert(characters, char)
		end
	end

	table.sort(characters, function(a, b)
		return (a:GetAttribute("Index") or 0) < (b:GetAttribute("Index") or 0)
	end)

	local characterCount = #characters
	if characterCount == 0 then
		return
	end

	-- Reposition each character using the same helper function
	for count, char in pairs(characters) do
		local newPosition =
			Utility.CalculateCharacterSpawnPosition(side, characterCount, count, char:GetExtentsSize().Y)
		char:PivotTo(newPosition)
	end
end

return Utility
