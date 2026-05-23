local CharacterDataTypes = require(game.ReplicatedStorage.Shared.data_Types.type_CharacterData)

local info = {
	name = "MockEnemy",
	description = "",
	-- Base stats
	baseStats = {
		atk = 200,
		def = 140,
		hp = 520,
		spd = 40,
		--
		critRate = 0,
		critDmg = 0,
		--
		maxEnergy = 100,
		ultimateGainEfficiency = 100,
	},
} :: CharacterDataTypes.CharacterData

return info
