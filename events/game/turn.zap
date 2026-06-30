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
		side: enum { Playable, NPC },
	},
}

event TurnRemovedForCharacter = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		side: enum { Playable, NPC },
	},
}

event TurnAdded = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		turnId: u16,
		char: Instance.Model,
		side: enum { Playable, NPC },
		actionValue: f64,
	},
}

event ActionAdvance = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		advancedBy: f64,
	},
}