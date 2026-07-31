local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["WeavingBlade"] = {
		isDefault = true,
		--
		moveType = "BasicAttack",
		--
		targetSelectionType = "Single",
		selectedSide = "NPC",
		--
		manaChange = 25,
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 100 / 100 },
				},
				energyGain = 20,
				exposureDealt = 10,
			},
		},
		--
		info = {
			name = "Weaving Blade",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["TwinBlades"] = {
		moveType = "Skill",
		--
		targetSelectionType = "Blast",
		selectedSide = "NPC",
		--
		manaChange = -40,
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 120 / 100 },
				},
				energyGain = 20,
				exposureDealt = 10,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 120 / 100 },
				},
				energyGain = 20,
				exposureDealt = 10,
			},
		},
		--
		info = {
			name = "Twin Blades",
			description = "A skill that deals blast damage to multiple enemies.",
		},
	},
	["BladeDance"] = {
		moveType = "Ultimate",
		--
		targetSelectionType = "Blast",
		selectedSide = "NPC",
		--
		manaChange = 0,
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 15 / 100 },
				},
				energyGain = 3,
				exposureDealt = 3,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 20 / 100 },
				},
				energyGain = 3,
				exposureDealt = 3,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 25 / 100 },
				},
				energyGain = 3,
				exposureDealt = 3,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 30 / 100 },
				},
				energyGain = 3,
				exposureDealt = 3,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 35 / 100 },
				},
				energyGain = 3,
				exposureDealt = 3,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 40 / 100 },
				},
				energyGain = 3,
				exposureDealt = 3,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 130 / 100 },
				},
				energyGain = 7,
				exposureDealt = 30,
			},
		},
		--
		info = {
			name = "Blade Dance",
			description = "An ultimate skill that deals damage to multiple enemies.",
		},
	},
}

return moves
