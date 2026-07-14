--- @within data_TYPES
--- @type CharacterLevelInfo = { statsChangePerLevel: { [string]: number }, ascensionStages: { [number]: { [string]: number } } }
export type CharacterLevelInfo = {
	-- Stats change per level
	statsChangePerLevel: {
		[string]: number,
	},
	-- Ascension stats change
	ascensionStages: {
		[number]: {
			[string]: number,
		},
	},
}

return nil
