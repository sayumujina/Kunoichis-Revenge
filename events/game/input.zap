event InputSent = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		origin: Instance.Model,
        action: string.binary,
    },
}
