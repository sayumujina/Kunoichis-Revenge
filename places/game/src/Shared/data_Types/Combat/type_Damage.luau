local CharacterTypes = require(script.Parent.Parent.Parent.Parent.Shared.data_Types.type_Character)

--- @within data_TYPES
--- @type Damage = {target: Character, damage: number, isCrit: boolean}
export type Damage = {
	target: CharacterTypes.Character,
	damage: number,
	isCrit: boolean,
}

return nil
