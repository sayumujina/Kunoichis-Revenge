local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["WeavingBlade"] = {
		isDefault = true,
		--
		moveType = "BasicAttack",
		--
		enemySelectionType = "Single",
		--
		data = {
			mult = 100,
			energyGain = 5,
			skillPointGain = 2,
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
		enemySelectionType = "Blast",
		--
		data = {
			mult = 240,
			energyGain = 5,
			skillPointGain = 2,
		},
		--
		info = {
			name = "Twin Blades",
			description = "A skill that deals blast damage to multiple enemies.",
		},
	},
}

return moves
