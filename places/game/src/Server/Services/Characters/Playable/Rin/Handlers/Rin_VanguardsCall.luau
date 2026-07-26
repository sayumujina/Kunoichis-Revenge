local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Rin.data_Rin_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local TurnService = require(Services.TurnService)
local CombatService = require(Services.CombatService)
local PlayerService = require(Services.PlayerService)
local StatusService = require(Services.StatusService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)
-- Utility
local CanCastUltimate = require(rep.Shared.Modules.Attack.Utility.CanCastUltimate)
local Utility = require(rep.Shared.Modules.Utility)
-- Packages
local Zap = require(Services.Parent.zap)

local moveName = "VanguardsCall"
-- Info
local moveInfo = require(rep.Data.Characters.Playable.Rin.data_Rin_Moves)[moveName]
-- Combat info
local combatInfo = require(rep.Data.Characters.Playable.Rin.data_Rin_CombatInfo)

-- Status
local status = {
	statusType = { "StatModification" } :: { _TYPES.StatusTypes },
	--
	info = {
		name = "Vanguard's Call",
		description = "Boosts attack by " .. combatInfo.ultimate.atkBoost * 100 .. "% for 1 turn.",
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
			value = combatInfo.ultimate.atkBoost, -- Boost attack
		},
	} :: { _TYPES.StatChangeTypes },
} :: _TYPES.Status

return function(char: _TYPES.Character, data: _TYPES_CHAR.ServerCharData)
	-- Check if Rin's energy is full
	if not CanCastUltimate(char) then
		warn("Rin's energy is not full. Cannot execute ultimate.")
		return false
	end

	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local primaryTargetIndex = CombatService.GetCombatData(player).selectedPlayableIndex

	-- Set energy to 0 after executing the ultimate
	CharService.UpdateCurrentCharacterStat(char, "energy", 0)

	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	if ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, true) then
		-- Advance the action value of the buffed ally
		TurnService.AdvanceAction(attackData.targets[1], combatInfo.ultimate.actionAdvanceAmount)

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

		data.Trove:Add(currentAnimationTrack:GetMarkerReachedSignal("heal"):Connect(function(count)
			-- At the weaken marker, apply the debuff to all targets
			if count ~= "buff" then
				return
			end

			for _, target in pairs(attackData.targets) do
				StatusService.AddStatus(target, "Rin_VanguardsCall", status)
			end
		end))
		return true
	end

	return false
end
