local CharacterTypes = require(script.type_Character)

--
local CharacterCombatDataTypes = require(script.Combat.type_CharacterCombatData)
local PlayerCombatDataTypes = require(script.Combat.type_PlayerCombatData)
local SidesTypes = require(script.Combat.type_Sides)
local TurnTypes = require(script.Combat.type_Turns)
local CharacterDataTypes = require(script.type_CharacterData)
local AttackDataTypes = require(script.Combat.type_AttackData)
local MoveTypes = require(script.Combat.type_Moves)
local StatusTypes = require(script.Combat.type_Status)
local ConsumablesTypes = require(script.Combat.type_Consumables)
local AttackScalingsTypes = require(script.Combat.type_AttackScalings)
local KnockbackTypes = require(script.Combat.type_Knockback)
local InputDataTypes = require(script.Combat.type_InputData)
local DamageTypes = require(script.Combat.type_Damage)
local StageTypes = require(script.type_Stage)

export type Character = CharacterTypes.Character
export type RobloxPlayerType = CharacterTypes.RobloxPlayerType

-- Combat data types
export type CharacterCombatData = CharacterCombatDataTypes.CharacterCombatData
export type CombatCharData<I> = CharacterCombatDataTypes.CombatCharData<I>
export type NPCCombatData = CharacterCombatDataTypes.NPCCombatData
export type PlayerCombatData = PlayerCombatDataTypes.PlayerCombatData
export type Sides = SidesTypes.Sides
export type MoveType = MoveTypes.MoveType
export type MoveData = MoveTypes.MoveData

-- Character data types
export type CharacterStats = CharacterDataTypes.CharacterStats
export type CharacterInfo = CharacterDataTypes.CharacterInfo

-- Turn types
export type TurnEntry = TurnTypes.TurnEntry
export type ExtraActionEntry = TurnTypes.ExtraActionEntry

-- Combat data
export type AttackData = AttackDataTypes.AttackData

-- Knockback
export type KnockbackOptions = KnockbackTypes.KnockbackOptions

-- Input data
export type InputData = InputDataTypes.InputData

-- Attack scalings
export type AttackScalings = AttackScalingsTypes.AttackScalings

-- Status
export type StatusTypes = StatusTypes.StatusTypes
export type StatChangeTypes = StatusTypes.StatChangeTypes
export type Status = StatusTypes.Status

-- Damage
export type Damage = DamageTypes.Damage

-- Consumables
export type ConsumableType = ConsumablesTypes.ConsumableType
export type Consumables = ConsumablesTypes.Consumables
export type RegenerationConsumables = ConsumablesTypes.RegenerationConsumables
export type BuffingConsumables = ConsumablesTypes.BuffingConsumables

-- Stage
export type Stage = StageTypes.Stage

return nil
