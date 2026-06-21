local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

-- A table to map move categories to their corresponding target sides
local teamEffectMoveCategories = { "Heal", "Shield", "Buff" }

-- Helper function to find a character in the workspace based on the provided index
local function findCharacterWithIndex(indexToFind: number, folder: Folder): _TYPES.Character?
	-- Loop through the children of the folder to find the character with the matching index
	for _, child in pairs(folder:GetChildren()) do
		local charIndex = child:GetAttribute("Index")
		warn(charIndex, indexToFind)
		if charIndex and charIndex == indexToFind then
			return child :: _TYPES.Character
		end
	end

	return nil
end

return function(attackData: _TYPES.AttackData, moveName: string)
	local targets = {} :: { _TYPES.Character }
	local side = attackData.origin:GetAttribute("Side")
	local targetsInWorkspace
	-- Depends on the side and move category, retrieve the appropriate folder
	if side == "Allies" then
		if table.find(teamEffectMoveCategories, attackData.moveCategory) then
			targetsInWorkspace = game.Workspace.Characters.Allies
		else
			targetsInWorkspace = game.Workspace.Characters.Enemies
		end
	else
		if table.find(teamEffectMoveCategories, attackData.moveCategory) then
			targetsInWorkspace = game.Workspace.Characters.Enemies
		else
			targetsInWorkspace = game.Workspace.Characters.Allies
		end
	end

	local moveData = Utility.GetCharacterMoveList(attackData.origin :: _TYPES.Character)[moveName]
	local targetSelectionType = moveData.targetSelectionType

	-- Determine the indexes first
	if targetSelectionType == "Single" then -- Select a single target.
		table.insert(
			targets,
			findCharacterWithIndex(attackData.primaryTargetIndex, targetsInWorkspace) :: _TYPES.Character
		)
	elseif targetSelectionType == "Blast" then -- Select a main target and 2 targets around them (if they exist).
		-- Insert the primary target first
		table.insert(
			targets,
			findCharacterWithIndex(attackData.primaryTargetIndex, targetsInWorkspace) :: _TYPES.Character
		)

		-- Check if the primary target has adjacent targets and add them to the targets list
		if attackData.primaryTargetIndex - 1 > 0 then
			table.insert(
				targets,
				findCharacterWithIndex(attackData.primaryTargetIndex - 1, targetsInWorkspace) :: _TYPES.Character
			)
		end
		if attackData.primaryTargetIndex + 1 <= #targetsInWorkspace:GetChildren() then
			table.insert(
				targets,
				findCharacterWithIndex(attackData.primaryTargetIndex + 1, targetsInWorkspace) :: _TYPES.Character
			)
		end
	elseif targetSelectionType == "AoE" then -- Select all targets on the field.
		targets = targetsInWorkspace:GetChildren()
	end

	return targets
end
