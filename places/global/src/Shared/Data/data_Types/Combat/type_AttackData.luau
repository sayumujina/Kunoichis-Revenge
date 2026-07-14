local CharacterTypes = require(game.ReplicatedStorage.Data.data_Types.type_Character)
local MoveTypes = require(game.ReplicatedStorage.Data.data_Types.Combat.type_Moves)
local AttackScalingsTypes = require(game.ReplicatedStorage.Data.data_Types.Combat.type_AttackScalings)

--- @within data_TYPES
--- @type CharacterCombatData = {atk: number, def: number, hp: number, spd: number, maxEnergy: number, currentEnergy: number}
export type AttackData = {
	-- Primary target of the attack
	primaryTargetIndex: number,
	-- Targets to hit
	targets: { CharacterTypes.Character },
	-- Mana change
	manaChange: number?,
	-- Attacks data
	attacks: {
		{
			-- Attack category
			attackCategory: MoveTypes.AttackCategory,
			scalings: AttackScalingsTypes.AttackScalings,
			energyGain: number?,
			exposureDealt: number?,
		}
	},
	-- Info
	info: {
		name: string,
		description: string,
	},
}

return nil
