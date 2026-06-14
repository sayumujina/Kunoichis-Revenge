local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
-- Modules
local ExecuteAttack = require(rep.Shared.Modules.Attack.ExecuteAttack)

local moveName = "LightningArrow"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Allies.Hayumi.data_Hayumi_Moves)[moveName]

return function(char: _TYPES.Character)
	local attackData = {
		origin = char,
		targets = {},
		data = moveInfo.data,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	warn("Executing attack:", moveName, "with data:", attackData)
	ExecuteAttack(moveName, attackData, true)
end
