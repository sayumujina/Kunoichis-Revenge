--- @within data_TYPES
--- @type MoveType = "BasicAttack" | "Skill" | "Ultimate" | "SkipTurn"
export type MoveType = "BasicAttack" | "Skill" | "Ultimate" | "SkipTurn"

--- @within data_TYPES
--- @type MoveData = "Single" | "Blast" | "AoE"
export type EnemySelectionType =
	"Single" -- Select a single enemy.
	| "Blast" -- Select a main enemy and 2 enemies around them (if they exist).
	| "AoE" -- Select all enemies on the field.

--- @within data_TYPES
--- @type MoveData = {
--- 	moveType: MoveType, enemySelectionType: EnemySelectionType, data: { atk: number, energyGain: number, skillPointGain: number }, info: { name: string, description: string }
export type MoveData = {
	moveType: MoveType,
	--
	enemySelectionType: EnemySelectionType,
	--
	data: {
		atk: number,
		energyGain: number,
		skillPointGain: number,
	},
	--
	info: {
		name: string,
		description: string,
	},
}
return nil
