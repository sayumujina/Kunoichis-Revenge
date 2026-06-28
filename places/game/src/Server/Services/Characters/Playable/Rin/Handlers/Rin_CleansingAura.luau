local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "CleansingAura"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Playable.Rin.data_Rin_Moves)[moveName]

return function(char: _TYPES.Character, primaryTargetIndex: number)
	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, true)
end
