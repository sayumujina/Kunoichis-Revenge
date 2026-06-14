event RequestAttack = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		data: struct {
       		move: string.binary,
		}
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