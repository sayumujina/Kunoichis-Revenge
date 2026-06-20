local CharacterTypes = require(game.ReplicatedStorage.Shared.data_Types.type_Character)

--- @within data_TYPES
--- @type CharacterCombatData = {atk: number, def: number, hp: number, spd: number, maxEnergy: number, currentEnergy: number}
export type AttackData = {
	-- Originator of the attack
	origin: CharacterTypes.Character,
	-- Primary target of the attack
	primaryTargetIndex: number,
	-- Targets to hit
	targets: { CharacterTypes.Character },
	-- Attack data
	data: {
		mult: number?,
		energyGain: number,
		skillPointGain: number,
	},
	-- Info
	info: {
		name: string,
		description: string,
	},
}

return nil
