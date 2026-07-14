local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "ArcherysVision"
-- Info
local moveInfo = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Moves)[moveName]

return function(char: _TYPES.Character, data: _TYPES_CHAR.ServerCharData)
	warn("Attempting to execute move: " .. moveName .. " for character: " .. char.Name)
	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local primaryTargetIndex = CombatService.GetCombatData(player).primarySelectedTargetIndex

	if not data.Info.archerysVisionTarget then
		warn("No target selected for Archery's Vision. Move cannot be executed.")
		return false
	end

	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		manaChange = moveInfo.manaChange,
		targets = data.Info.archerysVisionTarget and { data.Info.archerysVisionTarget } or {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	if ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, true) then
		-- Reset the archery's vision target after executing the move
		data.Info.archerysVisionUseCount -= 1
		data.Info.archerysVisionTarget = nil
		return true
	else
		warn("Failed to execute move: " .. moveName)
		return false
	end
end
