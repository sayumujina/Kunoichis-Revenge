local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["LightningArrow"] = {
		isDefault = true,
		--
		moveType = "BasicAttack",
		moveCategory = "Damage",
		--
		targetSelectionType = "Single",
		selectedSide = "Enemies",
		--
		manaChange = 20,
		--
		attacks = {
			{
				scalings = {
					realStats = { atk = 70 / 100 },
				},
				energyGain = 5,
				exposureDealt = 10,
			},
		},
		--
		info = {
			name = "Lightning Arrow",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["LightningRain"] = {
		moveType = "Skill",
		moveCategory = "Damage",
		--
		targetSelectionType = "Blast",
		selectedSide = "Enemies",
		--
		manaChange = -15,
		--
		attacks = {
			{
				scalings = {
					realStats = { atk = 160 / 100 },
				},
				energyGain = 5,
				exposureDealt = 20,
			},
		},
		--
		info = {
			name = "Lightning Rain",
			description = "A powerful skill that hits multiple enemies in a blast.",
		},
	},
}

return moves
