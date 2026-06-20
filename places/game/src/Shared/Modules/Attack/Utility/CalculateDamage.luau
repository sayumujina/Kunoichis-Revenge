local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local LogService = game:GetService("LogService")

return function(attackData: _TYPES.AttackData, moveName: string)
	-- Outgoing DMG =
	-- Base DMG -- Character's ATK stat * (skill multiplier / 100)
	-- × DMG% Multiplier -- Damage bonus from buffs, debuffs, and other sources
	-- × DEF Multiplier -- The higher the attacker level compared to defender level, the greater the DEF Multiplier
	-- 100% - [DEF / (DEF + 200 + 10 * Attacker Level)]
	-- × DMG Taken Multiplier -- Damage taken bonus from buffs, debuffs, and other sources

	local origin = attackData.origin

	-- 1. Calculate base dmg
	local charAtk = CharService.GetRealCharacterStat(origin, "atk")
	local moveMult = attackData.data.mult or 100
	local baseDmg = charAtk * (moveMult / 100)

	-- 2. Calculate DMG% Multiplier
	local dmgPercentMult = 1 -- Placeholder for future implementation

	-- 3. Calculate DEF Multiplier
	local defMult = 1 -- Placeholder for future implementation

	-- 4. Calculate DMG Taken Multiplier
	local dmgTakenMult = 1 -- Placeholder for future implementation

	-- Calculate final damage for each target
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
			.. ", DMG Taken Mult: "
			.. dmgTakenMult
			.. ")"
	)
	return finalDmg
end
