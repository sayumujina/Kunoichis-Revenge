local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local CombatController = require(StarterPlayerScripts.Client.Controllers.CombatController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Utiltiy
local Utility = require(rep.Shared.Modules.Utility)

-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Moves),
}
-- Attack handlers
local AttackHandlers = {
	WeavingBlade = require(script.Parent.Handlers.Setsuna_WeavingBlade_Handler),
	TwinBlades = require(script.Parent.Handlers.Setsuna_TwinBlades_Handler),
} :: { [string]: (AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> () }

-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "WeavingBlade", -- Player needs to confirm the move twice before executing
}

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "WeavingBlade",
	Skill = "TwinBlades",
}

local Setsuna_CombatController = {}

--- Gets the attack handlers for Setsuna
function Setsuna_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Handles attack input from the player and sends it to the server
function Setsuna_CombatController.HandleInput(inputData)
	local action = inputData.action
	local targetSelectionType = Handlers.Moves[CharData.selectedMove].targetSelectionType

	-- Handle target selection actions
	if action == "PreviousTarget" then
		CombatController.SwitchToPreviousTarget(targetSelectionType)
		return
	elseif action == "NextTarget" then
		CombatController.SwitchToNextTarget(targetSelectionType)
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
			primaryTargetIndex = CombatController.GetPrimarySelectedTargetIndex(),
		},
	})
end

return Setsuna_CombatController
