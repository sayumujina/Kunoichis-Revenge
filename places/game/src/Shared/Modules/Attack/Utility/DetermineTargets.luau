local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

-- A table to map move categories to their corresponding target sides
local teamEffectMoveCategories = { "Heal", "Shield", "Buff" }

return function(char: _TYPES.Character, attackData: _TYPES.AttackData, moveName: string)
	local targets = {} :: { _TYPES.Character }
	local side = char:GetAttribute("Side")
	local targetsList
	-- Depends on the side and move category, retrieve the appropriate folder
	if side == "Allies" then
		if table.find(teamEffectMoveCategories, attackData.moveCategory) then
			targetsList = game.Workspace.Characters.Allies
		else
			targetsList = game.Workspace.Characters.Enemies
		end
	else
		if table.find(teamEffectMoveCategories, attackData.moveCategory) then
			targetsList = game.Workspace.Characters.Enemies
		else
			targetsList = game.Workspace.Characters.Allies
		end
	end

	local moveData = Utility.GetCharacterMoveList(char)[moveName]
	local targetSelectionType = moveData.targetSelectionType
	local findChar = Utility.FindCharacterWithIndex

	-- Determine the indexes first
	if targetSelectionType == "Single" then -- Select a single target.
		table.insert(targets, findChar(attackData.primaryTargetIndex, targetsList) :: _TYPES.Character)
	elseif targetSelectionType == "Blast" then -- Select a main target and 2 targets around them (if they exist).
		-- Insert the primary target first
		table.insert(targets, findChar(attackData.primaryTargetIndex, targetsList) :: _TYPES.Character)

		-- Find adjacent targets
		local charOnTheLeft = findChar(attackData.primaryTargetIndex - 1, targetsList)
		if charOnTheLeft then
			table.insert(targets, charOnTheLeft)
		end

		local charOnTheRight = findChar(attackData.primaryTargetIndex + 1, targetsList)
		if charOnTheRight then
			table.insert(targets, charOnTheRight)
		end
	elseif targetSelectionType == "AoE" then -- Select all targets on the field.
		targets = targetsList:GetChildren()
	end

	return targets
end
