local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "Skill"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Moves)[moveName]

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
