local _TYPES = require(game.ReplicatedStorage.Data.data_Types)
local GlobalControllers = game:GetService("StarterPlayer").StarterPlayerScripts.Client.GlobalControllers

local data = {
	["Version_1"] = {
		Shops = {
			["CharacterShop"] = {
				Items = {
					["Tsuyoka"] = {
						Name = "Tsuyoka",
						Type = "Character",
						ItemOrder = 1,
						Description = "Tsuyoka possesses a powerful defensive ability that can grant shields to allies, making her valuable against long battles",
						Price = 700,
						CurrencyType = "Koban",
						PurchaseLimit = 1,
					},
					["Rin"] = {
						Name = "Rin",
						Type = "Character",
						ItemOrder = 2,
						Description = "Rin is a support character who is capable of consistently healing and advancing allies' actions, making her a very versatile Kunoichi",
						Price = 700,
						CurrencyType = "Koban",
						PurchaseLimit = 1,
					},
					["Setsuna"] = {
						Name = "Setsuna",
						Type = "Character",
						ItemOrder = 3,
						Description = "Setsuna possesses high damage output, both in single target and blast attacks, making her a strong offensive character in any team composition",
						Price = 700,
						CurrencyType = "Koban",
						PurchaseLimit = 1,
					},
					["YouAintBuyingThisLilBro"] = {
						Name = "You Ain't Buying This Lil Bro",
						Type = "Character",
						ItemOrder = 4,
						Description = "Hell nah",
						Price = 999999,
						CurrencyType = "Koban",
						PurchaseLimit = 1,
					},
				},
				PurchasedPlayers = {
					["7409186113"] = {
						["Setsuna"] = 1,
					},
				},
			},
		},
	},
} :: { [string]: _TYPES.GlobalDataStore }
return data
