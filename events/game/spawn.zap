event SpawnSuccessful = {
	from: Server,
	type: Unreliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		side: enum { Allies, Enemies },
	},
}

event SpawnFinished = {
	from: Server,
	type: Unreliable,
	call: ManyAsync,
}

event RequestSpawn = {
	from: Client,
	type: Unreliable,
	call: ManyAsync,
}
