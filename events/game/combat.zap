event Attack = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
	data: struct {
        action: string.binary,
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