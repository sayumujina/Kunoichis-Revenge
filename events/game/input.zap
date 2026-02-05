event InputSent = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
	data: struct {
        action: string,
    },
}
