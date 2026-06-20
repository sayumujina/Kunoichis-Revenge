local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["LightningArrow"] = {
		isDefault = true,
		--
		moveType = "BasicAttack",
		--
		enemySelectionType = "Single",
		--
		data = {
			mult = 70,
			energyGain = 5,
			skillPointGain = 2,
		},
		--
		info = {
			name = "Lighting Arrow",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["LightningRain"] = {
		moveType = "Skill",
		--
		enemySelectionType = "Blast",
		--
		data = {
			mult = 160,
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
