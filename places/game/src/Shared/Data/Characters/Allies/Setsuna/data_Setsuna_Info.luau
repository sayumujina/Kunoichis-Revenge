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
		shield = 0,
		--
		critRate = 0,
		critDmg = 0,
		--
		energy = 100,
		ultimateGainEfficiency = 120,
		--
		dmgTakenMult = 100,
		dmgDealtMult = 140,
		--
		healingProvidedMult = 100,
		healingReceivedMult = 100,
	},
	-- Starting stats
	startingStats = {
		hp = 1100,
		energy = 50,
		shield = 0,
	},
} :: _TYPES.CharacterData

return info
