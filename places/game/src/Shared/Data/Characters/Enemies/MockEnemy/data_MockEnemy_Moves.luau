local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["BasicAttack"] = {
		moveType = "BasicAttack",
		moveCategory = "Damage",
		--
		targetSelectionType = "Single",
		selectedSide = "Enemies",
		--
		data = {
			scalings = {
				realStats = { atk = 100 / 100 },
			},
			energyGain = 5,
			skillPointGain = 2,
		},
		--
		info = {
			name = "Basic Attack",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["Skill"] = {
		moveType = "Skill",
		moveCategory = "Damage",
		--
		targetSelectionType = "Blast",
		selectedSide = "Enemies",
		--
		data = {
			scalings = {
				realStats = { atk = 200 / 100 },
			},
			energyGain = 5,
			skillPointGain = 2,
		},
		--
		info = {
			name = "Skill",
			description = "A skill that hits multiple enemies in a blast.",
		},
	},
}

return moves
