local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local TurnService = require(Services.TurnService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "VanguardsCall"
-- Info
local moveInfo = require(rep.Shared.Data.Characters.Playable.Rin.data_Rin_Moves)[moveName]
-- Combat info
local combatInfo = require(rep.Shared.Data.Characters.Playable.Rin.data_Rin_CombatInfo)

return function(char: _TYPES.Character, primaryTargetIndex: number)
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
		warn(
			"Advancing action value of buffed ally:",
			attackData.targets[1].Name,
			"by",
			combatInfo.ultimate.actionAdvanceAmount
		)
		TurnService.AdvanceAction(attackData.targets[1], combatInfo.ultimate.actionAdvanceAmount)
		return true
	end

	return false
end
