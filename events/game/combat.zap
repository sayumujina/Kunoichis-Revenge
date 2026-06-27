event SuccessfulMove = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		origin: Instance.Model,
		data: struct {
			moveName: string.binary,
			attackData: struct {
				primaryTargetIndex: u8,
				moveCategory: string.binary,
				targets: Instance.Model[],
				manaChange: f32?,
				attacks: struct {
					scalings: struct {
						baseStats: map {[string.binary]: f32}?,
						realStats: map {[string.binary]: f32}?,
						currentStats: map {[string.binary]: f32}?,
					},
					energyGain: f32?,
					exposureDealt: f32?,
				}[],
				info: struct {
					name: string.binary,
					description: string.binary,
				},
			}
		}
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