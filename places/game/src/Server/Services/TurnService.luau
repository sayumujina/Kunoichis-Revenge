local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local CharService = require(script.Parent.CharService)
local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
--
local Services = game:GetService("ServerScriptService").Server.Services
local Zap = require(Services.Parent.zap)

-- Constants
local BASE_ACTION_VALUE = 10000

--- @class TurnService
--- @server
--- @tag Service
local TurnService = {}

-- Turn queue stores characters and their action values
-- Each character gets 2 entries for upcoming turns
type TurnEntry = {
	char: _TYPES.Character,
	actionValue: number,
}

local turnQueue: { TurnEntry } = {}
local activeCharacters: { _TYPES.Character } = {}

--- Helper function to sort the turn queue by action value
--- @param queue -- The turn queue to sort
local function sortTurnQueue(queue: { TurnEntry })
	table.sort(queue, function(a, b)
		return a.actionValue < b.actionValue
	end)
end

--- Helper function to calculolate action value based on character speed (lower is faster)
--- @param char -- The character to calculate the action value for
local function calculateActionValue(char: _TYPES.Character): number
	local charSpd = CharService.GetCharacterStat(char, "spd")
	return BASE_ACTION_VALUE / charSpd
end

--- Called when the service starts
function TurnService.OnStart()
	-- Initialise an empty turn system
	turnQueue = {}
	activeCharacters = {}

	-- For testing, add all characters in the workspace to the turn system
	task.delay(3, function()
		for _, char in pairs(workspace.Characters:GetDescendants()) do
			if char:IsA("Model") and char:FindFirstChildOfClass("Humanoid") then
				TurnService.AddActiveCharacter(char)
			end
		end

		warn("TurnService started with " .. tostring(#activeCharacters) .. " active characters.")
		warn(turnQueue)
	end)

	Zap.AdvanceToNextTurn.On(function()
		TurnService.MoveToNextTurn()
		warn("Advanced to next turn. Current turn queue:")
		warn(turnQueue)
	end)
end

--- Add a character to the turn system
--- @param char -- _TYPES.Character
function TurnService.AddActiveCharacter(char: _TYPES.Character)
	-- Only add if not already in the active characters list
	if table.find(activeCharacters, char) then
		return
	end

	table.insert(activeCharacters, char)

	-- Add 2 turns for this character to the queue
	local actionValue = calculateActionValue(char)
	table.insert(turnQueue, {
		char = char,
		actionValue = actionValue,
	})
	table.insert(turnQueue, {
		char = char,
		actionValue = actionValue * 2,
	})

	-- Re-sort the turn queue with the new character
	sortTurnQueue(turnQueue)
end

--- Remove a character from the turn system
--- @param char -- _TYPES.Character
function TurnService.RemoveActiveCharacter(char: _TYPES.Character)
	-- Remove from active characters
	local index = table.find(activeCharacters, char)
	if index then
		table.remove(activeCharacters, index)
	end

	-- Re-sort the turn queue after removal
	sortTurnQueue(turnQueue)
end

--- Get the current turn data
function TurnService.GetCurrentTurn(): TurnEntry?
	if #turnQueue == 0 then
		return nil
	end

	local currentEntry = turnQueue[1]
	return currentEntry
end

--- Advance to the next turn
function TurnService.MoveToNextTurn()
	if #turnQueue == 0 then
		return
	end

	-- Remove the current turn from the queue
	local completedTurn = table.remove(turnQueue, 1)

	if not completedTurn then
		return
	end

	-- Subtract all action values by the completed turn's action value to normalise the queue
	for _, entry in ipairs(turnQueue) do
		entry.actionValue = entry.actionValue - completedTurn.actionValue
	end

	-- Check if this character is still active
	if table.find(activeCharacters, completedTurn.char) then
		-- Calculate next turn for this character
		local nextActionValue = calculateActionValue(completedTurn.char)

		-- Find the base action value to add to (highest current action value for proper sequencing)
		local baseActionValue = 0
		for _, entry in ipairs(turnQueue) do
			baseActionValue = math.max(baseActionValue, entry.actionValue)
		end

		-- Add the new turn to the queue
		table.insert(turnQueue, {
			char = completedTurn.char,
			actionValue = baseActionValue + nextActionValue,
		})

		-- Re-sort the turn queue
		sortTurnQueue(turnQueue)
	end
end

--- Modifies a character's action value (in case of action delay/ advance)
--- @param char -- The character to modify
--- @param newActionValue -- The new action value to set for the character's next turn
function TurnService.ModifyCharacterActionValue(char: _TYPES.Character, newActionValue: number)
	-- Only update one single turn entry (the one with the lowest action value)
	for _, entry in pairs(turnQueue) do
		if entry.char :: any == char then
			entry.actionValue = newActionValue
			break
		end
	end

	-- Re-sort the turn queue after modification
	sortTurnQueue(turnQueue)
end

--- Get the turn order preview
function TurnService.GetTurnQueue(): { TurnEntry }
	return turnQueue
end

--- Start the turn
function TurnService.StartTurn() end

--- Check if there are any active characters
function TurnService.HasActiveCharacters(): boolean
	return #activeCharacters > 0
end

--- Get all active characters
function TurnService.GetActiveCharacters(): { _TYPES.Character }
	return activeCharacters
end

return TurnService
