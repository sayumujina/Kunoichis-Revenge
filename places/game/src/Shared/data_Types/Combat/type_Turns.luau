local SidesTypes = require(script.Parent.type_Sides)
local CharacterTypes = require(script.Parent.Parent.type_Character)

--- @within data_TYPES
--- @type TurnEntry = {char: Character, side: Sides, actionValue: number}
export type TurnEntry = {
	turnId: number,
	char: CharacterTypes.Character,
	side: SidesTypes.Sides,
	actionValue: number,
}

return nil
