local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

local info = {
	name = "MockEnemy",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 140,
		hp = 12000,
		spd = 40,
		shield = 0,
		--
		exposure = 100,
		--
		critRate = 0,
		critDmg = 0,
		--
		energy = 100,
		ultimateGainEfficiency = 100,
		--
		dmgTakenMult = 130,
		dmgDealtMult = 100,
		--
		healingProvidedMult = 100,
		healingReceivedMult = 100,
	},
	-- Starting stats
	startingStats = {
		hp = 12000,
		energy = 0,
		shield = 0,
		--
		exposure = 40,
	},
} :: _TYPES.CharacterData

return info
