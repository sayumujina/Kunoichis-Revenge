event SuccessfulMove = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: struct {
			moveName: string.binary,
			targets: Instance.Model[],
		},
	},
}

event RealStatsChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: map {[string.binary]: f32}
	},
}

event CurrentStatsChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: map {[string.binary]: f32}
	},
}

event PlayerBaseStatsChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		data: map {[string.binary]: f32}
	},
}

event PlayerCurrentStatsChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		data: map {[string.binary]: f32}
	},
}

event UpdateMovePreview = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: struct {
			moveName: string.binary,
			primaryTargetIndex: u8,
		},
	},
}