local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local _TYPES_CHAR = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Types)
-- Modules
local ExecuteMove = require(rep.Shared.Modules.Attack.ExecuteMove)

local moveName = "ArcherysVision"
-- Info
local moveInfo = require(rep.Data.Characters.Playable.Hayumi.data_Hayumi_Moves)[moveName]

return function(char: _TYPES.Character, data: _TYPES_CHAR.ServerCharData)
	local selectedTarget = data.Info.archerysVisionTarget
	local target = if selectedTarget and selectedTarget:FindFirstChild("Humanoid") then selectedTarget else nil

	local attackData = {
		primaryTargetIndex = if target then target:GetAttribute("Index") else nil,
		manaChange = moveInfo.manaChange,
		targets = if target then { target } else nil,
		attacks = moveInfo.attacks,
		info = moveInfo.info,
	} :: _TYPES.AttackData

	if ExecuteMove(char, moveInfo.selectedSide, moveName, attackData, true) then
		-- Reset the archery's vision target after executing the move
		data.Info.archerysVisionUseCount -= 1
		data.Info.archerysVisionTarget = nil
		return true
	else
		return false
	end
end
