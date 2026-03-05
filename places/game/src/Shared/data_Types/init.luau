local CharacterTypes = require(script.type_Character)

--
local CharacterCombatDataTypes = require(script.Combat.type_CharacterCombatData)
local PlayerCombatDataTypes = require(script.Combat.type_PlayerCombatData)
local CharacterDataTypes = require(script.type_CharacterData)

export type Character = CharacterTypes.Character
export type RobloxPlayerType = CharacterTypes.RobloxPlayerType

-- Combat data types
export type CharacterCombatData = CharacterCombatDataTypes.CharacterCombatData
export type PlayerCombatData = PlayerCombatDataTypes.PlayerCombatData

-- Character data types
export type CharacterStats = CharacterDataTypes.CharacterStats
export type CharacterData = CharacterDataTypes.CharacterData

return nil
