event SpawnSuccessful = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		character: Instance.Model,
		side: string,
	},
}

event RequestSpawn = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
}
