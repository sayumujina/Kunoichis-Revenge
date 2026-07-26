local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
local StatusService = require(Services.StatusService)
local CharService = require(Services.CharService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
local moveName = "WeakenFromAfar"
-- Info
local moveInfo = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Moves)[moveName]
local combatInfo = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_CombatInfo)

-- Weakened status
local weakenedStatus = {
	statusType = { "StatModification" } :: { _TYPES.StatusTypes },
	--
	info = {
		name = "Weakened",
		description = "Reduces attack by " .. combatInfo.weakenFromAfar.atkReductionPercentage * 100 .. "% for 1 turn.",
	},
	--
	data = {
		duration = 1, -- Collapsed for 1 turn
		expellable = true,
	},
	--
	statChanges = {
		{
			statChangeType = "Mult",
			statName = "atk",
			value = -combatInfo.weakenFromAfar.atkReductionPercentage, -- Deal reduced damage while weakened
		},
	} :: { _TYPES.StatChangeTypes },
} :: _TYPES.Status

return function(char: _TYPES.Character, data: _TYPES_CHAR.ServerCharData)
	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local primaryTargetIndex = CombatService.GetCombatData(player).selectedNPCIndex

	-- Set energy to 0 after executing the ultimate
	CharService.UpdateCurrentCharacterStat(char, "energy", 0)

	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		manaChange = moveInfo.manaChange,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	if ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, true) then
		-- Gain one use of Archery's Vision after executing Lightning Rain
		data.Info.archerysVisionUseCount = math.min(
			data.Info.archerysVisionUseCount + combatInfo.archerysVision.useCountGainPerMove,
			combatInfo.archerysVision.maxUseCount
		)

		-- Get the current playing animation track for the character
		local currentAnimationTrack
		for _, animationTrack in pairs(char.Humanoid.Animator:GetPlayingAnimationTracks()) do
			if
				Utility.GetPlayingAttackAnimationId(char, moveName .. "_Execute")
				== animationTrack.Animation.AnimationId
			then
				currentAnimationTrack = animationTrack
				break
			end
		end

		data.Trove:Add(currentAnimationTrack:GetMarkerReachedSignal("hit"):Connect(function(count)
			-- At the weaken marker, apply the debuff to all targets
			if count ~= "weaken" then
				return
			end

			for _, target in pairs(attackData.targets) do
				StatusService.AddStatus(target, "Hayumi_WeakenedFromAfar", weakenedStatus)
			end
		end))

		return true
	else
		warn("Failed to execute move: " .. moveName)
		return false
	end
end
