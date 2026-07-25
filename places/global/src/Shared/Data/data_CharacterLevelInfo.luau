local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)

local charactersLevelInfo = {
	["Setsuna"] = {
		statsChangePerLevel = {
			["hp"] = 10,
			["atk"] = 2,
			["def"] = 1,
		},
		ascensionStages = {
			[1] = {
				["hp"] = 50,
				["atk"] = 5,
				["def"] = 2,
			},
		},
	},
	["Rin"] = {
		statsChangePerLevel = {
			["hp"] = 12,
			["atk"] = 3,
			["def"] = 1,
		},
		ascensionStages = {
			[1] = {
				["hp"] = 60,
				["atk"] = 6,
				["def"] = 2,
			},
		},
	},
	["Hayumi"] = {
		statsChangePerLevel = {
			["hp"] = 15,
			["atk"] = 4,
			["def"] = 2,
		},
		ascensionStages = {
			[1] = {
				["hp"] = 75,
				["atk"] = 8,
				["def"] = 3,
			},
		},
	},
	["Tsuyoka"] = {
		statsChangePerLevel = {
			["hp"] = 20,
			["atk"] = 5,
			["def"] = 3,
		},
		ascensionStages = {
			[1] = {
				["hp"] = 100,
				["atk"] = 10,
				["def"] = 4,
			},
		},
	},
} :: { [string]: _TYPES.CharacterLevelInfo }

return charactersLevelInfo
