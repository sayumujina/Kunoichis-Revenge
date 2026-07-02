local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rep = game:GetService("ReplicatedStorage")
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)
-- Packages
local Trove = require(game.ReplicatedStorage.Packages.Trove)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local CharService = {}

--
local Chars = {} :: { [_TYPES.Character]: _TYPES.CharacterCombatData }

-- Stats template
local statsTemplate = {
	side = "Playable" :: _TYPES.Sides,
	-- Base stats
	baseStats = {
		atk = 1,
		def = 1,
		hp = 1,
		spd = 1,
		shield = 1,
		--
		exposure = 1, -- Only for NPCs
		--
		critRate = 0,
		critDmg = 0,
		--
		energy = 0,
		ultimateGainEfficiency = 100,
		--
		manaGainEfficiency = 100,
		--
		dmgTakenMult = 100,
		dmgDealtMult = 100,
		--
		healingProvidedMult = 100,
		healingReceivedMult = 100,
	},
	-- Real stats
	realStats = {
		atk = 1,
		def = 1,
		hp = 1,
		spd = 1,
		shield = 1,
		--
		exposure = 1, -- Only for NPCs
		--
		critRate = 0,
		critDmg = 0,
		--
		energy = 0,
		ultimateGainEfficiency = 100,
		--
		manaGainEfficiency = 100,
		--
		dmgTakenMult = 100,
		dmgDealtMult = 100,
		--
		healingProvidedMult = 100,
		healingReceivedMult = 100,
	},
	-- Current stats
	currentStats = {
		hp = 1,
		energy = 0,
		shield = 0,
		--
		exposure = 1, -- Only for NPCs
	},
	-- Statuses
	statuses = {},
	-- Trove
	trove = Trove.new(),
} :: _TYPES.CharacterCombatData

-- Helper function to import character data from a data source
local function importCharacterStatsFromSource(char: _TYPES.Character, side: _TYPES.Sides)
	if not char then
		return
	end

	-- Get the path based on the character name, defaults to the "Default" character
	local dataSource
	local dataFolder = rep.Shared.Data.Characters[side]:FindFirstChild(char.Name)
	if dataFolder then
		dataSource = require(dataFolder["data_" .. char.Name .. "_Info"]) :: _TYPES.CharacterInfo
	else
		dataSource = require(rep.Shared.Data.Characters.Default.data_Default_Info) :: _TYPES.CharacterInfo
	end

	-- Set the character's side
	Chars[char].side = side

	-- Get the stats that are needed for combat
	if not dataSource then
		return
	end

	-- Import base stats first
	for statName, stat in pairs(dataSource.baseStats) do
		-- Verify with the base stats
		if Chars[char].baseStats[statName] then
			Chars[char].baseStats[statName] = stat
			-- Since the real stats table is identical, we can copy the base stats to the real stats
			Chars[char].realStats[statName] = stat
		end
	end

	-- Then import the starting stats
	for statName, stat in pairs(dataSource.startingStats) do
		-- Verify with the current stats
		if Chars[char].currentStats[statName] then
			Chars[char].currentStats[statName] = stat
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
--- @param side -- The side the character belongs to (Playable or NPC)
function CharService.LoadCharacterStats(char: _TYPES.Character, side: _TYPES.Sides)
	if not Chars[char] then
		Chars[char] = TableUtil.Copy(statsTemplate, true)
	end

	importCharacterStatsFromSource(char, side)
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

--- Retrieve a specific current stat of a character
--- @param char -- The character to retrieve the stat for
--- @param statName -- The name of the stat to retrieve (e.g., "hp", "energy", "shield")
function CharService.GetCurrentCharacterStat(char: _TYPES.Character, statName: string): number
	return Chars[char].currentStats[statName] or 0
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

	-- Fire the event to notify clients about the real stat change
	EventService.Events.RealStatsChanged:Fire({
		char = char,
		data = { [statName] = newValue },
	})
end

--- Update a specific current stat of a character
--- @param char -- The character to update the stat for
--- @param statName -- The name of the stat to update (e.g., "hp", "energy", "shield")
--- @param newValue -- The new value to set for the stat
function CharService.UpdateCurrentCharacterStat(char: _TYPES.Character, statName: string, newValue: number)
	Chars[char].currentStats[statName] = newValue

	-- Fire the event to notify clients about the current stat change
	EventService.Events.CurrentStatsChanged:Fire({
		char = char,
		data = { [statName] = newValue },
	})
end

--- Get the character's stat
--- @param char -- The character to get the stat for
--- @param statType -- The type of stat to get (baseStats, realStats, currentStats)
--- @param statName -- The name of the stat to get
function CharService.GetCharacterStat(char: _TYPES.Character, statType: string, statName: string): number
	if statType == "baseStats" then
		return CharService.GetBaseCharacterStat(char, statName)
	elseif statType == "realStats" then
		return CharService.GetRealCharacterStat(char, statName)
	elseif statType == "currentStats" then
		return CharService.GetCurrentCharacterStat(char, statName)
	end

	return 0
end

--- Applies all active statuses to the character, modifying its stats accordingly.
--- Updates the character's stats based on the statuses applied.
--- @within CharService
--- @param char -- The character instance.
function CharService.ApplyStatuses(char: _TYPES.Character)
	local chardata = Chars[char]

	-- Copy real stats before applying statuses
	local prevRealStats = TableUtil.Copy(chardata.realStats)
	local default: any = TableUtil.Copy(chardata.baseStats)

	-- Check if the character has any statuses to apply
	if not chardata.statuses then
		return
	end

	local overriddenStats = {}

	-- Loop through all statuses and apply their buffs, if applicable
	for __, status in pairs(chardata.statuses) do
		if not status.statChanges then
			continue
		end

		-- Loop through all stat changes of the status and apply them to the character's stats
		local statusChanges = status.statChanges
		for __, statChangeData in statusChanges do
			local amount = statChangeData.value

			-- Apply the stat change based on the change type (flat, mult, or override)
			if statChangeData.statChangeType == "Flat" then
				default[statChangeData.statName] += amount
			-- In case of a multiplier, we add the mults, not multiplying them
			-- Example: 2 mults: 30% and 60%
			-- The final mult would be 100% + 30% + 60% = 190% total, not 1.3 * 1.6 = 208% total
			elseif statChangeData.statChangeType == "Mult" then
				default[statChangeData.statName] += amount * chardata.baseStats[statChangeData.statName]
			-- For override specifically, once a specific stat is set,
			-- we ignore any subsequent override changes to that same stat from other statuses to avoid conflicts
			elseif statChangeData.statChangeType == "Override" then
				if overriddenStats[statChangeData.statName] then
					continue
				end

				default[statChangeData.statName] = amount
				overriddenStats[statChangeData.statName] = true
			end
		end
	end

	-- Update real stats if there are any changes
	for statName, stat in default do
		if stat ~= prevRealStats[statName] then
			CharService.UpdateRealCharacterStat(char, statName, stat)
		end
	end
end
return CharService
