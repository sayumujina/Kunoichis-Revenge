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

--- @within data_TYPES
--- @type ExtraActionEntry = {currentTurnId: number, extraActionId: number, char: Character, side: Sides, action: string}
export type ExtraActionEntry = {
	currentTurnId: number,
	--
	extraActionId: number,
	char: CharacterTypes.Character,
	side: SidesTypes.Sides,
	action: string,
}

return nil
