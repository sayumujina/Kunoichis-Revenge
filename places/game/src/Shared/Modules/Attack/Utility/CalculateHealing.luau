local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local LogService = game:GetService("LogService")

return function(attackData: _TYPES.AttackData, target: _TYPES.Character, moveName: string)
	-- Outgoing Healing =
	-- Base healing -- Character's scaled stats * skill scalings
	-- × Healing% multiplier -- Healing bonus from buffs, debuffs, and other sources
	-- × Healing received multiplier -- Target's healing received bonus from buffs, debuffs, and other sources
	-- × Healing Provided multiplier -- Origin's healing provided bonus from buffs, debuffs, and other sources

	local origin = attackData.origin
	local originStats = CharService.GetCharacterCombatData(origin) :: _TYPES.CharacterCombatData
	local targetStats = CharService.GetCharacterCombatData(target) :: _TYPES.CharacterCombatData

	-- 1. Calculate base healing
	-- Loop through each scaling type and apply the scaling to the character's stats
	local moveScalings = attackData.data.scalings
	local baseHealing = 0

	-- Loop through each stat type (baseStats, realStats, currentStats)
	-- Within that loop, loop through each stat name and scaling multiplier
	-- For example:
	-- moveScalings = {
	-- 		realStats = { atk = 1.5, def = 0.5 },
	-- 		currentStats = { hp = 0.2 },
	-- }
	-- The base healing would be calculated as:
	-- baseHealing = (originStats.realStats.atk * 1.5) + (originStats.realStats.def * 0.5) + (originStats.currentStats.hp * 0.2)
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
			baseHealing += originStats[statType][statName] * scaling
		end
	end

	-- 2. Include Healing% Multiplier
	local healingPercentMult = originStats.realStats.healingProvidedMult / 100

	-- 3. Include healing received multiplier
	local healingReceivedMult = targetStats.realStats.healingReceivedMult / 100

	-- 4. Include healing provided multiplier
	local healingProvidedMult = originStats.realStats.healingProvidedMult / 100

	-- Calculate final healing for each target
	local finalHealing = baseHealing * healingPercentMult * healingReceivedMult * healingProvidedMult
	LogService:Output(
		"Calculated healing for move "
			.. moveName
			.. ": "
			.. finalHealing
			.. " (Base: "
			.. baseHealing
			.. ", Healing% Mult: "
			.. healingPercentMult
			.. ", Healing Received Mult: "
			.. healingReceivedMult
			.. ", Healing Provided Mult: "
			.. healingProvidedMult
			.. ")"
	)
	return finalHealing
end
