local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

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
				energyGain = 10,
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
					realStats = { hp = 10 / 100 },
				},
				energyGain = 20,
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
		attacks = {
			{
				attackCategory = "Heal",
				scalings = {
					realStats = { hp = 40 / 100 },
				},
				energyGain = 0,
				exposureDealt = 0,
			},
			{
				attackCategory = "Buff",
				scalings = {
					realStats = { atk = 20 / 100 },
				},
				energyGain = 20,
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
