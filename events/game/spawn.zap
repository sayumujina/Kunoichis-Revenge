event SpawnSuccessfulForChar = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		data: struct {
			side: enum { Playable, NPC },
			realStats: map {[string.binary]: f32},
			currentStats: map {[string.binary]: f32},
		},
	},
}

event SpawnFinished = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct{
		stageData: struct {
			worldId: string,
			stageId: string,
		},
	}
}

event DespawnSuccessful = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct{
		player: Instance.Player,
	}
}

event RestartRequested = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
}

event RestartSuccessful = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
}
