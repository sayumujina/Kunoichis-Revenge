--- @within data_TYPES
--- @type PlayerStoreData = { OwnedCharacters: { string }, Currencies: { Koban: number } }
export type PlayerStoreData = {
	-- Owned characters
	OwnedCharacters: { string },
	-- Cleared stages
	ClearedStages: {
		{
			worldId: string,
			stageId: string,
			clearedExtraObjectives: { string },
		}
	},
	UnlockedStages: {
		{
			worldId: string,
			stageId: string,
		}
	},
	-- Currencies
	Currencies: {
		Koban: number,
	},
}

return nil
