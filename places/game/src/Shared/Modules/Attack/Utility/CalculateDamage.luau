local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local LogService = game:GetService("LogService")

--- Calculates the final damage dealt by an attack based on the provided scalings, origin character, and target character.
--- @within Modules
--- @param scalings - The attack scalings to use for the damage calculation
--- @param origin - The character dealing the damage
--- @param target - The character receiving the damage
--- @param moveName - The name of the move being executed (for logging purposes)
--- @return number, boolean - The final damage dealt and whether the hit was a critical hit
return function(scalings: _TYPES.AttackScalings, origin: _TYPES.Character, target: _TYPES.Character, moveName: string)
	-- Outgoing DMG =
	-- Base DMG -- Character's scaled stats * skill scalings
	-- × DMG% Multiplier -- Damage bonus from buffs, debuffs, and other sources
	-- × DEF Multiplier -- The higher the attacker level compared to defender level, the greater the DEF Multiplier
	-- 100% - [DEF / (DEF + 200 + 10 * Attacker Level)]
	-- × DMG Taken Multiplier -- Damage taken bonus from buffs, debuffs, and other sources

	local originStats = CharService.GetCharacterCombatData(origin) :: _TYPES.CharacterCombatData
	local targetStats = CharService.GetCharacterCombatData(target) :: _TYPES.CharacterCombatData

	-- 1. Calculate base dmg
	-- Loop through each scaling type and apply the scaling to the character's stats
	local moveScalings = scalings
	local baseDmg = 0

	-- Loop through each stat type (baseStats, realStats, currentStats)
	-- Within that loop, loop through each stat name and scaling multiplier
	-- For example:
	-- moveScalings = {
	-- 		realStats = { atk = 1.5, def = 0.5 },
	-- 		currentStats = { hp = 0.2 },
	-- }
	-- The base damage would be calculated as:
	-- baseDmg = (originStats.realStats.atk * 1.5) + (originStats.realStats.def * 0.5) + (originStats.currentStats.hp * 0.2)
	for statType in pairs(moveScalings) do
		for statName, scaling in pairs(moveScalings[statType]) do
			if not originStats[statType] or not originStats[statType][statName] then
				warn(
					"Invalid stat type or name for scaling: "
						.. tostring(statType)
						.. "."
						.. tostring(statName)
						.. " for move "
						.. moveName
				)
				continue
			end
			baseDmg += originStats[statType][statName] * scaling
		end
	end

	-- 2. Include DMG% Multiplier
	local dmgPercentMult = originStats.realStats.dmgDealtMult / 100

	-- 3. Decides if this hit should be a crit hit
	local critRate = originStats.realStats.critRate / 100
	local randomValue = math.random()
	local isCrit = randomValue < critRate
	if isCrit then
		local critDmgMult = originStats.realStats.critDmg / 100
		baseDmg *= critDmgMult
		LogService:Output("Critical hit! Damage multiplied by " .. critDmgMult)
	end

	-- 4. Include DEF Multiplier
	local defMult = 1 -- Placeholder for future implementation

	-- 5. Include DMG Taken Multiplier
	local dmgTakenMult = targetStats.realStats.dmgTakenMult / 100

	-- 6. Calculate final damage for each target
	local finalDmg = baseDmg * dmgPercentMult * defMult * dmgTakenMult
	LogService:Output(
		"Calculated damage for move "
			.. moveName
			.. ": "
			.. finalDmg
			.. " (Base: "
			.. baseDmg
			.. ", DMG% Mult: "
			.. dmgPercentMult
			.. ", DEF Mult: "
			.. defMult
			.. ", Crit DMG: "
			.. (isCrit and originStats.realStats.critDmg / 100 or 1)
			.. ", DMG Taken Mult: "
			.. dmgTakenMult
			.. ")"
	)

	return finalDmg, isCrit
end
