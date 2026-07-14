local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["BasicAttack"] = {
		moveType = "BasicAttack",
		--
		targetSelectionType = "Single",
		selectedSide = "Playable",
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 100 / 100 },
				},
			},
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
		targetSelectionType = "Blast",
		selectedSide = "Playable",
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 200 / 100 },
				},
			},
		},
		--
		info = {
			name = "Skill",
			description = "A skill that hits multiple enemies in a blast.",
		},
	},
}

return moves
