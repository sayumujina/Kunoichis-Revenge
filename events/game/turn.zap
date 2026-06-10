event TurnStarted = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		turnId: u16,
		char: Instance.Model,
	},
}

event TurnCompleted = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		turnId: u16,
	},
}

event TurnRemoved = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		turnId: u16,
		char: Instance.Model,
		side: enum { Allies, Enemies },
	},
}

event TurnRemovedForCharacter = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		side: enum { Allies, Enemies },
	},
}

event TurnAdded = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		turnId: u16,
		char: Instance.Model,
		side: enum { Allies, Enemies },
		actionValue: f64,
	},
}