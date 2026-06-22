local SideTypes = require(script.Parent.type_Sides)
local CharacterDataTypes = require(script.Parent.Parent.type_CharacterData)
local StatusTypes = require(script.Parent.type_Status)

--- @within data_TYPES
--- @type CharacterCombatData = { side: SideTypes.Sides,
--- baseStats: CharacterDataTypes.CharacterStats,
--- realStats: CharacterDataTypes.CharacterStats,
--- currentStats: { hp: number, energy: number, shield: number, exposure: number? },
--- statuses: { [string]: StatusTypes.Status }?, consumables: { [string]: number }? }
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
		--
		exposure: number?, -- Only for NPCs
	},
	-- Statuses
	statuses: { [string]: StatusTypes.Status }?,
}

--- @within data_TYPES
--- @type PlayerCombatData = CharacterCombatData & { player: CharacterTypes.RobloxPlayerType }
export type NPCCombatData = CharacterCombatData & {
	-- NPC specific combat data can be added here in the future
	currentPatternIndex: number, -- The index of the current action the NPC is performing in its' action list. Resets after reaching the end of the list.
}

return nil
