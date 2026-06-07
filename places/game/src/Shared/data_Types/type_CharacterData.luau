--- @within data_TYPES
--- @type CharacterData = {atk: number, def: number, hp: number, spd: number, critRate: number, critDmg: number, maxEnergy: number, ultimateGainEfficiency: number}
export type CharacterStats = {
	--
	atk: number,
	def: number,
	hp: number,
	spd: number,
	--
	critRate: number,
	critDmg: number,
	--
	startingEnergy: number,
	maxEnergy: number,
	ultimateGainEfficiency: number,
}

export type CharacterData = {
	name: string,
	description: string,
	-- Base stats
	baseStats: CharacterStats,
}

return nil
