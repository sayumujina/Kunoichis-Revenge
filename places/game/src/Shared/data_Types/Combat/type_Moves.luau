--- @within data_TYPES
--- @type MoveType = "BasicAttack" | "Skill" | "Ultimate" | "SkipTurn"
export type MoveType = "BasicAttack" | "Skill" | "Ultimate" | "SkipTurn"

export type MoveData = {
	atk: number,
	energyGain: number,
	skillPointGain: number,
	info: {
		name: string,
		description: string,
	},
}
return nil
