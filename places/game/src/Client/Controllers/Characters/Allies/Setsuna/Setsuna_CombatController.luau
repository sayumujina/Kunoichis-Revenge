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

local Setsuna_CombatController = {}

--- Gets the attack handlers for Setsuna
function Setsuna_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Handles attack input from the player and sends it to the server
--- @param inputData - The input data containing the action and any relevant information
function Setsuna_CombatController.HandleInput(inputData)
	if inputData.action == "PreviousTarget" then
		CombatController.SwitchPrimarySelectedEnemy(
			Handlers.Moves[CharData.selectedMove].enemySelectionType,
			"increment",
			-1
		)
	elseif inputData.action == "NextTarget" then
		CombatController.SwitchPrimarySelectedEnemy(
			Handlers.Moves[CharData.selectedMove].enemySelectionType,
			"increment",
			1
		)
	elseif inputData.action == "BasicAttack" then
		if CharData.selectedMove ~= "WeavingBlade" then
			CharData.selectedMove = "WeavingBlade"
			CombatController.SwitchPrimarySelectedEnemy(
				Handlers.Moves[CharData.selectedMove].enemySelectionType,
				"increment",
				0
			)
			return
		end
		Zap.RequestAttack.Fire({
			char = player.ActiveCharacter.Value,
			data = {
				move = "WeavingBlade",
				primaryTargetIndex = CombatController.GetPrimarySelectedEnemyIndex(),
			},
		})
	end
end

return Setsuna_CombatController
