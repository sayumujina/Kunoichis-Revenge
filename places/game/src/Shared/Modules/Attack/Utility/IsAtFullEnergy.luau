local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
--
local CharService = require(game:GetService("ServerScriptService").Server.Services.CharService)

return function(char: _TYPES.Character)
	-- Get the character's combat data
	local combatData = CharService.GetCharacterCombatData(char)

	-- Check if the character has full energy
	if combatData and combatData.baseStats.energy and combatData.currentStats.energy then
		return combatData.currentStats.energy >= combatData.baseStats.energy
	end

	return false
end
