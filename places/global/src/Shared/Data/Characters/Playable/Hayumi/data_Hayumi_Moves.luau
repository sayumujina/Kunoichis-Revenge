local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["LightningArrow"] = {
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
					realStats = { atk = 70 / 100 },
				},
				energyGain = 20,
				exposureDealt = 10,
			},
		},
		--
		info = {
			name = "Lightning Arrow",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["ArcherysVision"] = {
		moveType = "FollowUp",
		--
		targetSelectionType = "Single",
		selectedSide = "NPC",
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 60 / 100 },
				},
				energyGain = 10,
				exposureDealt = 15,
			},
		},
		--
		info = {
			name = "Archery's Vision",
			description = "Trigger a follow-up attack after an ally's attack, dealing additional damage to a target.",
		},
	},
	["LightningRain"] = {
		moveType = "Skill",
		--
		targetSelectionType = "Blast",
		selectedSide = "NPC",
		--
		manaChange = -30,
		--
		attacks = {
			{
				attackCategory = "Damage",
				scalings = {
					realStats = { atk = 160 / 100 },
				},
				energyGain = 40,
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
