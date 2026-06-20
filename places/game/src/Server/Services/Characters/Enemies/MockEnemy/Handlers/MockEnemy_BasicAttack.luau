local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteAttack = require(rep.Shared.Modules.Attack.ExecuteAttack)

local moveName = "BasicAttack"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Moves)[moveName]

return function(char: _TYPES.Character, primaryTargetIndex: number)
	local attackData = {
		origin = char,
		primaryTargetIndex = primaryTargetIndex,
		targets = {},
		data = moveInfo.data,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	ExecuteAttack(moveName, attackData, true)
end
