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
}

event PlayerDatastoreChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: PlayerDatastore
}

event RequestDatastoreData = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
}

event DatastoreDataResponse = {
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

event Warning = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		message: string.binary,
	},
}