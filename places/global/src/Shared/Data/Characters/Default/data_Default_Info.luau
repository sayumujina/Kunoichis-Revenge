local CharacterDataTypes = require(game.ReplicatedStorage.Data.data_Types.type_CharacterData)

local info = {
	name = "Default",
	description = "",
	-- Base stats
	baseStats = {
		atk = 1,
		def = 1,
		hp = 1,
		spd = 1,
		shield = 1,
		--
		exposure = 1,
		--
		critRate = 0,
		critDmg = 0,
		--
		energy = 100,
		ultimateGainEfficiency = 100,
		--
		manaGainEfficiency = 100,
		--
		dmgTakenMult = 100,
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
} :: CharacterDataTypes.CharacterInfo

return info
