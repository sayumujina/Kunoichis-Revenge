local rep = game.ReplicatedStorage
local _TYPES = require(rep.Shared.data_Types)
--
local Services = game:GetService("ServerScriptService").Server.Services
local PlayerService = require(Services.PlayerService)
local CharService = require(script.Parent.CharService)
local EventService = require(script.Parent.EventService)
local CombatService = require(script.Parent.CombatService)
local StatusService = require(script.Parent.StatusService)
local AnimationService = require(script.Parent.AnimationService)
--
local Zap = require(Services.Parent.zap)
--
local Utility = require(rep.Shared.Modules.Utility)

-- Constants
local BASE_ACTION_VALUE = 10000

--- @class TurnService
--- @server
--- @tag Service
local TurnService = {}

local Players = {} :: {
	[_TYPES.RobloxPlayerType]: {
		turnQueue: { _TYPES.TurnEntry },
		currentTurnCount: number,
		currentTurn: _TYPES.TurnEntry?,
		--
		activeCharacters: { _TYPES.Character },
		previousTurn: _TYPES.TurnEntry?,
		--
		currentExtraActionCount: number,
		currentExtraAction: _TYPES.ExtraActionEntry?,
		extraActionQueue: { _TYPES.ExtraActionEntry },
	},
}

-- Helper function to calculolate action value based on character speed (lower is faster)
local function calculateActionValue(char: _TYPES.Character): number
	local charSpd = CharService.GetBaseCharacterStat(char, "spd")
	return BASE_ACTION_VALUE / charSpd
end

--- Helper function to add a turn to the queue
local function addTurnToQueue(char: _TYPES.Character, actionValue: number)
	local player = PlayerService.GetPlayerFromCharacter(char)
	if not player then
		warn("Player not found for character:", char.Name)
		return
	end

	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	playerData.currentTurnCount = playerData.currentTurnCount + 1

	local turnEntry: _TYPES.TurnEntry = {
		turnId = playerData.currentTurnCount,
		char = char,
		side = CharService.GetCharacterCombatData(char).side,
		actionValue = actionValue,
	}

	-- Add the new turn entry to the queue and send an event about the new turn
	table.insert(playerData.turnQueue, turnEntry)
	EventService.Events.TurnAdded:Fire(turnEntry)
end

-- Helper function to promote a turn to the top of its tie group in the queue
local function promoteTurnToTopOfTieGroup(
	player: _TYPES.RobloxPlayerType,
	entry: _TYPES.TurnEntry,
	queue: { _TYPES.TurnEntry }
)
	for sortedIndex, sortedEntry in ipairs(queue) do
		if sortedEntry.turnId ~= entry.turnId then
			continue
		end

		local tieStartIndex = sortedIndex
		while tieStartIndex > 1 and queue[tieStartIndex - 1].actionValue == sortedEntry.actionValue do
			-- If the action value is 0 when there's a current turn, it should not take over the current turn
			if
				sortedEntry.actionValue == 0
				and Players[player].currentTurn
				and queue[tieStartIndex - 1].turnId == Players[player].currentTurn.turnId
			then
				break
			end

			tieStartIndex -= 1
		end

		if tieStartIndex ~= sortedIndex then
			table.remove(queue, sortedIndex)
			table.insert(queue, tieStartIndex, sortedEntry)
		end

		break
	end
end

--- Called when the service starts
function TurnService.OnStart()
	-- Listens to spawn finished event to add the spawned character to the turn system
	-- This event is used ONCE per battle, to ensure that the battle is ready for proceeding
	EventService.Events.SpawnFinished:Connect(function(event)
		-- Initialize player data if it doesn't exist
		if not Players[event.player] then
			TurnService.InitialisePlayerEntry(event.player)
		end

		warn("Spawn finished event received for player:", event.player.Name)
		local playerData = Players[event.player]
		if not playerData then
			warn("Player data not found for player:", event.player.Name)
			return
		end

		-- Normalise the turn queue
		playerData.turnQueue = Utility.NormaliseTurnQueue(playerData.turnQueue)
		warn("Turn queue normalised for player:", event.player.Name, "Queue:", playerData.turnQueue)

		-- Do this at the end of the thread to make sure spawn finished reaches the client first
		task.defer(function()
			TurnService.StartTurn(event.player)
		end)
	end)
end

--- Add a character to the turn system
--- @param char -- The character to be added to the turn system
--- @param player -- The player associated with the character being added
function TurnService.AddActiveCharacter(char: _TYPES.Character, player: _TYPES.RobloxPlayerType)
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	-- Only add if not already in the active characters list
	if table.find(playerData.activeCharacters, char) then
		return
	end

	table.insert(playerData.activeCharacters, char)

	-- Add 2 turns for this character to the queue and notify clients about the new turns
	local actionValue = calculateActionValue(char)

	-- Turn 1
	addTurnToQueue(char, actionValue)

	-- Turn 2
	addTurnToQueue(char, actionValue * 2)

	-- Re-sort the turn queue with the new character
	playerData.turnQueue = Utility.SortTurnQueue(playerData.turnQueue)
end

--- Remove a character from the turn system
--- @param char -- The character to be removed from the turn system
--- @param player -- The player associated with the character being removed
function TurnService.RemoveActiveCharacter(char: _TYPES.Character, player: _TYPES.RobloxPlayerType)
	-- Remove from active characters
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	local index = table.find(playerData.activeCharacters, char)

	if index then
		table.remove(playerData.activeCharacters, index)

		-- Notify the client about the turn removal
		Zap.TurnRemovedForCharacter.Fire(player, {
			char = char,
			side = CharService.GetCharacterCombatData(char).side,
		})
	end

	-- Re-sort the turn queue after removal
	playerData.turnQueue = Utility.SortTurnQueue(playerData.turnQueue)
end

--- Get the current turn data
--- @param player -- The player to get the current turn for
function TurnService.GetCurrentTurn(player: _TYPES.RobloxPlayerType): _TYPES.TurnEntry?
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return nil
	end

	if #playerData.turnQueue == 0 then
		return nil
	end

	return playerData.currentTurn
end

-- Helper function to get a character's combat service module
local function getCharacterCombatService(char: _TYPES.Character): any
	local combatServiceModuleName = char.Name .. "_CombatService"
	local combatServiceModule =
		Services.Characters[char:GetAttribute("Side")][char.Name]:FindFirstChild(combatServiceModuleName)
	if not combatServiceModule then
		warn("CombatService module", combatServiceModuleName, "not found for character", char.Name)
		return nil
	end

	return combatServiceModule
end

--- Mark a turn as completed, allowing the next turn to proceed
--- @param player -- The player to mark the completed turn for
function TurnService.CompleteTurn(player: _TYPES.RobloxPlayerType)
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	if #playerData.turnQueue == 0 then
		return
	end

	-- Remove the current turn from the queue
	local completedTurn = table.remove(playerData.turnQueue, 1)

	if not completedTurn then
		return
	end

	-- Set the current turn entry to nil since the turn has completed
	-- Note: Before starting each turn, there is a brief moment where actions like ultimates can be used, and they wouldn't count
	-- as a "current turn", but rather an extra action
	playerData.currentTurn = nil

	-- Store the removed turn for turn-based statuses
	playerData.previousTurn = completedTurn

	-- Notify the client about the turn completion
	EventService.Events.TurnCompleted:Fire({
		turnId = completedTurn.turnId,
	})

	-- Normalise the turn queue after removing the completed turn
	playerData.turnQueue = Utility.NormaliseTurnQueue(playerData.turnQueue)

	-- Check if there is any extra action to execute
	warn(next(playerData.extraActionQueue), "Extra action queue for player:", player.Name)
	if playerData and next(playerData.extraActionQueue) then
		TurnService.ExecuteNextExtraAction(player :: _TYPES.RobloxPlayerType)
	end
end

--- Advance to the next turn
--- @param player -- The player to move to the next turn for
function TurnService.MoveToNextTurn(player: _TYPES.RobloxPlayerType)
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	local char = playerData.previousTurn and playerData.previousTurn.char or nil
	if char then
		-- Reduce the duration of all statuses for the character whose turn just completed
		StatusService.ReduceStatusesDuration(char)

		-- Check if this character is still active
		if table.find(playerData.activeCharacters, char) then
			-- Add the new turn to the queue
			playerData.currentTurnCount = playerData.currentTurnCount + 1
			addTurnToQueue(char, calculateActionValue(char))

			-- Re-sort the turn queue
			playerData.turnQueue = Utility.SortTurnQueue(playerData.turnQueue)
		end
	end

	-- Start the next turn
	TurnService.StartTurn(player)
end

--- Get the player turn data
--- @param player -- The player to get the turn data for
function TurnService.GetPlayerTurnData(player: _TYPES.RobloxPlayerType)
	return Players[player] or nil
end

--- Start the turn
--- @param player -- The player to start the turn for
function TurnService.StartTurn(player: _TYPES.RobloxPlayerType)
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	-- Return if no turn is available
	if not playerData.turnQueue[1] then
		warn("No turn available to start.")
		return
	end
	warn(playerData.turnQueue)

	-- Set the current turn entry
	playerData.currentTurn = playerData.turnQueue[1]

	-- Set the turn's character as the active character for the player
	player.ActiveCharacter.Value = playerData.turnQueue[1].char

	-- If the next character is an npc, execute its' attack after a short delay
	if playerData.turnQueue[1].side == "NPC" then
		task.wait(1) -- This is a placeholder, we will implement NPC attack delay and behaviour later
		-- Call the NPC's combat service to execute its' attack
		local npcCombatService = getCharacterCombatService(playerData.turnQueue[1].char)
		if npcCombatService then
			require(npcCombatService).HandleAttackBehaviour(playerData.turnQueue[1].char)
		else
			warn("No combat service found for NPC character:", playerData.turnQueue[1].char.Name)
		end
	-- If the turn belongs to a playable character, set that as the active character value
	else
		local char = playerData.turnQueue[1].char
		player.ActiveCharacter.Value = char
	end

	-- Send the turn started event to the client
	EventService.Events.TurnStarted:Fire({
		player = PlayerService.GetPlayerFromCharacter(playerData.turnQueue[1].char) :: _TYPES.RobloxPlayerType,
		data = {
			char = playerData.turnQueue[1].char,
			turnId = playerData.turnQueue[1].turnId,
			previousTurnId = playerData.previousTurn and playerData.previousTurn.turnId or nil,
		},
	})
end

--- Advance a character's action value by a specified amount
--- @param char -- The character whose action value is to be advanced
--- @param advancedBy -- The amount to advance the action value by, in percentages
function TurnService.AdvanceAction(char: _TYPES.Character, advancedBy: number)
	local player = PlayerService.GetPlayerFromCharacter(char)
	if not player then
		warn("Player not found for character:", char.Name)
		return
	end

	-- Find the turn entry for the character
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	for _, entry in pairs(playerData.turnQueue) do
		if entry.char :: any ~= char then
			continue
		end

		-- Advance the action value by the specified amount
		entry.actionValue = entry.actionValue - (entry.actionValue * advancedBy)

		-- Ensure the action value does not go below 0
		if entry.actionValue < 0 then
			entry.actionValue = 0
		end

		-- Re-sort the turn queue after modification
		local sortedQueue = Utility.SortTurnQueue(playerData.turnQueue) or {}
		warn(sortedQueue)

		-- Promote that queue to the top of the tie group if it's not already
		-- If the action value is 0 when there's a current turn, it should not take over the current turn
		promoteTurnToTopOfTieGroup(player, entry, sortedQueue)

		-- Then set the current turn queue to the sorted queue
		playerData.turnQueue = sortedQueue

		-- Fire the ActionAdvance event
		EventService.Events.ActionAdvance:Fire({
			char = char,
			advancedBy = advancedBy,
		})
		return
	end

	warn("Character", char.Name, "not found in turn queue. Cannot advance action.")
end

--- Execute the current extra action for a player, if any
--- @param player -- The player to execute the extra action for
function TurnService.ExecuteNextExtraAction(player: _TYPES.RobloxPlayerType)
	-- Set the current extra action for the player
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	if #playerData.extraActionQueue == 0 then
		warn("No extra actions queued for player:", player.Name)
		return
	end

	task.wait(1.5)

	-- Stop the start turn timeout for the player to avoid moving to the next turn
	local combatData = CombatService.GetCombatData(player)
	if combatData and combatData.startTurnTimeout and combatData.startTurnTimeout.IsRunning then
		warn("Stopping start turn timeout for player:", player.Name)
		combatData.startTurnTimeout:Stop()
	end

	local extraAction = playerData.extraActionQueue[1]
	playerData.currentExtraAction = extraAction

	local char = extraAction.char
	local action = extraAction.action
	local isFollowupAttack = extraAction.isFollowupAttack

	-- Get the combat service for the character
	if not getCharacterCombatService(char) then
		warn("No combat service found for character:", char.Name)
		return
	end
	
	local charCombatService = require(getCharacterCombatService(char))

	-- Set the char as the active character for the player
	player.ActiveCharacter.Value = char

	-- If the attack is a follow-up, call the attack handler directly
	if isFollowupAttack then
		local charCombatData = charCombatService.GetCharData(char)
		if not charCombatService.GetAttackHandlers()[action](char, charCombatData) then
			warn("Failed to execute follow-up attack for character:", char.Name, "with action:", action)
			TurnService.EndCurrentExtraAction(player)
		end
	-- Otherwise, call the input handler for the character's combat service
	else
		if not charCombatService.HandleInput(char, { action = action }) then
			warn("Failed to execute extra action for character:", char.Name, "with action:", action)
			TurnService.EndCurrentExtraAction(player)
		end
	end
end

--- Add an extra action for a character
--- @param char -- The character to add the extra action for
--- @param action -- The action to add for the character
--- @param isFollowupAttack -- Whether the extra action is a follow-up attack
function TurnService.AddExtraAction(char: _TYPES.Character, action: string, isFollowupAttack: boolean?)
	local player = PlayerService.GetPlayerFromCharacter(char)
	if not player then
		warn("Player not found for character:", char.Name)
		return
	end

	-- Get the player data
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	-- Get combat data
	local processingAttack = CombatService.GetCombatData(player).isProcessingAttack
	playerData.currentExtraActionCount += 1
	local extraActionId = playerData.currentExtraActionCount

	local currentTurnId = 0
	if playerData.currentTurn then
		currentTurnId = playerData.currentTurn.turnId
	elseif playerData.turnQueue[1] then
		currentTurnId = playerData.turnQueue[1].turnId
	end
	
	-- Add the extra action to the queue
	table.insert(playerData.extraActionQueue, {
		currentTurnId = currentTurnId,
		--
		extraActionId = extraActionId,
		char = char,
		side = CharService.GetCharacterCombatData(char).side,
		action = action,
		--
		isFollowupAttack = isFollowupAttack ~= nil,
	})

	-- Notify the client about the new extra action
	EventService.Events.ExtraActionAdded:Fire({
		currentTurnId = currentTurnId,
		--
		extraActionId = extraActionId,
		char = char,
		side = CharService.GetCharacterCombatData(char).side,
		action = action,
		isProcessingAttack = processingAttack,
		--
		isFollowupAttack = isFollowupAttack ~= nil,
	})
	
	return extraActionId
end

--- End the current extra action for a player, allowing the next queued extra action to be executed,
--- or if there are no queued extra actions, the turn system will proceed to the next turn
--- @param player -- The player to end the current extra action for
function TurnService.EndCurrentExtraAction(player: _TYPES.RobloxPlayerType)
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return
	end

	if not playerData.currentExtraAction then
		warn("No current extra action to end for player:", player.Name)
		return
	end

	-- Remove the current extra action
	local removedExtraAction = table.remove(playerData.extraActionQueue, 1)

	if not removedExtraAction then
		warn("Failed to remove current extra action for player:", player.Name)
		return
	end

	-- Notify the client about the extra action completion
	EventService.Events.ExtraActionCompleted:Fire({
		extraActionId = removedExtraAction.extraActionId,
	})

	-- Clear the current extra action
	playerData.currentExtraAction = nil

	-- If there are queued extra actions, execute the next one
	if #playerData.extraActionQueue > 0 then
		TurnService.ExecuteNextExtraAction(player)
		return
	end

	-- Else, return the active character to the current turn's character
	local currentTurn = playerData.currentTurn
	if not currentTurn then
		warn("No current turn found for player:", player.Name)
		return
	end

	local currentTurnChar = currentTurn.char
	player.ActiveCharacter.Value = currentTurnChar

	-- PLay the move preview again for the current turn's character
	local defaultMove = Utility.GetCharacterDefaultMove(currentTurnChar :: _TYPES.Character)
	if not defaultMove then
		return
	end
	-- Play the idle animation of the default move
	AnimationService.Play(currentTurnChar :: _TYPES.Character, defaultMove .. "_Idle")
	-- Update the move preview for the player with the default move
	CombatService.UpdateMovePreview(player, currentTurnChar :: _TYPES.Character, defaultMove)
end

--- Check if there are any active characters
--- @param player -- The player to check for active characters
function TurnService.HasActiveCharacters(player: _TYPES.RobloxPlayerType): boolean
	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return false
	end
	return #playerData.activeCharacters > 0
end

--- Get the turn data for a player
--- @param player -- The player to get the turn data for
function TurnService.GetTurnData(player: _TYPES.RobloxPlayerType)
	local playerData = Players[player]

	return playerData or nil
end

function TurnService.IsExtraActionQueued(char: _TYPES.Character, id: number): boolean
	local player = PlayerService.GetPlayerFromCharacter(char)
	if not player then
		warn("Player not found for character:", char.Name)
		return false
	end

	local playerData = Players[player]
	if not playerData then
		warn("Player data not found for player:", player.Name)
		return false
	end

	-- Find the queued action
	for _, queuedAction in pairs(playerData.extraActionQueue) do
		if queuedAction.extraActionId == id then
			return true
		end
	end

	return false
end
--- Initialise player entry in the turn system
--- @param player -- The player to initialise the entry for
function TurnService.InitialisePlayerEntry(player: _TYPES.RobloxPlayerType)
	Players[player] = {
		turnQueue = {},
		currentTurnCount = 0,
		currentTurn = nil,
		activeCharacters = {},
		previousTurnChar = nil,
		currentExtraActionCount = 0,
		currentExtraAction = nil,
		extraActionQueue = {},
	}
end

return TurnService
