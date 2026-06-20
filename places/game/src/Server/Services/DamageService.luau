local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)

local DamageService = {}

--- Called when the server starts
function DamageService.OnStart() end

--- Deals damage to a target character based on the origin character and the damage amount
--- @within DamageService
--- @param origin - The character dealing the damage
--- @param target - The character receiving the damage
--- @param damage - The amount of damage to deal
function DamageService.Damage(origin: _TYPES.Character, target: _TYPES.Character, damage: number)
	-- Get the target's current HP
	local targetCombatData = CharService.GetCurrentCharacterStat(target, "hp")

	local newHP = targetCombatData - damage
	-- If the target hp goes down to 0 or below, set it to 0 and handle the character's death
	if newHP <= 0 then
		-- Destroy the target character and handle death logic
		target:Destroy()
	else
		-- Otherwise, subtract the damage from the target's current HP
		CharService.UpdateCurrentCharacterStat(target, "hp", newHP)
	end
end

--- Heals a target character based on the origin character and the heal amount
--- @within DamageService
--- @param origin - The character initiating the heal
--- @param target - The character receiving the heal
--- @param healAmount - The amount of heal to apply
function DamageService.Heal(origin: _TYPES.Character, target: _TYPES.Character, healAmount: number)
	-- Get the target's current HP
	local targetCombatData = CharService.GetCurrentCharacterStat(target, "hp")
	local targetMaxHP = CharService.GetRealCharacterStat(target, "hp")

	local newHP = targetCombatData + healAmount
	warn(target, newHP, targetMaxHP)
	-- If the target hp goes above max HP, set it to max HP
	if newHP >= targetMaxHP then
		CharService.UpdateCurrentCharacterStat(target, "hp", targetMaxHP)
	else
		-- Otherwise, add the heal amount to the target's current HP
		CharService.UpdateCurrentCharacterStat(target, "hp", newHP)
	end
end

return DamageService
