event SpawnSuccessfulForChar = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		data: struct {
			side: enum { Allies, Enemies },
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
