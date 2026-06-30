local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "LightningRain"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Playable.Hayumi.data_Hayumi_Moves)[moveName]

return function(char: _TYPES.Character, primaryTargetIndex: number)
	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		manaChange = moveInfo.manaChange,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, false)
end
