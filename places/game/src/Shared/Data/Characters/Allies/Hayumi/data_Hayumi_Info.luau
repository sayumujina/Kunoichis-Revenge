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
		--
		critRate = 0,
		critDmg = 0,
		--
		startingEnergy = 40,
		maxEnergy = 100,
		ultimateGainEfficiency = 120,
	},
} :: _TYPES.CharacterData

return info
