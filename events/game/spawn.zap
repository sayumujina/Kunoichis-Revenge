event SpawnSuccessful = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		characters: Instance.Model[]
	},
}
