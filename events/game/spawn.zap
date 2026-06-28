event SpawnSuccessfulForChar = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		data: struct {
			side: enum { Playable, NPC },
		},
	},
}

event SpawnFinished = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
}

event RequestSpawn = {
	from: Client,
	type: Unreliable,
	call: ManyAsync,
}
