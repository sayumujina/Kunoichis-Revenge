type OwnedCharacterInfo = {
	Level: number,
	Experience: number,
	AscensionStage: number,
}

type UnlockedStageInfo = {
	Cleared: boolean,
	ClearedExtraObjectives: { string },
}

--- @within data_TYPES
--- @type PlayerStoreData = { OwnedCharacters: { OwnedCharacterInfo }, UnlockedStages: { Worlds: { WorldId: string, Stages: { UnlockedStageInfo } } }, Currencies: { Koban: number } }
export type PlayerStoreData = {
	-- Owned characters
	OwnedCharacters: { [string]: OwnedCharacterInfo },
	-- Cleared stages
	UnlockedStages: {
		Worlds: {
			[string]: {
				Stages: { [string]: UnlockedStageInfo },
			},
		},
	},
	-- Currencies
	Currencies: {
		Koban: number,
	},
	-- Purchased items from shops
	PurchasedItemsFromShops: {
		[string]: {
			[string]: number,
		},
	},
}

return nil
