local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

local info = {
	name = "Hayumi",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 140,
		hp = 2200,
		spd = 90,
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
	},
	-- Starting stats
	startingStats = {
		hp = 2000,
		energy = 40,
		shield = 0,
	},
} :: _TYPES.CharacterData

return info
