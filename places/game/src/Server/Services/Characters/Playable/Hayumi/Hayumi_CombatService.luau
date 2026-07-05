local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local _TYPES_CHAR = require(rep.Shared.Data.Characters.Playable.Hayumi.data_Hayumi_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local EventService = require(Services.EventService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
-- Packages
local Trove = require(rep.Packages.Trove)

-- Data
local MoveInfo = require(rep.Shared.Data.Characters.Playable.Hayumi.data_Hayumi_Moves)

-- Attack handlers
local Handlers = {
	LightningArrow = require(script.Parent.Handlers.Hayumi_LightningArrow),
	LightningRain = require(script.Parent.Handlers.Hayumi_LightningRain),
	ArcherysVision = require(script.Parent.Handlers.Hayumi_ArcherysVision),
} :: { [string]: (_TYPES.Character, _TYPES_CHAR.ServerCharData) -> boolean }

local charName = "Hayumi"
local Chars = {} :: { [_TYPES.Character]: _TYPES_CHAR.ServerCharData }

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "LightningArrow",
	Skill = "LightningRain",
}

local Hayumi_CombatService = {}

function Hayumi_CombatService.OnStart() end

--- Initialize the combat service for Hayumi
--- @param char -- The character to initialize the combat service for
function Hayumi_CombatService.Init(char: _TYPES.Character)
	-- Initialize the character's combat data if it doesn't exist
	if not Chars[char] then
		Chars[char] = {
			Info = {
				selectedMove = "LightningArrow",
				archerysVisionTarget = nil,
				archerysVisionUseCount = 1,
			},
			Trove = Trove.new(),
		} :: _TYPES_CHAR.ServerCharData
	end

	-- Listen to successful move events
	Chars[char].Trove:Add(EventService.Events.SuccessfulMove:Connect(function(successfulMoveData)
		warn("Successful move detected for Hayumi. Checking if Archery's Vision should be cast.")
		local origin = successfulMoveData.origin
		local attackData = successfulMoveData.data.attackData

		-- If the origin is Hayumi, do not cast Archery's Vision
		if origin :: any == char then
			warn("Origin is Hayumi. Not casting Archery's Vision.")
			return
		end

		-- If the attack category is not "Damage", do not cast Archery's Vision
		local foundDamageAttack = false
		for _, attack in pairs(attackData.attacks) do
			if attack.attackCategory == "Damage" then
				foundDamageAttack = true
				break
			end
		end

		if not foundDamageAttack then
			warn("No 'Damage' attack found. Not casting Archery's Vision.")
			return
		end

		-- If an ally attacked successfully, cast Archery's Vision if the player has uses left
		if origin:GetAttribute("Side") ~= "Playable" then
			warn("Archery's Vision can only be cast by playable characters.")
			return
		end

		local target = successfulMoveData.data.attackData.targets[1]
		if not target then
			warn("No target found for the successful move.")
			return
		end

		local charData = Chars[char]
		warn(
			"Casting Archery's Vision for " .. char.Name .. ". Remaining uses: " .. charData.Info.archerysVisionUseCount
		)
		if charData and charData.Info.archerysVisionUseCount > 0 then
			charData.Info.archerysVisionTarget = target
			TurnService.AddExtraAction(char, "ArcherysVision", true)
		end
	end))

	-- Clean up when the character is destroyed
	char.Destroying:Connect(function()
		if Chars[char] then
			Chars[char].Trove:Destroy()
			Chars[char] = nil
		end
	end)

	-- Listens to the turn started event to reset the selected move to the default
	EventService.Events.TurnStarted:Connect(function(turnData)
		if turnData.data.char :: any == char then
			Chars[char].Info.selectedMove = "LightningArrow"
			-- Chars[char].Info.queuedUltimateId = nil
		end
	end)
end

--- Handle input for Hayumi's combat service
--- @param char -- The character performing the action
--- @param inputData -- The input data containing the action and target information
function Hayumi_CombatService.HandleInput(char: _TYPES.Character, inputData: _TYPES.InputData)
	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local action = inputData.action

	local charData = Chars[char]
	-- Handle target selection actions
	if action == "PreviousTarget" then
		CombatService.SwitchToPreviousTarget(player, MoveInfo[charData.Info.selectedMove].selectedSide)
		CombatService.UpdateMovePreview(player, char, charData.Info.selectedMove)
		return true
	elseif action == "NextTarget" then
		CombatService.SwitchToNextTarget(player, MoveInfo[charData.Info.selectedMove].selectedSide)
		CombatService.UpdateMovePreview(player, char, charData.Info.selectedMove)
		return true
	-- Handle move selection actions
	elseif ActionToMoveMap[action] then
		-- Handle move selection actions
		local mappedMove = ActionToMoveMap[action]

		-- If the move isn't the same as the currently selected move, it means the player is selecting a new move
		-- Only confirm the move if the player has selected the same move twice in a row
		if mappedMove and charData.Info.selectedMove ~= mappedMove then
			charData.Info.selectedMove = mappedMove
			-- Update the selection type reference for the new move
			CombatService.UpdateMovePreview(player, char, mappedMove)
			return true
		end

		-- Handle the input based on the action
		if charData.Info.selectedMove == "LightningArrow" then
			return Handlers.LightningArrow(char, charData)
		elseif charData.Info.selectedMove == "LightningRain" then
			return Handlers.LightningRain(char, charData)
		end
	end

	return false
end

--- Get the attack handlers for Hayumi's combat service
function Hayumi_CombatService.GetAttackHandlers()
	return Handlers
end

--- Get the character data for Hayumi's combat service
--- @param char -- The character to get the data for
function Hayumi_CombatService.GetCharData(char: _TYPES.Character)
	return Chars[char]
end

return Hayumi_CombatService
