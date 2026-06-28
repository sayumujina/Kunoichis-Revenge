local AttackScalingsTypes = require(game.ReplicatedStorage.Shared.data_Types.Combat.type_AttackScalings)

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
--- @type AttackCategory = "Damage" | "Heal" | "Shield" | "Buff" | "Debuff"
export type AttackCategory = "Damage" | "Heal" | "Shield" | "Buff" | "Debuff"

--- @within data_TYPES
--- @type MoveData = {
--- 	moveType: MoveType, targetSelectionType: TargetSelectionType, selectedSide: "Playable" | "NPC", attacks: { attackCategory: AttackCategory, scalings: AttackScalingsTypes.AttackScalings, energyGain: number, manaChange: number }, info: { name: string, description: string }
export type MoveData = {
	isDefault: boolean?, -- Whether this move is the default move for the character
	--
	moveType: MoveType,
	--
	targetSelectionType: TargetSelectionType,
	selectedSide: "Playable" | "NPC",
	-- Mana change
	manaChange: number?, -- Only for playable characters
	-- A table of attacks in the move
	attacks: {
		{
			attackCategory: AttackCategory,
			-- A table of scalings for the move, where the key is the stat name and the value is the scaling multiplier
			scalings: AttackScalingsTypes.AttackScalings,
			-- Energy gain
			energyGain: number?, -- Only for playable characters
			-- Exposure dealt
			exposureDealt: number?, -- Only for playable characters
		}
	},
	--
	info: {
		name: string,
		description: string,
	},
}
return nil
