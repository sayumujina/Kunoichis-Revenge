local SideTypes = require(script.Parent.type_Sides)
local CharacterDataTypes = require(script.Parent.Parent.type_CharacterData)
--- @within data_TYPES
--- @type CharacterCombatData = {atk: number, def: number, hp: number, spd: number, maxEnergy: number, currentEnergy: number}
export type CharacterCombatData = {
	-- Side
	side: SideTypes.Sides,
	-- Base stats
	baseStats: CharacterDataTypes.CharacterStats,
	-- Real stats
	realStats: CharacterDataTypes.CharacterStats,
	-- Current stats
	currentStats: {
		hp: number,
		energy: number,
		shield: number,
	},
}

export type NPCCombatData = CharacterCombatData & {
	-- NPC specific combat data can be added here in the future
	currentPatternIndex: number, -- The index of the current action the NPC is performing in its' action list. Resets after reaching the end of the list.
}

return nil
