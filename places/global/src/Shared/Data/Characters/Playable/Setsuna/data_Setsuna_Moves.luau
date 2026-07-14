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
}

return moves
