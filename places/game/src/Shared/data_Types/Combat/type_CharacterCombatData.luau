local SideTypes = require(script.Parent.type_Sides)

--- @within data_TYPES
--- @type CharacterCombatData = {atk: number, def: number, hp: number, spd: number, maxEnergy: number, currentEnergy: number}
export type CharacterCombatData = {
	-- Side
	side: SideTypes.Sides,
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
		startingEnergy: number,
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
		currentEnergy: number,
		ultimateGainEfficiency: number,
	},
}

export type NPCCombatData = CharacterCombatData & {
	-- NPC specific combat data can be added here in the future
	currentPatternIndex: number, -- The index of the current action the NPC is performing in its' action list. Resets after reaching the end of the list.
}

return nil
