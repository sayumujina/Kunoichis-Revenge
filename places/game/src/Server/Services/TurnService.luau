local rep = game.ReplicatedStorage
local _TYPES = require(rep.Shared.data_Types)
--
local Services = game:GetService("ServerScriptService").Server.Services
local PlayerService = require(Services.PlayerService)
local CharService = require(script.Parent.CharService)
local EventService = require(script.Parent.EventService)
--
local Zap = require(Services.Parent.zap)
--
local Utility = require(rep.Shared.Modules.Utility)

-- Constants
local BASE_ACTION_VALUE = 10000
-- Variables
local currentTurnCount: number

--- @class TurnService
--- @server
--- @tag Service
local TurnService = {}

-- Turn queue stores characters and their action values
-- Each character gets 2 entries for upcoming turns

local turnQueue: { _TYPES.TurnEntry } = {}
local activeCharacters: { _TYPES.Character } = {}

--- Helper function to calculolate action value based on character speed (lower is faster)
--- @param char -- The character to calculate the action value for
local function calculateActionValue(char: _TYPES.Character): number
	local charSpd = CharService.GetBaseCharacterStat(char, "spd")
	return BASE_ACTION_VALUE / charSpd
end

--- Called when the service starts
function TurnService.OnStart()
	-- Initialise an empty turn system
	turnQueue = {}
	activeCharacters = {}
	currentTurnCount = 0

	-- Listens to spawn finished event to add the spawned character to the turn system
	-- This event is used ONCE per battle, to ensure that the battle is ready for proceeding
	EventService.Events.SpawnFinished:Connect(function()
		Utility.NormaliseTurnQueue(turnQueue)
		-- Do this at the end of the thread to make sure spawn finished reaches the client first
		task.defer(function()
			TurnService.StartTurn()
		end)
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

	-- Add 2 turns for this character to the queue and notify clients about the new turns
	local actionValue = calculateActionValue(char)

	-- Turn 1
	currentTurnCount = currentTurnCount + 1
	table.insert(turnQueue, {
		turnId = currentTurnCount,
		char = char,
		side = CharService.GetCharacterCombatData(char).side,
		actionValue = actionValue,
	})
	EventService.Events.TurnAdded:Fire({
		turnId = currentTurnCount,
		char = char,
		side = CharService.GetCharacterCombatData(char).side,
		actionValue = actionValue,
	})

	-- Turn 2
	currentTurnCount = currentTurnCount + 1
	table.insert(turnQueue, {
		turnId = currentTurnCount,
		char = char,
		side = CharService.GetCharacterCombatData(char).side,
		actionValue = actionValue * 2,
	})
	EventService.Events.TurnAdded:Fire({
		turnId = currentTurnCount,
		char = char,
		side = CharService.GetCharacterCombatData(char).side,
		actionValue = actionValue * 2,
	})

	-- Re-sort the turn queue with the new character
	Utility.SortTurnQueue(turnQueue)
end

--- Remove a character from the turn system
--- @param char -- _TYPES.Character
function TurnService.RemoveActiveCharacter(char: _TYPES.Character)
	-- Remove from active characters
	local index = table.find(activeCharacters, char)

	if index then
		table.remove(activeCharacters, index)

		-- Notify the client about the turn removal
		Zap.TurnRemovedForCharacter.Fire(PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType, {
			char = char,
			side = CharService.GetCharacterCombatData(char).side,
		})
	end

	-- Re-sort the turn queue after removal
	Utility.SortTurnQueue(turnQueue)
end

--- Get the current turn data
function TurnService.GetCurrentTurn(): _TYPES.TurnEntry?
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

	-- Notify the client about the turn completion
	Zap.TurnCompleted.Fire(PlayerService.GetPlayerFromCharacter(turnQueue[1].char) :: _TYPES.RobloxPlayerType, {
		turnId = turnQueue[1].turnId,
	})

	-- Remove the current turn from the queue
	local completedTurn = table.remove(turnQueue, 1)

	if not completedTurn then
		return -- bro there's no way this check ever fails cuz there's alraedy an empty table check earlier, I just don't want the Language server to yell
	end

	-- Check if this character is still active
	if table.find(activeCharacters, completedTurn.char) then
		-- Normalise the turn queue
		turnQueue = Utility.NormaliseTurnQueue(turnQueue)

		-- Add the new turn to the queue
		currentTurnCount = currentTurnCount + 1
		table.insert(turnQueue, {
			turnId = currentTurnCount,
			char = completedTurn.char,
			side = completedTurn.side,
			actionValue = calculateActionValue(completedTurn.char),
		})

		-- Re-sort the turn queue
		Utility.SortTurnQueue(turnQueue)

		-- Send update to clients about the new turn
		EventService.Events.TurnAdded:Fire({
			turnId = currentTurnCount,
			char = completedTurn.char,
			side = completedTurn.side,
			actionValue = calculateActionValue(completedTurn.char),
		})
	end

	-- Start the next turn
	TurnService.StartTurn()

	-- If the next character is an npc, execute its' attack after a short delay
	if turnQueue[1].side == "Enemies" then
		task.wait(1) --This is a placeholder, we will implement NPC attack delay and behaviour later
		EventService.Events.ExecuteNPCAttack:Fire({
			char = turnQueue[1].char,
		})
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
	Utility.SortTurnQueue(turnQueue)
end

--- Get the turn order preview
function TurnService.GetTurnQueue(): { _TYPES.TurnEntry }
	return turnQueue
end

--- Start the turn
function TurnService.StartTurn()
	-- If the turn belongs to the ally, set that as the active character value
	if turnQueue[1] and turnQueue[1].side == "Allies" then
		local player = PlayerService.GetPlayerFromCharacter(turnQueue[1].char)
		if player then
			player.ActiveCharacter.Value = turnQueue[1].char
		end
	end

	-- Send the turn started event to the client
	EventService.Events.TurnStarted:Fire({
		player = PlayerService.GetPlayerFromCharacter(turnQueue[1].char) :: _TYPES.RobloxPlayerType,
		data = {
			char = turnQueue[1].char,
			turnId = turnQueue[1].turnId,
		},
	})
end

--- Check if there are any active characters
function TurnService.HasActiveCharacters(): boolean
	return #activeCharacters > 0
end

--- Get all active characters
function TurnService.GetActiveCharacters(): { _TYPES.Character }
	return activeCharacters
end

return TurnService
