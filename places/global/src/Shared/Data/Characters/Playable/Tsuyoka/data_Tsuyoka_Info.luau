local _TYPES = require(game.ReplicatedStorage.Data.data_Types)

local info = {
	name = "Tsuyoka",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 1600,
		hp = 3000,
		spd = 170,
		shield = 0,
		--
		critRate = -100,
		critDmg = 10,
		--
		energy = 0,
		ultimateGainEfficiency = 120,
		--
		manaGainEfficiency = 100,
		--
		dmgTakenMult = 100,
		dmgDealtMult = 100,
		--
		healingProvidedMult = 140,
		healingReceivedMult = 100,
		--
		shieldProvidedMult = 140,
		shieldReceivedMult = 100,
	},
	-- Starting stats
	startingStats = {
		hp = 10,
		energy = 80,
		shield = 0,
	},
} :: _TYPES.CharacterInfo

return info
