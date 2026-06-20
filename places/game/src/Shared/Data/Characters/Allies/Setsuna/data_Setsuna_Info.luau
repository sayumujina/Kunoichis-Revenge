local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

local info = {
	name = "Setsuna",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 140,
		hp = 1800,
		spd = 120,
		--
		critRate = 0,
		critDmg = 0,
		--
		startingEnergy = 0,
		maxEnergy = 100,
		ultimateGainEfficiency = 120,
	},
} :: _TYPES.CharacterData

return info
