local _TYPES = require(game.ReplicatedStorage.Data.data_Types)

local info = {
	name = "Hayumi",
	description = "",
	-- Base stats
	baseStats = {
		atk = 850,
		def = 140,
		hp = 3000,
		spd = 90,
		shield = 0,
		--
		critRate = 60,
		critDmg = 110,
		--
		energy = 120,
		ultimateGainEfficiency = 120,
		--
		manaGainEfficiency = 100,
		--
		dmgTakenMult = 100,
		dmgDealtMult = 100,
		--
		healingProvidedMult = 100,
		healingReceivedMult = 100,
		--
		shieldProvidedMult = 100,
		shieldReceivedMult = 100,
	},
	-- Starting stats
	startingStats = {
		energy = 120,
		shield = 0,
	},
} :: _TYPES.CharacterInfo

return info
