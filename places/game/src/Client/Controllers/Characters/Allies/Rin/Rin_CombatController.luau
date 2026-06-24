local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
-- Controllers
local Controllers = StarterPlayerScripts.Client.Controllers
local CameraController = require(Controllers.CameraController)
local CombatController = require(Controllers.CombatController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Rin.data_Rin_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Rin.data_Rin_Moves),
}
-- Attack handlers
local AttackHandlers = {
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance_Handler),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura_Handler),
} :: { [string]: (AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> () }

-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "HiddenAssistance", -- Player needs to confirm the move twice before executing
}

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "HiddenAssistance",
	Skill = "CleansingAura",
}

local Rin_CombatController = {}

--- Gets the attack handlers for Rin
function Rin_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Handles attack input from the player and sends it to the server
function Rin_CombatController.HandleInput(inputData)
	local action = inputData.action
	local combatData = CombatController.GetCombatData()
	local targetSelectionType = Handlers.Moves[CharData.selectedMove].targetSelectionType

	-- Handle target selection actions
	if action == "PreviousTarget" then
		CombatController.SwitchToPreviousTarget(targetSelectionType)
		CameraController.LookAtEnemies(combatData.currentCharacter :: any, combatData.primarySelectedTargetIndex)
		return
	elseif action == "NextTarget" then
		CombatController.SwitchToNextTarget(targetSelectionType)
		CameraController.LookAtEnemies(combatData.currentCharacter :: any, combatData.primarySelectedTargetIndex)
		return
	end

	-- Handle move selection actions
	local mappedMove = ActionToMoveMap[action]
	if mappedMove and CharData.selectedMove ~= mappedMove then
		CharData.selectedMove = mappedMove

		-- Update the selection type reference for the new move
		targetSelectionType = Handlers.Moves[CharData.selectedMove].targetSelectionType

		-- Set the selected side based on the move's selected side
		CombatController.SetSelectedSide(Handlers.Moves[CharData.selectedMove].selectedSide)

		-- Update the move preview with the target selection type and mana change value
		CombatController.UpdateMovePreview(
			targetSelectionType,
			Handlers.Moves[CharData.selectedMove].data.manaChange :: number
		)
		return
	end

	-- Execute the attack
	Zap.RequestAttack.Fire({
		char = player.ActiveCharacter.Value,
		data = {
			move = CharData.selectedMove,
			primaryTargetIndex = combatData.primarySelectedTargetIndex,
		},
	})
end

return Rin_CombatController
