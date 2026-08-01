local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Packages
local Trove = require(rep.Packages.Trove)

-- Attack handlers
local AttackHandlers = {
	BasicAttack = require(script.Parent.Handlers.Red_MockEnemy_BasicAttack_Handler),
	Skill = require(script.Parent.Handlers.Red_MockEnemy_Skill_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, _TYPES.AttackData) -> number }

-- Character data

local Red_MockEnemy_CombatController = {}

--- Gets the attack handlers for Red_MockEnemy
function Red_MockEnemy_CombatController.GetAttackHandlers()
	return AttackHandlers
end

return Red_MockEnemy_CombatController
