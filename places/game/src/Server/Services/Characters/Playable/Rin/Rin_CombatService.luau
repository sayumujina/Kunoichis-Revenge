local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
-- Utility
local IsAtFullEnergy = require(rep.Shared.Modules.Attack.Utility.IsAtFullEnergy)

-- Attack handlers
local Handlers = {
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura),
	VanguardsCall = require(script.Parent.Handlers.Rin_VanguardsCall),
} :: { [string]: (_TYPES.Character, number) -> () }

local charName = "Rin"

-- Character data
local CharData = {
	selectedMove = "HiddenAssistance", -- Player needs to confirm the move twice before executing
}

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "HiddenAssistance",
	Skill = "CleansingAura",
	Ultimate = "VanguardsCall",
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
	local combatData = CombatService.GetCombatData(player)

	-- Handle target selection actions
	if action == "PreviousTarget" then
		CombatService.SwitchToPreviousTarget(player)
		CombatService.UpdateMovePreview(player, char, CharData.selectedMove)
		return
	elseif action == "NextTarget" then
		CombatService.SwitchToNextTarget(player)
		CombatService.UpdateMovePreview(player, char, CharData.selectedMove)
		return
	-- Handle ultimates differently
	elseif action:find("Ultimate") then
		-- If the selected move is the ultimate again, execute it
		if CharData.selectedMove == "VanguardsCall" then
			print(charName .. " executes their ultimate!")
			Handlers.VanguardsCall(char, combatData.primarySelectedTargetIndex)

			-- Reset the selected move to the default after executing the ultimate
			CharData.selectedMove = "HiddenAssistance"
			return
		end

		-- Check if Rin's energy is full
		if not IsAtFullEnergy(char) then
			warn("Rin's energy is not full. Cannot execute ultimate.")
			return
		end

		-- Set the selected move to the ultimate
		CharData.selectedMove = "VanguardsCall"
	-- Handle move selection actions
	elseif ActionToMoveMap[action] then
		-- If ultimate is already selected, disallow switching to other moves
		if CharData.selectedMove == "VanguardsCall" then
			warn("Ultimate is already selected. Cannot switch to " .. action)
			return
		end

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

		-- Handle the input based on the action
		if CharData.selectedMove == "HiddenAssistance" then
			print(charName .. " performs a basic attack!")
			Handlers.HiddenAssistance(char, combatData.primarySelectedTargetIndex)
		elseif CharData.selectedMove == "CleansingAura" then
			print(charName .. " uses their skill!")
			Handlers.CleansingAura(char, combatData.primarySelectedTargetIndex)
		end
	end
end

return Rin_CombatService
