type Stage = struct {
    Cleared: boolean,
    ClearedExtraObjectives: string.utf8[],
}

type World = struct {
    Stages: map {[string.utf8]: Stage},
}

type OwnedCharacter = struct {
    Level: i32,
    Experience: f32,
    AscensionStage: i32,
}

type PlayerDatastore = struct {
    OwnedCharacters: map {[string.utf8]: OwnedCharacter},
    UnlockedStages: struct { Worlds: map {[string.utf8]: World} },
    Currencies: struct {
        Koban: f32,
    },
    PurchasedItemsFromShops: map {[string.utf8]: map {[string.utf8]: u32}},
}

event PlayerDatastoreChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: PlayerDatastore
}

event RequestPlayerstoreData = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
}

event PlayerstoreDataResponse = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: PlayerDatastore
}

event PlayerDatastoreLoaded = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: PlayerDatastore
}
	
type Item = struct {
    Name: string.utf8,
    Type: enum { Character, Item, Consumable, Currency },
    ItemOrder: u32,
    Description: string.utf8,
    Price: u32,
    CurrencyType: string.utf8,
    PurchaseLimit: u32,
}

type Shop = struct {
    Items: map {[string.utf8]: Item},
}

type GlobalDatastore = struct {
    Shops: map {[string.utf8]: Shop},
}

event GlobalDataStoreChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: GlobalDatastore,
}

event RequestGlobalstoreData = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
}

event GlobalstoreDataResponse = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: GlobalDatastore,
}

event GlobalDatastoreLoaded = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: GlobalDatastore,
}

event RequestPurchaseItem = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		shopId: string.utf8,
		itemId: string.utf8,
	},
}

event PurchaseResponse = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		itemId: string.utf8,
		success: boolean,
		purchasesLeft: u32,
	},
}

event Warning = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		success: boolean?,
		message: string.binary,
	},
}
