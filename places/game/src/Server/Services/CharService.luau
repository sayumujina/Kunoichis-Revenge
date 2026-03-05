local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local rep = game:GetService("ReplicatedStorage")

local CharService = {}

--
local Chars = {} :: { [_TYPES.Character]: _TYPES.CharacterCombatData }

-- Helper function to import character data from a data source
local function importBaseCharacterStatsFromSource(char: _TYPES.Character)
	-- Get the path based on the character name
	local dataSource = require(rep.Data.Characters[char.Name]["data_" .. char.Name .. "_Info"]) :: _TYPES.CharacterStats

	-- Get the stats that are needed for combat
	for stat in pairs(dataSource) do
		-- Verify with the base stats
		if table.find(Chars[char].baseStats, stat) then
			Chars[char].baseStats[stat] = dataSource[stat]
		end
		-- Verify with the real stats
		if table.find(Chars[char].realStats, stat) then
			Chars[char].realStats[stat] = dataSource[stat]
		end
	end
	return
end

--- Called when the service starts
function CharService.OnStart()
	print("CharService started")
end

--- Retrieve data from a specified character
--- @param char -- The character to retrieve data for
function CharService.GetCharacterCombatData(char: _TYPES.Character): _TYPES.CharacterCombatData
	return Chars[char]
end

--- Retrieve a specific stat of a character
--- @param char -- The character to retrieve the stat for
--- @param statName -- The name of the stat to retrieve (e.g., "atk", "def", "hp", "spd")
function CharService.GetCharacterStat(char: _TYPES.Character, statName: string): number
	local charData = CharService.GetCharacterCombatData(char)
	return charData[statName] or 0
end

--- Update a specific stat of a character
--- @param char -- The character to update the stat for
--- @param statName -- The name of the stat to update (e.g., "atk", "def", "hp", "spd")
--- @param newValue -- The new value to set for the stat
function CharService.UpdateCharacterStat(char: _TYPES.Character, statName: string, newValue: number)
	local charData = CharService.GetCharacterCombatData(char)
	charData[statName] = newValue
end

return CharService
