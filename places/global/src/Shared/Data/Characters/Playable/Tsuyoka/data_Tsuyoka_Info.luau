local _TYPES = require(game.ReplicatedStorage.Data.data_Types)

local info = {
	name = "Tsuyoka",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 2700,
		hp = 3000,
		spd = 170,
		shield = 0,
		--
		critRate = 70,
		critDmg = 140,
		--
		energy = 120,
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
		energy = 80,
		shield = 0,
	},
} :: _TYPES.CharacterInfo

return info
