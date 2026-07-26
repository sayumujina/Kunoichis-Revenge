local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)
-- Packages
local Zap = require(Services.Parent.zap)

local moveName = "LightningRain"
-- Info
local moveInfo = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Moves)[moveName]
local combatInfo = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_CombatInfo).archerysVision

return function(char: _TYPES.Character, data: _TYPES_CHAR.ServerCharData)
	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local primaryTargetIndex = CombatService.GetCombatData(player).selectedNPCIndex

	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		manaChange = moveInfo.manaChange,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	if ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, false) then
		-- If move ended up successful, play the move success sound
		Zap.RequestPlaySound.Fire(player :: _TYPES.RobloxPlayerType, "Sound_MoveSuccessful")

		-- Gain one use of Archery's Vision after executing Lightning Rain
		data.Info.archerysVisionUseCount =
			math.min(data.Info.archerysVisionUseCount + combatInfo.useCountGainPerMove, combatInfo.maxUseCount)
		return true
	else
		warn("Failed to execute move: " .. moveName)
		return false
	end
end
