local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

return function(char: _TYPES.Character, primaryTargetIndex: number, moveName: string)
	local targets = {} :: { _TYPES.Character }
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
	local findChar = Utility.FindCharacterWithIndex

	-- Determine the indexes first
	if targetSelectionType == "Single" then -- Select a single target.
		warn("Primary target index:", primaryTargetIndex)
		table.insert(targets, findChar(primaryTargetIndex, targetsList) :: _TYPES.Character)
	elseif targetSelectionType == "Blast" then -- Select a main target and 2 targets around them (if they exist).
		-- Insert the primary target first
		table.insert(targets, findChar(primaryTargetIndex, targetsList) :: _TYPES.Character)

		-- Find adjacent targets
		local charOnTheLeft = findChar(primaryTargetIndex - 1, targetsList)
		if charOnTheLeft then
			table.insert(targets, charOnTheLeft)
		end

		local charOnTheRight = findChar(primaryTargetIndex + 1, targetsList)
		if charOnTheRight then
			table.insert(targets, charOnTheRight)
		end
	elseif targetSelectionType == "AoE" then -- Select all targets on the field.
		targets = targetsList:GetChildren()
	end

	return targets
end
