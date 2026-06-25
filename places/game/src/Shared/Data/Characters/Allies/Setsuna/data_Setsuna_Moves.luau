local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["WeavingBlade"] = {
		isDefault = true,
		--
		moveType = "BasicAttack",
		moveCategory = "Damage",
		--
		targetSelectionType = "Single",
		selectedSide = "Enemies",
		--
		manaChange = 25,
		--
		attacks = {
			{
				scalings = {
					realStats = { atk = 100 / 100 },
				},
				energyGain = 5,
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
		moveCategory = "Damage",
		--
		targetSelectionType = "Blast",
		selectedSide = "Enemies",
		--
		manaChange = -40,
		--
		attacks = {
			{
				scalings = {
					realStats = { atk = 120 / 100 },
				},
				energyGain = 5,
				exposureDealt = 10,
			},
			{
				scalings = {
					realStats = { atk = 120 / 100 },
				},
				energyGain = 5,
				exposureDealt = 10,
			},
		},
		--
		info = {
			name = "Twin Blades",
			description = "A skill that deals blast damage to multiple enemies.",
		},
	},
}

return moves
