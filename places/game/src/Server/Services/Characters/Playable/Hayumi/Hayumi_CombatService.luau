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
	LightningArrow = require(script.Parent.Handlers.Hayumi_LightningArrow),
	LightningRain = require(script.Parent.Handlers.Hayumi_LightningRain),
} :: { [string]: (_TYPES.Character, number) -> () }

local charName = "Hayumi"
local Chars = {} :: {}

-- Character data
local CharData = {
	selectedMove = "LightningArrow", -- Player needs to confirm the move twice before executing
}

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "LightningArrow",
	Skill = "LightningRain",
}

local Hayumi_CombatService = {}

function Hayumi_CombatService.OnStart() end

--- Handle input for Hayumi's combat service
--- @param char -- The character performing the action
--- @param inputData -- The input data containing the action and target information
function Hayumi_CombatService.HandleInput(char: _TYPES.Character, inputData: _TYPES.InputData)
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
		if CharData.selectedMove == "LightningArrow" then
			print(charName .. " performs a basic attack!")
			Handlers.LightningArrow(char, primaryTargetIndex)
		elseif CharData.selectedMove == "LightningRain" then
			print(charName .. " uses their skill!")
			Handlers.LightningRain(char, primaryTargetIndex)
		end
	end
end

return Hayumi_CombatService
