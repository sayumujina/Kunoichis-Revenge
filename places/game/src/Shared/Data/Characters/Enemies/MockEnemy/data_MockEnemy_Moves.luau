local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["BasicAttack"] = {
		moveType = "BasicAttack",
		--
		enemySelectionType = "Single",
		--
		data = {
			atk = 10,
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
		--
		enemySelectionType = "Blast",
		--
		data = {
			atk = 10,
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
