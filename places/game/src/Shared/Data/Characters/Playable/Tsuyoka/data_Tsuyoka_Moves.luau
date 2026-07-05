local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["NoEscape"] = {
		isDefault = true,
		--
		moveType = "BasicAttack",
		--
		targetSelectionType = "Single",
		selectedSide = "NPC",
		--
		manaChange = 20,
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { def = 20 / 100 },
				},
				energyGain = 10,
				exposureDealt = 10,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { def = 20 / 100 },
				},
				energyGain = 10,
				exposureDealt = 10,
			},
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { def = 20 / 100 },
				},
				energyGain = 10,
				exposureDealt = 10,
			},
		},
		--
		info = {
			name = "No Escape",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["Solidify"] = {
		moveType = "Skill",
		--
		targetSelectionType = "Single",
		selectedSide = "Playable",
		--
		manaChange = -20,
		attacks = {
			{
				attackCategory = "Shield",
				scalings = {
					realStats = { def = 10 / 100 },
				},
				energyGain = 40,
				exposureDealt = 0,
			},
		},
		--
		info = {
			name = "Solidify",
			description = "Provides a shield for one ally",
		},
	},
	["DestructiveCriticism"] = {
		moveType = "Ultimate",
		--
		targetSelectionType = "AoE",
		selectedSide = "Playable",
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { def = 50 / 100 },
				},
				energyGain = 0,
				exposureDealt = 0,
			},
		},
		--
		info = {
			name = "Destructive Criticism",
			description = "Deals damage to all enemies and applies vulnerability",
		},
	},
}

return moves
