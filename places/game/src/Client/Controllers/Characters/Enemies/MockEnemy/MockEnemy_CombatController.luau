local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
-- Packages
local Trove = require(rep.Packages.Trove)
-- Utiltiy

-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Moves),
}
-- Attack handlers
local AttackHandlers = {
	BasicAttack = require(script.Parent.Handlers.MockEnemy_BasicAttack_Handler),
	Skill = require(script.Parent.Handlers.MockEnemy_Skill_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, _TYPES.AttackData) -> number }

-- Character data
local CharData = {
	selectedMove = "BasicAttack", -- Player needs to confirm the move twice before executing
}

local MockEnemy_CombatController = {}

--- Gets the attack handlers for MockEnemy
function MockEnemy_CombatController.GetAttackHandlers()
	return AttackHandlers
end

return MockEnemy_CombatController
