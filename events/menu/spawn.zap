event RequestSpawn = {
	from: Client,
	type: Unreliable,
	call: ManyAsync,
	data: struct {
		stageId: string.binary,
		worldId: string.binary,
		chars: string.binary[],
	},
}