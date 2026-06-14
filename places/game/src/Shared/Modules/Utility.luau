local rep = game.ReplicatedStorage
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
--
local _TYPES = require(rep.Shared.data_Types)
local TableUtil = require(rep.Packages.TableUtil)

local Utility = {}

--- Sort the turn queue by action value
--- @param queue -- The turn queue to sort
function Utility.SortTurnQueue(queue: { _TYPES.TurnEntry })
	table.sort(queue, function(a, b)
		return a.actionValue < b.actionValue
	end)
end

--- Normalise the turn queue after a turn is completed
--- This makes sure the action on top is always at 0 action value
--- @param queue -- The turn queue to normalise
--- @return The normalised turn queue
function Utility.NormaliseTurnQueue(queue: { _TYPES.TurnEntry })
	-- Deep copy the queue to avoid mutating the original
	if #queue == 0 then
		return
	end

	local normalisedQueue = TableUtil.Copy(queue, true)

	local topActionValue = normalisedQueue[1].actionValue
	for _, entry in pairs(normalisedQueue) do
		entry.actionValue = entry.actionValue - topActionValue
	end

	return normalisedQueue
end

--- Get the combat controller module for a character
--- @param char -- The character to get the combat controller for
function Utility.GetCharacterCombatController(char: _TYPES.Character): any
	local combatControllerModuleName = char.Name .. "_CombatController"
	if not combatControllerModuleName then
		warn("Character", char.Name, "does not have a CombatController module")
		return nil
	end

	local combatControllerModule =
		StarterPlayerScripts.Client.Controllers.Characters[char.Name]:FindFirstChild(combatControllerModuleName)
	if not combatControllerModule then
		warn("CombatController module", combatControllerModuleName, "not found for character", char.Name)
		return nil
	end

	return combatControllerModule
end

--- Get the move list for a character
--- @param char -- The character to get the move list for
function Utility.GetCharacterMoveList(char: _TYPES.Character): any
	local dataFolder = rep.Shared.Data.Characters[char:GetAttribute("Side")]:FindFirstChild(char.Name)
	local charMoveList = dataFolder and require(dataFolder:FindFirstChild("data_" .. char.Name .. "_Moves")) :: any

	return charMoveList
end

return Utility
