event SpawnSuccessfulForChar = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
	data: struct {
		char: Instance.Model,
		data: struct {
			side: enum { Allies, Enemies },
			baseStats: struct {
				atk: u32,
				def: u32,
				hp: u32,
				spd: u32,
				--
				critRate: u32,
				critDmg: u32,
				--
				startingEnergy: u32,
				maxEnergy: u32,
				ultimateGainEfficiency: u32,
			},
			realStats: struct {
				atk: u32,
				def: u32,
				hp: u32,
				spd: u32,
				--
				critRate: u32,
				critDmg: u32,
				--
				currentEnergy: u32,
				ultimateGainEfficiency: u32,
			},
		},
	},
}

event SpawnFinished = {
	from: Server,
	type: Reliable,
	call: ManyAsync,
}

event RequestSpawn = {
	from: Client,
	type: Unreliable,
	call: ManyAsync,
}
