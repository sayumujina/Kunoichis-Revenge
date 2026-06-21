--- @within data_TYPES
--- @type MoveType = "BasicAttack" | "Skill" | "Ultimate" | "SkipTurn"
export type MoveType = "BasicAttack" | "Skill" | "Ultimate" | "SkipTurn"

--- @within data_TYPES
--- @type MoveData = "Single" | "Blast" | "AoE"
export type TargetSelectionType =
	"Single" -- Select a single enemy.
	| "Blast" -- Select a main enemy and 2 enemies around them (if they exist).
	| "AoE" -- Select all enemies on the field.

--- @within data_TYPES
--- @type MoveCategory = "Damage" | "Heal" | "Shield" | "Buff" | "Debuff"
export type MoveCategory = "Damage" | "Heal" | "Shield" | "Buff" | "Debuff"

--- @within data_TYPES
--- @type MoveData = {
--- 	moveType: MoveType, moveCategory: MoveCategory, targetSelectionType: TargetSelectionType, selectedSide: "Allies" | "Enemies", data: { atk: number, energyGain: number, skillPointGain: number }, info: { name: string, description: string }
export type MoveData = {
	isDefault: boolean?, -- Whether this move is the default move for the character
	--
	moveType: MoveType,
	moveCategory: MoveCategory,
	--
	targetSelectionType: TargetSelectionType,
	selectedSide: "Allies" | "Enemies",
	--
	data: {
		-- A table of scalings for the move, where the key is the stat name and the value is the scaling multiplier
		scalings: {
			baseStats: { [string]: number }?,
			realStats: { [string]: number }?,
			currentStats: { [string]: number }?,
		},
		--
		energyGain: number,
		skillPointGain: number,
		exposureDealt: number?,
	},
	--
	info: {
		name: string,
		description: string,
	},
}
return nil
