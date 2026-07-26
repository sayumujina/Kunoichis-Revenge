local _TYPES = require(game.ReplicatedStorage.Data.data_Types)
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

	local oldEnergy = originCombatData.currentStats.energy
	-- If energy is already full, we don't need to do anything
	if oldEnergy >= originCombatData.baseStats.energy then
		return
	end

	local finalisedEnergy
	-- If the gain is fixed, we add the flat amount, otherwise we calculate it based on the character's stats
	if fixedGain then
		finalisedEnergy = math.clamp(oldEnergy + amount, 0, originCombatData.baseStats.energy)
	else
		local energyGain = amount * (originCombatData.realStats.ultimateGainEfficiency / 100)
		finalisedEnergy = math.clamp(oldEnergy + energyGain, 0, originCombatData.baseStats.energy)
	end

	-- If energy is full, play the energy full sound
	if finalisedEnergy == originCombatData.baseStats.energy then
		Zap.RequestPlaySound.Fire(
			PlayerService.GetPlayerFromCharacter(energyReceiver) :: _TYPES.RobloxPlayerType,
			"Sound_UltimateCharged"
		)
	end

	-- Update the character's energy
	CharService.UpdateCurrentCharacterStat(energyReceiver, "energy", finalisedEnergy)
end
