--- @within data_TYPES
--- @type GlobalDataStore = { Shops: { [string]: { Items: { string } } } }
export type GlobalDataStore = {
	Shops: {
		[string]: {
			Items: {
				[string]: {
					Name: string,
					Type: "Character" | "Item" | "Consumable" | "Currency",
					ItemOrder: number,
					Description: string,
					Price: number,
					CurrencyType: string,
					PurchaseLimit: number,
				},
			},
		},
	},
}

return nil
