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
		data = {
			scalings = {
				realStats = { atk = 70 / 100 },
			},
			energyGain = 5,
			skillPointGain = 2,
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
		data = {
			scalings = {
				realStats = { atk = 160 / 100 },
			},
			energyGain = 5,
			skillPointGain = 2,
		},
		--
		info = {
			name = "Lightning Rain",
			description = "A powerful skill that hits multiple enemies in a blast.",
		},
	},
}

return moves
