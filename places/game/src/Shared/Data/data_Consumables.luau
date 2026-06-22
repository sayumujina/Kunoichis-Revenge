local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)

local consumables = {
	["HealingOnigiri"] = {
		consumableType = "Regeneration",
		data = {
			scalings = {
				["hp"] = {
					mult = 0.5,
					flat = 200,
				},
			},
		} :: _TYPES.RegenerationConsumables,
		info = {
			name = "Healing Onigiri",
			description = "A delicious onigiri that restores HP when consumed.",
		},
	},
} :: { [string]: _TYPES.Consumables }

return consumables
