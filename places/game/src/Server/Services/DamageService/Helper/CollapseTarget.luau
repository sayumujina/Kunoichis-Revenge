local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local StatusService = require(Services.StatusService)
local AnimationService = require(Services.AnimationService)
local TurnService = require(Services.TurnService)

-- Collapsed status
local collapsedStatus = {
	statusType = { "Collapsed" } :: { _TYPES.StatusTypes },
	--
	info = {
		name = "Collapsed",
		description = "The character has collapsed. Their next action will be delayed and takes 10% increased damage",
	},
	--
	data = {
		duration = 1, -- Collapsed for 1 turn
		expellable = false,
	},
	--
	statChanges = {
		{
			statChangeType = "Flat",
			statName = "dmgTakenMult",
			value = 10, -- Take 10% more damage while collapsed
		},
	} :: { _TYPES.StatChangeTypes },
} :: _TYPES.Status

return function(target: _TYPES.Character)
	-- Add the collapsed status to the target character
	StatusService.AddStatus(target, "Collapsed", collapsedStatus)

	-- Delay the target's next action by 60%
	TurnService.AdvanceAction(target, -60 / 100)
end
