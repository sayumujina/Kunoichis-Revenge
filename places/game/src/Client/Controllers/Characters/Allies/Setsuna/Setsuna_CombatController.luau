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

-- Action to move mapping at the top of the file (around line 23, after CharData)
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
		CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", -1)
		return
	elseif action == "NextTarget" then
		CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", 1)
		return
	end

	-- Handle move selection actions
	local mappedMove = ActionToMoveMap[action]
	if mappedMove and CharData.selectedMove ~= mappedMove then
		CharData.selectedMove = mappedMove

		-- Set the selected side based on the move's selected side
		CombatController.SetSelectedSide(Handlers.Moves[CharData.selectedMove].selectedSide)
		CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", 0)
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
