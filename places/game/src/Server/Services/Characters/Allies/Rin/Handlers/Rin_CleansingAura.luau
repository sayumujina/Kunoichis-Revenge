local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "CleansingAura"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Allies.Rin.data_Rin_Moves)[moveName]

return function(char: _TYPES.Character, primaryTargetIndex: number)
	local attackData = {
		origin = char,
		primaryTargetIndex = primaryTargetIndex,
		moveCategory = moveInfo.moveCategory,
		targets = {},
		data = moveInfo.data,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	ExecuteMove(moveName, attackData, true)
end
