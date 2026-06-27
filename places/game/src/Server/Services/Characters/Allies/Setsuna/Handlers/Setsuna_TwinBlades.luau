local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "TwinBlades"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Moves)[moveName]

return function(char: _TYPES.Character, primaryTargetIndex: number)
	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		moveCategory = moveInfo.moveCategory,
		manaChange = moveInfo.manaChange,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	ExecuteMove(char, moveName, attackData, true)
end
