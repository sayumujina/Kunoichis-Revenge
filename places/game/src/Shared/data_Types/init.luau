local CharacterTypes = require(script.type_Character)

--
local CharacterCombatDataTypes = require(script.Combat.type_CharacterCombatData)
local PlayerCombatDataTypes = require(script.Combat.type_PlayerCombatData)
local SidesTypes = require(script.Combat.type_Sides)
local TurnTypes = require(script.Combat.type_Turns)
local CharacterDataTypes = require(script.type_CharacterData)
local AttackDataTypes = require(script.Combat.type_AttackData)

export type Character = CharacterTypes.Character
export type RobloxPlayerType = CharacterTypes.RobloxPlayerType

-- Combat data types
export type CharacterCombatData = CharacterCombatDataTypes.CharacterCombatData
export type PlayerCombatData = PlayerCombatDataTypes.PlayerCombatData
export type Sides = SidesTypes.Sides

-- Character data types
export type CharacterStats = CharacterDataTypes.CharacterStats
export type CharacterData = CharacterDataTypes.CharacterData

-- Turn types
export type TurnEntry = TurnTypes.TurnEntry

-- Combat data
export type AttackData = AttackDataTypes.AttackData

return nil
