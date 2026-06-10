local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteAttack = require(rep.Shared.Modules.Attack.ExecuteAttack)
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Moves).Skill

return function(char: _TYPES.Character)
	local attackData = {
		origin = char,
		targets = {},
		data = moveInfo.data,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	ExecuteAttack(attackData, true)
end
