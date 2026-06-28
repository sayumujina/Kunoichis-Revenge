local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "VanguardsCall"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Playable.Rin.data_Rin_Moves)[moveName]

return function(char: _TYPES.Character, primaryTargetIndex: number)
	-- Set energy to 0 after executing the ultimate
	CharService.UpdateCurrentCharacterStat(char, "energy", 0)

	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, true)
end
