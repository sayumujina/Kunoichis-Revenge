local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

--- Determines the targets for a move based on the move's target selection type and the primary target index.
--- @within Modules
--- @param char - The character executing the move
--- @param primaryTargetIndex - The index of the primary target for the move
--- @param moveName - The name of the move being executed
--- @return { _TYPES.Character } - A list of characters that are the targets of the move
return function(char: _TYPES.Character, primaryTargetIndex: number, moveName: string)
	local targetsList

	-- Get the selected side for the move
	local moveData = Utility.GetCharacterMoveList(char)[moveName]
	local side = moveData.selectedSide

	-- Retrieve the folder containing the targets to look for
	if side == "Playable" then
		targetsList = workspace.Characters.Playable
	else
		targetsList = workspace.Characters.NPC
	end

	local targetSelectionType = moveData.targetSelectionType

	return Utility.DetermineTargetList(targetSelectionType, primaryTargetIndex, targetsList)
end
