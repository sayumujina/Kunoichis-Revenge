local StatusTypes = require(script.Parent.type_Status)
local CharacterTypes = require(script.Parent.Parent.type_Character)

--- @within data_TYPES
--- @type ConsumableType = "Healing" | "Buffing"
export type ConsumableType = "Regeneration" | "Buffing"

--- @within data_TYPES
--- @type Consumables = { type: ConsumableType, data: RegenerateConsumables | BuffingConsumables, info: { name: string, description: string } }
export type Consumables = {
	consumableType: ConsumableType,
	data: RegenerationConsumables | BuffingConsumables,
	info: {
		name: string,
		description: string,
	},
}

--- @within data_TYPES
--- @type RegenerationConsumables = { healScaling: { [string]: { mult: number?, flat: number? } } }
export type RegenerationConsumables = {
	scalings: {
		{ -- A table of the stats to scale the regeneration with
			[string]: { -- The stat to scale the regeneration with
				mult: number?, -- The multiplier for the regeneration based on the character's stats
				flat: number?, -- A flat regeneration amount added on top of the scaling regeneration
			},
		}
	},
}

--- @within data_TYPES
--- @type BuffingConsumables = { statusEffects: { StatusTypes.Status } }
export type BuffingConsumables = {
	statusEffects: { StatusTypes.Status }, -- The status effects to apply to the target
}

return nil
