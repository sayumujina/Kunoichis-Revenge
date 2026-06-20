event RequestAttack = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		data: struct {
       		move: string.binary,
			primaryTargetIndex: u8,
		}
    },
}

event SuccessfulAttack = {
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

event EnergyChanged = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: struct {
			oldEnergy: f32,
			newEnergy: f32,
		},
	},
}