local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local EventService = require(Services.EventService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
-- Packages
local Trove = require(rep.Packages.Trove)
local Zap = require(Services.Parent.zap)
-- Utility
local CanCastUltimate = require(rep.Shared.Modules.Attack.Utility.CanCastUltimate)
-- Data
local MoveInfo = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Moves)

-- Attack handlers
local Handlers = {
	LightningArrow = require(script.Parent.Handlers.Hayumi_LightningArrow),
	LightningRain = require(script.Parent.Handlers.Hayumi_LightningRain),
	ArcherysVision = require(script.Parent.Handlers.Hayumi_ArcherysVision),
	WeakenFromAfar = require(script.Parent.Handlers.Hayumi_WeakenFromAfar),
} :: { [string]: (_TYPES.Character, _TYPES_CHAR.ServerCharData) -> boolean }

local charName = "Hayumi"
local Chars = {} :: { [_TYPES.Character]: _TYPES_CHAR.ServerCharData }

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "LightningArrow",
	Skill = "LightningRain",
	Ultimate = "WeakenFromAfar",
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
				queuedUltimateId = nil,
			},
			Trove = Trove.new(),
		} :: _TYPES_CHAR.ServerCharData
	end

	-- Listen to successful move events
	Chars[char].Trove:Add(EventService.Events.SuccessfulMove:Connect(function(successfulMoveData)
		local origin = successfulMoveData.origin
		local attackData = successfulMoveData.data.attackData

		-- If the origin is Hayumi, do not cast Archery's Vision
		if origin :: any == char then
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
			return
		end

		-- If an ally attacked successfully, cast Archery's Vision if the player has uses left
		if origin:GetAttribute("Side") ~= "Playable" then
			return
		end

		local target = successfulMoveData.data.attackData.targets[1]
		if not target then
			warn("No target found for the successful move.")
			return
		end

		local charData = Chars[char]
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

	-- Clean up when the character is downed
	EventService.Events.Death:Connect(function(deathData)
		if deathData.char :: any == char then
			if Chars[char] then
				Chars[char].Trove:Destroy()
				Chars[char] = nil
			end
		end
	end)

	-- Listens to the turn started event to reset the selected move to the default
	EventService.Events.TurnStarted:Connect(function(turnData)
		if turnData.data.char :: any == char then
			Chars[char].Info.selectedMove = "LightningArrow"
			Chars[char].Info.queuedUltimateId = nil
		end
	end)
end

--- Handle input for Hayumi's combat service
--- @param char -- The character performing the action
--- @param inputData -- The input data containing the action and target information
function Hayumi_CombatService.HandleInput(char: _TYPES.Character, inputData: _TYPES.InputData)
	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local action = inputData.action
	local combatData = CombatService.GetCombatData(player)

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
	-- Handle ultimates differently
	elseif action:find("Ultimate") then
		-- If the selected move is the ultimate again, execute it
		if charData.Info.selectedMove == "WeakenFromAfar" then
			-- Reset the queued ultimate ID after executing the ultimate
			charData.Info.queuedUltimateId = nil
			-- Reset the selected move to the default after executing the ultimate
			charData.Info.selectedMove = "LightningArrow"

			return Handlers.WeakenFromAfar(char, charData)
		end

		-- Check if Hayumi's energy is full
		if not CanCastUltimate(char) then
			warn("Hayumi's energy is not full. Cannot execute ultimate.")
			return false
		end

		-- Store the queued ultimate action ID for later execution
		if combatData.isProcessingAttack then
			if charData.Info.queuedUltimateId then
				return false
			end

			charData.Info.queuedUltimateId = TurnService.AddExtraAction(char, "Ultimate")
			return true
		else
			if not charData.Info.queuedUltimateId then
				charData.Info.queuedUltimateId = TurnService.AddExtraAction(char, "Ultimate")
				TurnService.ExecuteNextExtraAction(player)
				return true
			end
		end

		-- Set the selected move to the ultimate
		charData.Info.selectedMove = "WeakenFromAfar"

		-- Play the ultimate cast sound
		Zap.RequestPlaySound.Fire(player :: _TYPES.RobloxPlayerType, "Sound_UltimateCasted")

		warn("Selected ultimate for Hayumi:", char.Name, "with queued ID:", charData.Info.queuedUltimateId)

		-- Update the selection type reference for the new move
		CombatService.UpdateMovePreview(player, char, charData.Info.selectedMove)

		-- Notify the client that the ultimate has been casted
		local cinematicInfo = MoveInfo[charData.Info.selectedMove].cinematicInfo
		local flashDuration = cinematicInfo and cinematicInfo.flashDuration or 1
		Zap.CastedUltimate.Fire(PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType, {
			char = char,
			data = {
				fullMoveName = MoveInfo[charData.Info.selectedMove].info.name,
				flashDuration = flashDuration,
			},
		})
	-- Handle the confirm move action
	elseif action == "ConfirmMove" then
		-- Handle the input based on the action
		if charData.Info.selectedMove == "LightningArrow" then
			return Handlers.LightningArrow(char, charData)
		elseif charData.Info.selectedMove == "LightningRain" then
			return Handlers.LightningRain(char, charData)
		elseif charData.Info.selectedMove == "WeakenFromAfar" then
			-- Reset the queued ultimate ID after executing the ultimate
			charData.Info.queuedUltimateId = nil

			-- Reset the selected move to the default after executing the ultimate
			charData.Info.selectedMove = "LightningArrow"
			return Handlers.WeakenFromAfar(char, charData)
		end
	-- Handle move selection actions
	elseif ActionToMoveMap[action] then
		-- If ultimate is already selected, disallow switching to other moves
		if charData.Info.selectedMove == "WeakenFromAfar" then
			warn("Ultimate is already selected. Cannot switch to " .. action)
			return false
		end

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
			Handlers.LightningArrow(char, charData)
		elseif charData.Info.selectedMove == "LightningRain" then
			Handlers.LightningRain(char, charData)
		end
	end

	return true
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
