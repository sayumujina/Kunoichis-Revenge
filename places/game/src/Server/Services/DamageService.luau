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
--- @param origin _TYPES.Character The character dealing the damage
--- @param target _TYPES.Character The character receiving the damage
--- @param damage number The amount of damage to deal
function DamageService.Damage(origin: _TYPES.Character, target: _TYPES.Character, damage: number)
	-- Get the target's current HP
	local targetCombatData = CharService.GetRealCharacterStat(target, "hp")

	local newHP = targetCombatData - damage
	-- If the target hp goes down to 0 or below, set it to 0 and handle the character's death
	if newHP <= 0 then
		-- Destroy the target character and handle death logic
		target:Destroy()
	else
		-- Otherwise, subtract the damage from the target's current HP
		CharService.UpdateRealCharacterStat(target, "hp", newHP)
	end
end

return DamageService
