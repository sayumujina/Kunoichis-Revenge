local rep = game.ReplicatedStorage
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
return Utility
