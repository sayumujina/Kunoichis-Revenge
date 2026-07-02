local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Packages
local Trove = require(rep.Packages.Trove)

-- Handlers
local Handlers = {
	Info = require(
		game:GetService("ReplicatedStorage").Shared.Data.Characters.NPC.Red_MockEnemy.data_Red_MockEnemy_Info
	),
	Moves = require(
		game:GetService("ReplicatedStorage").Shared.Data.Characters.NPC.Red_MockEnemy.data_Red_MockEnemy_Moves
	),
}

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
