local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local _TYPES_CHAR = require(rep.Shared.Data.Characters.Playable.Rin.data_Rin_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local TurnService = require(Services.TurnService)
local CombatService = require(Services.CombatService)
local PlayerService = require(Services.PlayerService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)
-- Utility
local CanCastUltimate = require(rep.Shared.Modules.Attack.Utility.CanCastUltimate)
-- Packages
local Zap = require(Services.Parent.zap)

local moveName = "DestructiveCriticism"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Playable.Tsuyoka.data_Tsuyoka_Moves)[moveName]
-- Combat info
local combatInfo = require(rep.Shared.Data.Characters.Playable.Tsuyoka.data_Tsuyoka_CombatInfo)

return function(char: _TYPES.Character, data: _TYPES_CHAR.ServerCharData)
	-- Check if Tsuyoka can cast her ultimate before proceeding
	if not CanCastUltimate(char) then
		warn("Tsuyoka's energy is not full. Cannot execute ultimate.")
		return false
	end

	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local primaryTargetIndex = CombatService.GetCombatData(player).primarySelectedTargetIndex

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
		-- Advance the action value of the buffed ally
		TurnService.AdvanceAction(attackData.targets[1], combatInfo.ultimate.actionAdvanceAmount)
		return true
	end

	return false
end
