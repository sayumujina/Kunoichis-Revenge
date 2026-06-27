local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)

-- Attack handlers
local Handlers = {
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura),
} :: { [string]: (_TYPES.Character, number) -> () }

local charName = "Rin"
local Chars = {} :: {}

-- Character data
local CharData = {
	selectedMove = "HiddenAssistance", -- Player needs to confirm the move twice before executing
}

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "HiddenAssistance",
	Skill = "CleansingAura",
}
local Rin_CombatService = {}

function Rin_CombatService.OnStart() end

--- Handle input for Rin's combat service
--- @param char -- The character performing the action
--- @param inputData -- The input data containing the action and target information
function Rin_CombatService.HandleInput(char: _TYPES.Character, inputData: _TYPES.InputData)
	-- Check if the input is for this character
	local currentTurnChar = TurnService.GetCurrentTurn()
	if not currentTurnChar or char :: any ~= currentTurnChar.char then
		return
	end

	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local action = inputData.action

	-- Handle target selection actions
	if action == "PreviousTarget" then
		CombatService.SwitchToPreviousTarget(player)
		CombatService.UpdateMovePreview(player, char, CharData.selectedMove)
		return
	elseif action == "NextTarget" then
		CombatService.SwitchToNextTarget(player)
		CombatService.UpdateMovePreview(player, char, CharData.selectedMove)
		return
	-- Handle move selection actions
	elseif ActionToMoveMap[action] then
		-- Handle move selection actions
		local mappedMove = ActionToMoveMap[action]

		-- If the move isn't the same as the currently selected move, it means the player is selecting a new move
		-- Only confirm the move if the player has selected the same move twice in a row
		if mappedMove and CharData.selectedMove ~= mappedMove then
			CharData.selectedMove = mappedMove
			-- Update the selection type reference for the new move
			CombatService.UpdateMovePreview(player, char, mappedMove)

			return
		end

		local primaryTargetIndex = CombatService.GetCombatData(player).primarySelectedTargetIndex
		-- Handle the input based on the action
		if CharData.selectedMove == "HiddenAssistance" then
			print(charName .. " performs a basic attack!")
			Handlers.HiddenAssistance(char, primaryTargetIndex)
		elseif CharData.selectedMove == "CleansingAura" then
			print(charName .. " uses their skill!")
			Handlers.CleansingAura(char, primaryTargetIndex)
		end
	end
end

return Rin_CombatService
