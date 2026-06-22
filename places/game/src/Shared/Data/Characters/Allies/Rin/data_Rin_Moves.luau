local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

local moves: { [string]: _TYPES.MoveData } = {
	["HiddenAssistance"] = {
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
				realStats = { hp = 5 / 100 },
			},
			energyGain = 5,
			manaChange = 20,
			exposureDealt = 10,
		},
		--
		info = {
			name = "Hidden Assistance",
			description = "A simple attack that deals damage to a single target.",
		},
	},
	["CleansingAura"] = {
		moveType = "Skill",
		moveCategory = "Heal",
		--
		targetSelectionType = "Blast",
		selectedSide = "Allies",
		--
		data = {
			scalings = {
				realStats = { hp = 20 / 100 },
			},
			energyGain = 5,
			manaChange = -20,
			exposureDealt = 20,
		},
		--
		info = {
			name = "Cleansing Aura",
			description = "Replenishes the health for all allies within the blast radius.",
		},
	},
}

return moves
