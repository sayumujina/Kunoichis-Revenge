local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "BasicAttack"
-- Info
local moveInfo = require(rep.Data.Characters.NPC.Red_MockEnemy.data_Red_MockEnemy_Moves)[moveName]

return function(char: _TYPES.Character)
	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local primaryTargetIndex = CombatService.GetCombatData(player).selectedPlayableIndex

	local attackData = {
		primaryTargetIndex = primaryTargetIndex,
		manaChange = moveInfo.manaChange,
		targets = {},
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	return ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, false)
end
