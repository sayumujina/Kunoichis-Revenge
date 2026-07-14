local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
--
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local CharService = require(Services.CharService)
local EventService = require(Services.EventService)
--
local CalculateShield = require(script.Parent.CalculateShield)

return function(data, char: _TYPES.Character, target: _TYPES.Character, moveName: string)
	local shieldAmount = CalculateShield(data.scalings, char, target, moveName)

	local currentShieldValue = CharService.GetCharacterStat(target, "currentStats", "shield")
	local newShieldValue = currentShieldValue + shieldAmount
	CharService.UpdateCurrentCharacterStat(target, "shield", newShieldValue)

	-- Fire the shield provided event
	EventService.Events.ShieldProvided:Fire({
		origin = char,
		data = { target = target, shieldAmount = newShieldValue },
	})
end
