local _TYPES = require(game.ReplicatedStorage.Data.data_Types)
local GlobalControllers = game:GetService("StarterPlayer").StarterPlayerScripts.Client.GlobalControllers

local data: _TYPES.PlayerStoreData = {
	OwnedCharacters = {
		["Hayumi"] = {
			Level = 20,
			Experience = 1000,
			AscensionStage = 1,
		},
		["Setsuna"] = {
			Level = 15,
			Experience = 500,
			AscensionStage = 0,
		},
	},
	--
	UnlockedStages = {
		Worlds = {
			["World1"] = {
				Stages = {
					["1-1"] = {
						Cleared = true,
						ClearedExtraObjectives = { "Objective1" },
					},
					["1-2"] = {
						Cleared = true,
						ClearedExtraObjectives = {},
					},
					["1-3"] = {
						Cleared = false,
						ClearedExtraObjectives = {},
					},
				},
			},
		},
	},
	--
	Currencies = {
		Koban = 1000,
	},
}

return data
