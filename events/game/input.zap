event InputSent = {
	from: Client,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		origin: Instance.Model,
        action: string.binary,
    },
}

event AllowCombatInfoMenuToggle = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		allowed: boolean,
	},
}

event ToggleInputAllowance = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		allowed: boolean,
	},
}