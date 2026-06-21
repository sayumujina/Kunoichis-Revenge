--- @within data_TYPES
--- @type CharacterData = {atk: number, def: number, startingHp: number, hp: number, spd: number, critRate: number, critDmg: number, maxEnergy: number, ultimateGainEfficiency: number}
export type CharacterStats = {
	--
	atk: number,
	def: number,
	hp: number,
	spd: number,
	shield: number,
	--
	exposure: number?, -- Only for NPCs
	--
	critRate: number,
	critDmg: number,
	--
	energy: number,
	ultimateGainEfficiency: number,
	--
	dmgTakenMult: number,
	dmgDealtMult: number,
	--
	healingProvidedMult: number,
	healingReceivedMult: number,
}

export type CharacterData = {
	name: string,
	description: string,
	-- Base stats
	baseStats: CharacterStats,
	-- Starting stats
	startingStats: {
		hp: number,
		energy: number,
		shield: number,
	},
}

return nil
