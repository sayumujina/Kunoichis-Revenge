local CharacterData = require(game.ReplicatedStorage.Shared.data_Types.type_CharacterData)

--- @within data_TYPES
--- @type CharacterCombatData = {atk: number, def: number, hp: number, spd: number, maxEnergy: number, currentEnergy: number}
export type CharacterCombatData = {
	-- Base stats
	baseStats: {
		atk: number,
		def: number,
		hp: number,
		spd: number,
		--
		critRate: number,
		critDmg: number,
		--
		maxEnergy: number,
		ultimateGainEfficiency: number,
	},
	-- Real stats
	realStats: {
		atk: number,
		def: number,
		hp: number,
		spd: number,
		--
		critRate: number,
		critDmg: number,
		--
		ultimateGainEfficiency: number,
	},
}

return nil
