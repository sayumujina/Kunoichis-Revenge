local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local StatusService = require(Services.StatusService)
local EventService = require(Services.EventService)
-- Helpers
local Helpers = Services.DamageService.Helper
local CollapseTarget = require(Helpers.CollapseTarget)

local DamageService = {}

--- Called when the server starts
function DamageService.OnStart() end

--- Deals damage to a target character based on the origin character and the damage amount
--- @within DamageService
--- @param origin - The character dealing the damage
--- @param target - The character receiving the damage
--- @param damage - The amount of damage to deal
--- @param isCrit - Whether the damage is a critical hit
function DamageService.Damage(origin: _TYPES.Character, target: _TYPES.Character, damage: number, isCrit: boolean)
	-- Get the target's current HP and shield
	local targetHP = CharService.GetCurrentCharacterStat(target, "hp")
	local targetShield = CharService.GetCurrentCharacterStat(target, "shield")

	warn(
		"DamageService.Damage called with origin: "
			.. tostring(origin)
			.. ", target: "
			.. tostring(target)
			.. ", damage: "
			.. tostring(damage)
			.. ", targetHP: "
			.. tostring(targetHP)
			.. ", targetShield: "
			.. tostring(targetShield)
	)

	-- Deduct the damage from the shield first, if any
	local remainingDamage = damage
	if targetShield > 0 then
		if targetShield >= remainingDamage then
			-- If the shield can absorb all the damage, just reduce the shield
			CharService.UpdateCurrentCharacterStat(target, "shield", targetShield - remainingDamage)
			remainingDamage = 0
		else
			-- If the shield can't absorb all the damage, reduce the shield to 0 and calculate remaining damage
			remainingDamage -= targetShield
			CharService.UpdateCurrentCharacterStat(target, "shield", 0)
		end
	end

	-- If the target hp goes down to 0 or below, set it to 0 and handle the character's death
	local newHP = targetHP - remainingDamage
	if newHP <= 0 then
		-- Destroy the target character and handle death logic
		target:Destroy()

		-- Fire the death event with the target and origin characters
		EventService.Events.Death:Fire({
			char = target,
			origin = origin,
		})
	else
		-- Otherwise, subtract the damage from the target's current HP
		CharService.UpdateCurrentCharacterStat(target, "hp", newHP)
	end

	-- Fire the damage event with the target, origin, and damage amount
	EventService.Events.Damage:Fire({
		origin = origin,
		data = {
			target = target,
			damage = damage,
			isCrit = isCrit,
		},
	})
end

--- Deals exposure damage to a target character based on the origin character and the exposure amount
--- Exposures only exist for NPC characters
--- @within DamageService
--- @param origin - The character dealing the exposure damage
--- @param target - The character receiving the exposure damage
--- @param exposure - The amount of exposure damage to deal
function DamageService.DealExposure(origin: _TYPES.Character, target: _TYPES.Character, exposure: number)
	-- Ignore if the target character is not an NPC
	if target:GetAttribute("Side") ~= "NPC" then
		return
	end

	-- Ignore if the target is already collapsed
	if StatusService.GetStatusById(target, "Collapsed") then
		return
	end

	-- Get the target's current and max exposure
	local targetMaxExposure = CharService.GetRealCharacterStat(target, "exposure")
	local targetCurrentExposure = CharService.GetCurrentCharacterStat(target, "exposure")

	local newExposure = targetCurrentExposure + exposure
	-- If the target's exposure goes up to the max exposure or above, set it to 0 and handle the character's collapsed state
	if newExposure >= targetMaxExposure then
		-- Collapse the target character
		CollapseTarget(target)

		-- Reset the target's current exposure to 0
		CharService.UpdateCurrentCharacterStat(target, "exposure", 0)
	else
		-- Otherwise, add the exposure to the target's current exposure
		CharService.UpdateCurrentCharacterStat(target, "exposure", newExposure)
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
	-- If the target hp goes above max HP, set it to max HP
	if newHP >= targetMaxHP then
		CharService.UpdateCurrentCharacterStat(target, "hp", targetMaxHP)
	else
		-- Otherwise, add the heal amount to the target's current HP
		CharService.UpdateCurrentCharacterStat(target, "hp", newHP)
	end
end

return DamageService
