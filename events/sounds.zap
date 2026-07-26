event RequestPlaySound = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: string.binary,
}
