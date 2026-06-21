local CharacterTypes = require(game.ReplicatedStorage.Shared.data_Types.type_Character)
local MoveTypes = require(game.ReplicatedStorage.Shared.data_Types.Combat.type_Moves)

--- @within data_TYPES
--- @type CharacterCombatData = {atk: number, def: number, hp: number, spd: number, maxEnergy: number, currentEnergy: number}
export type AttackData = {
	-- Originator of the attack
	origin: CharacterTypes.Character,
	-- Primary target of the attack
	primaryTargetIndex: number,
	-- Move category
	moveCategory: MoveTypes.MoveCategory,
	-- Targets to hit
	targets: { CharacterTypes.Character },
	-- Attack data
	data: {
		scalings: {
			baseStats: { [string]: number }?,
			realStats: { [string]: number }?,
			currentStats: { [string]: number }?,
		},
		energyGain: number,
		skillPointGain: number,
		exposureDealt: number?,
	},
	-- Info
	info: {
		name: string,
		description: string,
	},
}

return nil
