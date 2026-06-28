local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local StatusService = require(game:GetService("ServerScriptService").Server.Services.StatusService)
local AnimationService = require(game:GetService("ServerScriptService").Server.Services.AnimationService)

-- Collapsed status
local collapsedStatus = {
	statusType = { "Collapsed" } :: { _TYPES.StatusTypes },
	--
	info = {
		name = "Collapsed",
		description = "The character has collapsed. They cannot act and takes increased damage",
	},
	--
	data = {
		duration = 1, -- Collapsed for 1 turn
		expellable = false,
	},
	--
	statChanges = {
		{
			statChangeType = "Mult",
			statName = "dmgTakenMult",
			value = 10 / 100, -- Take 10% more damage while collapsed
		},
	} :: { _TYPES.StatChangeTypes },
} :: _TYPES.Status

return function(target: _TYPES.Character)
	-- Add the collapsed status to the target character
	StatusService.AddStatus(target, "Collapsed", collapsedStatus)
	warn("Collapsed status added to character: " .. target.Name)
end
