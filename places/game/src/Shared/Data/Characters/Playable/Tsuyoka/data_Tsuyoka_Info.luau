local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

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
		critRate = 0,
		critDmg = 0,
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
		hp = 2000,
		energy = 80,
		shield = 0,
	},
} :: _TYPES.CharacterInfo

return info
