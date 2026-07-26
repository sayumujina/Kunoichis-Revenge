local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Rin.data_Rin_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
local EventService = require(Services.EventService)
-- Utility
local CanCastUltimate = require(rep.Shared.Modules.Attack.Utility.CanCastUltimate)
--  Packages
local Trove = require(rep.Packages.Trove)
local Zap = require(Services.Parent.zap)

-- Data
local MoveInfo = require(rep.Data.Characters.Playable.Rin.data_Rin_Moves)

-- Attack handlers
local Handlers = {
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura),
	VanguardsCall = require(script.Parent.Handlers.Rin_VanguardsCall),
} :: { [string]: (_TYPES.Character, _TYPES_CHAR.ServerCharData) -> boolean }

local charName = "Rin"

-- Character data
local Chars = {} :: { [_TYPES.Character]: _TYPES_CHAR.ServerCharData }

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "HiddenAssistance",
	Skill = "CleansingAura",
	Ultimate = "VanguardsCall",
}
local Rin_CombatService = {}

function Rin_CombatService.OnStart() end

function Rin_CombatService.Init(char: _TYPES.Character)
	-- Initialize the character's combat data if it doesn't exist
	if not Chars[char] then
		Chars[char] = {
			Info = {
				selectedMove = "HiddenAssistance",
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
			Chars[char].Info.selectedMove = "HiddenAssistance"
			Chars[char].Info.queuedUltimateId = nil
		end
	end)
end

--- Handle input for Rin's combat service
--- @param char -- The character performing the action
--- @param inputData -- The input data containing the action and target information
function Rin_CombatService.HandleInput(char: _TYPES.Character, inputData: _TYPES.InputData)
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
		if charData.Info.selectedMove == "VanguardsCall" then
			-- Reset the queued ultimate ID after executing the ultimate
			charData.Info.queuedUltimateId = nil
			-- Reset the selected move to the default after executing the ultimate
			charData.Info.selectedMove = "HiddenAssistance"

			return Handlers.VanguardsCall(char, charData)
		end

		-- Check if Rin can cast her ultimate before proceeding
		if not CanCastUltimate(char) then
			warn("Rin's energy is not full. Cannot execute ultimate.")
			return false
		end

		-- Store the queued ultimate action ID for later execution
		if combatData.isProcessingAttack then
			if charData.Info.queuedUltimateId then
				return true
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
		charData.Info.selectedMove = "VanguardsCall"

		-- Play the ultimate cast sound
		Zap.RequestPlaySound.Fire(player :: _TYPES.RobloxPlayerType, "Sound_UltimateCasted")

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
		if charData.Info.selectedMove == "HiddenAssistance" then
			return Handlers.HiddenAssistance(char, charData)
		elseif charData.Info.selectedMove == "CleansingAura" then
			return Handlers.CleansingAura(char, charData)
		elseif charData.Info.selectedMove == "VanguardsCall" then
			-- Reset the queued ultimate ID after executing the ultimate
			charData.Info.queuedUltimateId = nil
			-- Reset the selected move to the default after executing the ultimate
			charData.Info.selectedMove = "HiddenAssistance"

			return Handlers.VanguardsCall(char, charData)
		end
	-- Handle move selection actions
	elseif ActionToMoveMap[action] then
		-- If ultimate is already selected, disallow switching to other moves
		if charData.Info.selectedMove == "VanguardsCall" then
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
		if charData.Info.selectedMove == "HiddenAssistance" then
			Handlers.HiddenAssistance(char, charData)
		elseif charData.Info.selectedMove == "CleansingAura" then
			Handlers.CleansingAura(char, charData)
		end
	end

	return true
end

--- Get the attack handlers for Rin's combat service
function Rin_CombatService.GetAttackHandlers()
	return Handlers
end

return Rin_CombatService
