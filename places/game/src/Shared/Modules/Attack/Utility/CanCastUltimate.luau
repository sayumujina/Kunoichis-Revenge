local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
--
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local PlayerService = require(Services.PlayerService)
--
local Zap = require(Services.Parent.zap)

return function(char: _TYPES.Character)
	-- Get the character's combat data
	local combatData = CharService.GetCharacterCombatData(char)
	local hasEnoughEnergy = false

	-- Check if the character has full energy
	if combatData and combatData.baseStats.energy and combatData.currentStats.energy then
		hasEnoughEnergy = combatData.currentStats.energy >= combatData.baseStats.energy
	end

	-- Fire a warning to the player if they don't have enough energy
	if not hasEnoughEnergy then
		local player = PlayerService.GetPlayerFromCharacter(char)
		warn("Player does not have enough energy to cast ultimate.")
		Zap.Warning.Fire(player :: _TYPES.RobloxPlayerType, {
			success = false,
			message = "Insufficient energy",
		})
	end

	return hasEnoughEnergy
end
