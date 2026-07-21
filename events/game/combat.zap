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
				targets: Instance.Model[],
				manaChange: f32?,
				attacks: struct {
					attackCategory: string.binary,
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

event MoveEnd = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		origin: Instance.Model, 
		data: struct {
			moveName: string.binary,
			recordedTargets: Instance.Model[],
		},
	},
}

event Damage = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		origin: Instance.Model, 
		data: struct {
			target: Instance.Model,
			damage: f32,
			isCrit: boolean,
		},
	},
}

event ShieldProvided = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		origin: Instance.Model, 
		data: struct {
			target: Instance.Model,
			shieldAmount: f32,
		},
	},
}

event Warning = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		message: string.binary,
	},
}

event StatusAdded = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: struct {
			id: string.binary,
			status: struct {
				statusType: enum { Collapsed, DmgTakenReduced, DmgTakenIncreased }?[],
				info: struct {
					name: string.binary,
					description: string.binary,
				},
				data: struct {
					duration: u8?,
					expellable: boolean?,
				},
				statChanges: struct {
					statChangeType: enum { Flat, Mult, Override },
					statName: string.binary,
					value: f32,
				}[]
			},
			new: boolean,
		},
	},
}

event StatusRemoved = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: struct {
			id: string.binary,
			status: struct {
				statusType: enum { Collapsed, DmgTakenReduced, DmgTakenIncreased }?[],
				info: struct {
					name: string.binary,
					description: string.binary,
				},
				data: struct {
					duration: u8?,
					expellable: boolean?,
				},
				statChanges: struct {
					statChangeType: enum { Flat, Mult, Override }?,
					statName: string.binary,
					value: f32,
				}[]
			},
		},
	},
}

event Death = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		origin: Instance.Model,
	},
}

event CastedUltimate = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model, 
		data: struct {
			fullMoveName: string.binary,
			flashDuration: f32,
		},
	},
}

event ObjectiveFailed = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		objectiveId: string.binary,
	},
}

event BattleEnded= {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		passed: boolean,
		stageId: string.binary,
		worldId: string.binary,
		successfulExtraObjectives: string.binary[]?,
	}
}