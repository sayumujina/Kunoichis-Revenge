local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local AnimationService = require(Services.AnimationService)
-- Modules
local ExecuteAttack = require(rep.Shared.Modules.Attack.ExecuteAttack)

-- Info
local moveName = "WeavingBlade"
local moveInfo = require(rep.Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Moves)[moveName]

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
