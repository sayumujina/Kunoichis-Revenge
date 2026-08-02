local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Setsuna.data_Setsuna_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
local EventService = require(Services.EventService)
-- Packages
local Trove = require(rep.Packages.Trove)
local Zap = require(Services.Parent.zap)
-- Utility
local CanCastUltimate = require(rep.Shared.Modules.Attack.Utility.CanCastUltimate)
-- Data
local MoveInfo = require(rep.Data.Characters.Playable.Setsuna.data_Setsuna_Moves)

-- Attack handlers
local Handlers = {
	WeavingBlade = require(script.Parent.Handlers.Setsuna_WeavingBlade),
	TwinBlades = require(script.Parent.Handlers.Setsuna_TwinBlades),
	BladeDance = require(script.Parent.Handlers.Setsuna_BladeDance),
} :: { [string]: (_TYPES.Character, _TYPES_CHAR.ServerCharData) -> boolean }

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "WeavingBlade",
	Skill = "TwinBlades",
	Ultimate = "BladeDance",
}

local charName = "Setsuna"
local Chars = {} :: { [_TYPES.Character]: _TYPES_CHAR.ServerCharData }

local Setsuna_CombatService = {}

function Setsuna_CombatService.OnStart() end

function Setsuna_CombatService.Init(char: _TYPES.Character)
	-- Initialize the character's combat data if it doesn't exist
	if not Chars[char] then
		Chars[char] = {
			Info = {
				selectedMove = "WeavingBlade",
				queuedUltimateId = nil,
			},
			Trove = Trove.new(),
		} :: _TYPES_CHAR.ServerCharData
	end

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
			Chars[char].Info.selectedMove = "WeavingBlade"
			Chars[char].Info.queuedUltimateId = nil
		end
	end)
end

--- Handle input for Setsuna's combat service
--- @param char -- The character performing the action
--- @param inputData -- The input data containing the action and target information
function Setsuna_CombatService.HandleInput(char: _TYPES.Character, inputData: _TYPES.InputData)
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
		if charData.Info.selectedMove == "BladeDance" then
			-- Reset the queued ultimate ID after executing the ultimate
			charData.Info.queuedUltimateId = nil
			-- Reset the selected move to the default after executing the ultimate
			charData.Info.selectedMove = "WeavingBlade"

			return Handlers.BladeDance(char, charData)
		end

		-- Check if Tsuyoka's energy is full
		if not CanCastUltimate(char) then
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
		charData.Info.selectedMove = "BladeDance"

		-- Play the ultimate cast sound
		Zap.RequestPlaySound.Fire(player :: _TYPES.RobloxPlayerType, "Sound_UltimateCasted")

		warn("Selected ultimate for Setsuna:", char.Name, "with queued ID:", charData.Info.queuedUltimateId)

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
		if combatData.isProcessingAttack then
			return false
		end

		-- Handle the input based on the action
		if charData.Info.selectedMove == "WeavingBlade" then
			return Handlers.WeavingBlade(char, charData)
		elseif charData.Info.selectedMove == "TwinBlades" then
			return Handlers.TwinBlades(char, charData)
		elseif charData.Info.selectedMove == "BladeDance" then
			-- Reset the queued ultimate ID after executing the ultimate
			charData.Info.queuedUltimateId = nil

			-- Reset the selected move to the default after executing the ultimate
			charData.Info.selectedMove = "WeavingBlade"
			return Handlers.BladeDance(char, charData)
		end
	-- Handle move selection actions
	elseif ActionToMoveMap[action] then
		if combatData.isProcessingAttack then
			return false
		end

		-- If ultimate is already selected, disallow switching to other moves
		if charData.Info.selectedMove == "BladeDance" then
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
		if charData.Info.selectedMove == "WeavingBlade" then
			Handlers.WeavingBlade(char, charData)
		elseif charData.Info.selectedMove == "TwinBlades" then
			Handlers.TwinBlades(char, charData)
		end
	end

	return true
end

--- Get the attack handlers for Setsuna's combat service
function Setsuna_CombatService.GetAttackHandlers()
	return Handlers
end

return Setsuna_CombatService
