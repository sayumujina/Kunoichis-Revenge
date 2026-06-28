local rep = game:GetService("ReplicatedStorage")
local Animations = rep.Assets.Animations
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
--
local _TYPES = require(rep.Shared.data_Types)
local TableUtil = require(rep.Packages.TableUtil)

local Utility = {}

--- Sort the turn queue by action value
--- @param queue -- The turn queue to sort
function Utility.SortTurnQueue(queue: { _TYPES.TurnEntry })
	table.sort(queue, function(a, b)
		if a.actionValue == b.actionValue then
			return a.turnId < b.turnId -- Tiebreaker: earlier turns stay first
		end
		return a.actionValue < b.actionValue
	end)
end

--- Normalise the turn queue after a turn is completed
--- This makes sure the action on top is always at 0 action value
--- @param queue -- The turn queue to normalise
--- @return The normalised turn queue
function Utility.NormaliseTurnQueue(queue: { _TYPES.TurnEntry })
	-- Deep copy the queue to avoid mutating the original
	if #queue == 0 then
		return
	end

	local normalisedQueue = TableUtil.Copy(queue, true)

	local topActionValue = normalisedQueue[1].actionValue
	for _, entry in pairs(normalisedQueue) do
		entry.actionValue = entry.actionValue - topActionValue
	end

	return normalisedQueue
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
	if not parent or not parent:IsA("Model") or parent:GetAttribute("Side") ~= "Allies" then
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

return Utility
