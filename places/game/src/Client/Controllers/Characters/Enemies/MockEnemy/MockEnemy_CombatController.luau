local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local StarterPlayer = game:GetService("StarterPlayer")
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
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Moves),
}
-- Attack handlers
local AttackHandlers = {
	BasicAttack = require(script.Parent.Handlers.MockEnemy_BasicAttack_Handler),
	Skill = require(script.Parent.Handlers.MockEnemy_Skill_Handler),
} :: { [string]: (AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> () }

-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "BasicAttack", -- Player needs to confirm the move twice before executing
}

local MockEnemy_CombatController = {}

--- Gets the attack handlers for MockEnemy
function MockEnemy_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Handles attack input from the player and sends it to the server
--- @param inputData - The input data containing the action and any relevant information
function MockEnemy_CombatController.HandleInput(inputData)
	if inputData.action == "PreviousTarget" then
		CombatController.SwitchPrimarySelectedTarget(
			Handlers.Moves[CharData.selectedMove].targetSelectionType,
			"increment",
			-1
		)
	elseif inputData.action == "NextTarget" then
		CombatController.SwitchPrimarySelectedTarget(
			Handlers.Moves[CharData.selectedMove].targetSelectionType,
			"increment",
			1
		)
	elseif inputData.action == "BasicAttack" then
		if CharData.selectedMove ~= "BasicAttack" then
			CharData.selectedMove = "BasicAttack"
			CombatController.SwitchPrimarySelectedTarget(
				Handlers.Moves[CharData.selectedMove].targetSelectionType,
				"increment",
				0
			)
			return
		end
	end
end

return MockEnemy_CombatController
