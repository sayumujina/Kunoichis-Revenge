local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local CharService = require(Services.CharService)
local PlayerService = require(Services.PlayerService)
local Zap = require(Services.Parent.zap)

--- Provides energy to targets based on the attack data
--- @within Modules
--- @param attackData -- The data for the attack to create
return function(energyReceiver: _TYPES.Character, amount: number, fixedGain: boolean)
	-- Get the origin combat data
	local originCombatData = CharService.GetCharacterCombatData(energyReceiver) :: _TYPES.CharacterCombatData
	if not originCombatData then
		warn("No combat data found for character: " .. energyReceiver.Name)
		return
	end

	local oldEnergy = originCombatData.realStats.currentEnergy
	local finalisedEnergy

	-- If the gain is fixed, we add the flat amount, otherwise we calculate it based on the character's stats
	if fixedGain then
		finalisedEnergy = math.clamp(oldEnergy + amount, 0, originCombatData.baseStats.maxEnergy)
	else
		local energyGain = amount * (originCombatData.realStats.ultimateGainEfficiency / 100)
		finalisedEnergy = math.clamp(oldEnergy + energyGain, 0, originCombatData.baseStats.maxEnergy)
	end

	-- Update the character's energy
	CharService.UpdateRealCharacterStat(energyReceiver, "currentEnergy", finalisedEnergy)

	-- Fire the energy changed event
	Zap.EnergyChanged.Fire(PlayerService.GetPlayerFromCharacter(energyReceiver) :: _TYPES.RobloxPlayerType, {
		char = energyReceiver,
		data = {
			oldEnergy = oldEnergy,
			newEnergy = finalisedEnergy,
		},
	})
end
