local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rep = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)

local CharService = {}

--
local Chars = {} :: { [_TYPES.Character]: _TYPES.CharacterCombatData }

-- Stats template
local statsTemplate = {
	side = "Allies" :: _TYPES.Sides,
	--
	baseStats = {
		atk = 1,
		def = 1,
		hp = 1,
		spd = 1,
		--
		critRate = 0,
		critDmg = 0,
		--
		startingEnergy = 0,
		maxEnergy = 0,
		ultimateGainEfficiency = 0,
	},

	realStats = {
		atk = 1,
		def = 1,
		hp = 1,
		spd = 1,
		--
		critRate = 0,
		critDmg = 0,
		--
		currentEnergy = 0,
		ultimateGainEfficiency = 0,
	},
} :: _TYPES.CharacterCombatData

-- Helper function to import character data from a data source
local function importBaseCharacterStatsFromSource(char: _TYPES.Character, side: _TYPES.Sides)
	if not char then
		return
	end

	-- Get the path based on the character name, defaults to the "Default" character
	local dataSource
	local dataFolder = rep.Shared.Data.Characters[side]:FindFirstChild(char.Name)
	if dataFolder then
		dataSource = require(dataFolder["data_" .. char.Name .. "_Info"]) :: _TYPES.CharacterData
	else
		dataSource = require(rep.Shared.Data.Characters.Default.data_Default_Info) :: _TYPES.CharacterData
	end

	-- Set the character's side
	Chars[char].side = side

	-- Get the stats that are needed for combat
	if dataSource then
		for statName, stat in pairs(dataSource.baseStats) do
			-- Verify with the base stats
			if Chars[char].baseStats[statName] then
				Chars[char].baseStats[statName] = stat
			end
			-- Verify with the real stats
			if Chars[char].realStats[statName] then
				Chars[char].realStats[statName] = stat
			end
		end
	end

	return
end

--- Called when the service starts
function CharService.OnStart()
	print("CharService started")

	-- Initialize the chars table
	Chars = {}
end

--- Load base stats of a character into the service's data structure
--- @param char -- The character to load stats for
--- @param side -- The side the character belongs to (Allies or Enemies)
function CharService.LoadCharacterBaseStats(char: _TYPES.Character, side: _TYPES.Sides)
	if not Chars[char] then
		Chars[char] = TableUtil.Copy(statsTemplate, true)
	end

	importBaseCharacterStatsFromSource(char, side)
end

--- Retrieve data from a specified character
--- @param char -- The character to retrieve data for
function CharService.GetCharacterCombatData(char: _TYPES.Character): _TYPES.CharacterCombatData
	return Chars[char]
end

--- Retrieve a specific base stat of a character
--- @param char -- The character to retrieve the stat for
--- @param statName -- The name of the stat to retrieve (e.g., "atk", "def", "hp", "spd")
function CharService.GetBaseCharacterStat(char: _TYPES.Character, statName: string): number
	return Chars[char].baseStats[statName] or 0
end

--- Retrieve a specific real stat of a character
--- @param char -- The character to retrieve the stat for
--- @param statName -- The name of the stat to retrieve (e.g., "atk", "def", "hp", "spd")
function CharService.GetRealCharacterStat(char: _TYPES.Character, statName: string): number
	return Chars[char].realStats[statName] or 0
end

--- Update a specific base stat of a character
--- @param char -- The character to update the stat for
--- @param statName -- The name of the stat to update (e.g., "atk", "def", "hp", "spd")
--- @param newValue -- The new value to set for the stat
function CharService.UpdateBaseCharacterStat(char: _TYPES.Character, statName: string, newValue: number)
	Chars[char].baseStats[statName] = newValue
end

--- Update a specific real stat of a character
--- @param char -- The character to update the stat for
--- @param statName -- The name of the stat to update (e.g., "atk", "def", "hp", "spd")
--- @param newValue -- The new value to set for the stat
function CharService.UpdateRealCharacterStat(char: _TYPES.Character, statName: string, newValue: number)
	Chars[char].realStats[statName] = newValue
end

return CharService
