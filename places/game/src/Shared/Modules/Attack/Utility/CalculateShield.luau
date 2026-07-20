local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local LogService = game:GetService("LogService")

--- Calculates the final shield dealt by an attack based on the provided scalings, origin character, and target character.
--- @within Modules
--- @param scalings - The attack scalings to use for the shield calculation
--- @param origin - The character providing the shield
--- @param target - The character receiving the shield
--- @param moveName - The name of the move being executed (for logging purposes)
--- @return number - The final shield dealt
return function(scalings: _TYPES.AttackScalings, origin: _TYPES.Character, target: _TYPES.Character, moveName: string)
	-- Outgoing Shield =
	-- Base shield -- Character's scaled stats * skill scalings
	-- × Shield% multiplier -- Shield bonus from buffs, debuffs, and other sources
	-- × Shield received multiplier -- Target's shield received bonus from buffs, debuffs, and other sources
	-- × Shield Provided multiplier -- Origin's shield provided bonus from buffs, debuffs, and other sources

	local originStats = CharService.GetCharacterCombatData(origin) :: _TYPES.CharacterCombatData
	local targetStats = CharService.GetCharacterCombatData(target) :: _TYPES.CharacterCombatData

	-- 1. Calculate base shield
	-- Loop through each scaling type and apply the scaling to the character's stats
	local moveScalings = scalings
	local baseShield = 0

	-- Loop through each stat type (baseStats, realStats, currentStats)
	-- Within that loop, loop through each stat name and scaling multiplier
	-- For example:
	-- moveScalings = {
	-- 		realStats = { atk = 1.5, def = 0.5 },
	-- 		currentStats = { hp = 0.2 },
	-- }
	-- The base shield would be calculated as:
	-- baseShield = (originStats.realStats.atk * 1.5) + (originStats.realStats.def * 0.5) + (originStats.currentStats.hp * 0.2)
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
			baseShield += originStats[statType][statName] * scaling
		end
	end

	-- 2. Include Shield% Multiplier
	local shieldPercentMult = originStats.realStats.shieldProvidedMult / 100

	-- 3. Include shield received multiplier
	local shieldReceivedMult = targetStats.realStats.shieldReceivedMult / 100

	-- 4. Include shield provided multiplier
	local shieldProvidedMult = originStats.realStats.shieldProvidedMult / 100

	-- Calculate final shield for each target
	local finalShield = baseShield * shieldPercentMult * shieldReceivedMult * shieldProvidedMult

	return finalShield
end
