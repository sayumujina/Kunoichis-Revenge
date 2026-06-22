local CharacterTypes = require(script.Parent.Parent.type_Character)

--- @within data_TYPES
--- @type PlayerData = { characters: { CharacterTypes.Character },
--- data: { baseStats: { mana: number }, currentStats: { mana: number }, consumablesCount: { [string]: number } } }
export type PlayerCombatData = {
	characters: { CharacterTypes.Character },
	data: {
		-- Base stats
		baseStats: {
			mana: number,
		},
		-- Current stats
		currentStats: {
			mana: number,
		},
		-- Consumables
		consumablesCount: { [string]: number },
	},
}

return nil
