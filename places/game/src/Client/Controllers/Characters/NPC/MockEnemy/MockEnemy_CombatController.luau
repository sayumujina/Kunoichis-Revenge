local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Packages
local Trove = require(rep.Packages.Trove)

-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Data.Characters.NPC.MockEnemy.data_MockEnemy_Info),
	Moves = require(game:GetService("ReplicatedStorage").Data.Characters.NPC.MockEnemy.data_MockEnemy_Moves),
}

-- Attack handlers
local AttackHandlers = {
	BasicAttack = require(script.Parent.Handlers.MockEnemy_BasicAttack_Handler),
	Skill = require(script.Parent.Handlers.MockEnemy_Skill_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, _TYPES.AttackData) -> number }

-- Character data

local MockEnemy_CombatController = {}

--- Gets the attack handlers for MockEnemy
function MockEnemy_CombatController.GetAttackHandlers()
	return AttackHandlers
end

return MockEnemy_CombatController
