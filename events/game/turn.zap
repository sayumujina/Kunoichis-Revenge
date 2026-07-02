event TurnStarted = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		turnId: u16,
		char: Instance.Model,
		previousTurnId: u16?,
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

event ExtraActionAdded = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		currentTurnId: u16,
		extraActionId: u16,
		char: Instance.Model,
		side: enum { Playable, NPC },
		action: string.binary,
		isProcessingAttack: boolean,
	},
}

event ExtraActionCompleted = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		extraActionId: u16,
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
