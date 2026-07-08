local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

local info = {
	name = "Rin",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 140,
		hp = 5000,
		spd = 170,
		shield = 0,
		--
		critRate = -100,
		critDmg = 100,
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
		shieldProvidedMult = 100,
		shieldReceivedMult = 100,
	},
	-- Starting stats
	startingStats = {
		hp = 2000,
		energy = 10,
		shield = 0,
	},
} :: _TYPES.CharacterInfo

return info
