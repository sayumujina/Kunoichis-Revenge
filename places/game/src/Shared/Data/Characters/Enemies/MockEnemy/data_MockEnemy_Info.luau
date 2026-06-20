local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

local info = {
	name = "MockEnemy",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 140,
		hp = 1200,
		spd = 40,
		shield = 0,
		--
		critRate = 0,
		critDmg = 0,
		--
		energy = 100,
		ultimateGainEfficiency = 100,
		--
		dmgTakenMult = 130,
		dmgDealtMult = 100,
	},
	-- Starting stats
	startingStats = {
		hp = 1200,
		energy = 0,
		shield = 0,
	},
} :: _TYPES.CharacterData

return info
