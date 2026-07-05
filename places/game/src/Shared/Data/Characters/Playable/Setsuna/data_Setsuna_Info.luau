local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

local info = {
	name = "Setsuna",
	description = "",
	-- Base stats
	baseStats = {
		atk = 750,
		def = 140,
		hp = 2000,
		spd = 120,
		shield = 0,
		--
		critRate = 90,
		critDmg = 160,
		--
		energy = 100,
		ultimateGainEfficiency = 120,
		--
		manaGainEfficiency = 100,
		--
		dmgTakenMult = 110,
		dmgDealtMult = 140,
		--
		healingProvidedMult = 100,
		healingReceivedMult = 100,
		--
		shieldProvidedMult = 100,
		shieldReceivedMult = 100,
	},
	-- Starting stats
	startingStats = {
		hp = 1100,
		energy = 50,
		shield = 0,
	},
} :: _TYPES.CharacterInfo

return info
