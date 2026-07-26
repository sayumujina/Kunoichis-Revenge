local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["HiddenAssistance"] = {
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
					realStats = { hp = 5 / 100 },
				},
				energyGain = 20,
				exposureDealt = 10,
			},
		},
		--
		info = {
			name = "Hidden Assistance",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["CleansingAura"] = {
		moveType = "Skill",
		--
		targetSelectionType = "Blast",
		selectedSide = "Playable",
		--
		manaChange = -20,
		attacks = {
			{
				attackCategory = "Heal",
				scalings = {
					realStats = { hp = 7 / 100 },
				},
				energyGain = 40,
				exposureDealt = 0,
			},
		},
		--
		info = {
			name = "Cleansing Aura",
			description = "Replenishes the health for all allies within the blast radius.",
		},
	},
	["VanguardsCall"] = {
		moveType = "Ultimate",
		--
		targetSelectionType = "Single",
		selectedSide = "Playable",
		--
		cinematicInfo = {
			flashDuration = 1.5,
		},
		--
		attacks = {
			{
				attackCategory = "Heal",
				scalings = {
					realStats = { hp = 18 / 100 },
				},
				energyGain = 0,
				exposureDealt = 0,
			},
		},
		--
		info = {
			name = "Vanguard's Call",
			description = "Increases the attack power of all allies on the field.",
		},
	},
}

return moves
