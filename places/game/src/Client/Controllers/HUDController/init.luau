local HUDController = {}
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)
local rep = game.ReplicatedStorage
local _TYPES = require(rep.Shared.data_Types)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
local QueueUIUtility = require(script.Helper.QueueUIUtility)
--
local ComponentsPath = game.StarterPlayer.StarterPlayerScripts.Client.Controllers.HUDController.Components
local Components = {
	Combat = {
		CharacterCombatInfo = {
			createCharacterCombatInfoFrame = require(
				ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfoFrame
			),
			createCharacterCombatInfoCard = require(ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfoCard),
		},
		Turns = {
			createTurnsFrame = require(ComponentsPath.Combat.Turns.Turns_Frame),
			createTurnCard = require(ComponentsPath.Combat.Turns.Turn_Card),
		},
	},
}

local matchingCurrentStatsName = {
	["energy"] = "CurrentEnergy",
	["hp"] = "CurrentHP",
	-- ["shield"] = "CurrentShield",
}

local matchingRealStatsName = {
	["energy"] = "MaxEnergy",
	["hp"] = "MaxHP",
	-- ["shield"] = "MaxShield",
}

--
local turnQueue = {} :: { _TYPES.TurnEntry }

-- PlayerGui reference for creating UI elements
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Helper function to determine the index of a turn in the turn queue
local function findTurnIndex(turnId: number): number?
	for index, turn in pairs(turnQueue) do
		if turn.turnId == turnId then
			return index
		end
	end
	return nil
end

--- Called when the controller starts
function HUDController.OnStart()
	-- Normalise the turn queue once all characters are spawned and the battle is ready to proceed
	Zap.SpawnFinished.On(function()
		-- Normalize the turn queue
		turnQueue = Utility.NormaliseTurnQueue(turnQueue)

		-- Update the turn queue UI after normalisation
		QueueUIUtility.UpdateTurnQueueUI(turnQueue)
	end)

	-- Listens to spawn successful events to create character info cards for the spawned characters
	Zap.SpawnSuccessfulForChar.On(function(spawnSuccessfulEvent)
		-- If the spawned character is not an ally, return early
		if spawnSuccessfulEvent.data.side ~= "Allies" then
			return
		end

		local char = spawnSuccessfulEvent.char

		-- Create a character info card for the spawned character
		local characterInfoCard =
			Components.Combat.CharacterCombatInfo.createCharacterCombatInfoCard(char :: _TYPES.Character)
		local characterInfoFrame = playerGui:FindFirstChild("UI_CharacterInfoFrame", true)
		if characterInfoFrame then
			characterInfoCard.Parent = characterInfoFrame
		end
	end)

	-- Listens to current stats changed events to update the stat values on the character info cards
	Zap.CurrentStatsChanged.On(function(statsChangedEvent)
		local characterInfoFrame = playerGui:FindFirstChild("UI_CharacterInfoFrame", true)
		if not characterInfoFrame then
			return
		end

		-- Find the corresponding character info card using the character reference and update the energy values
		for _, card in pairs(characterInfoFrame:GetChildren()) do
			-- Check if the card is a Frame and has the AssociatedCharValue object value, then compare the character reference
			local associatedCharValue = card:FindFirstChild("AssociatedCharValue", true)
			if not card:IsA("Frame") or not associatedCharValue then
				continue
			end

			-- If the associated character value does not match the character whose stats changed, skip this card
			if associatedCharValue.Value ~= statsChangedEvent.char then
				continue
			end

			-- Update the stat values on the character info card based on the changed stats
			for statName, statValue in pairs(statsChangedEvent.data) do
				-- Check if the stat name is one of the stats we are tracking
				if not matchingCurrentStatsName[statName] then
					continue
				end

				-- Replace the stat value on the character info card with the updated stat value
				local statValueObject =
					card:FindFirstChild("Character" .. matchingCurrentStatsName[statName] .. "Value", true)
				if statValueObject then
					statValueObject.Value = statValue
				end
			end
			break
		end
	end)

	-- Listens to real stats changed events to update the stat values on the character info cards
	Zap.RealStatsChanged.On(function(statsChangedEvent)
		local characterInfoFrame = playerGui:FindFirstChild("UI_CharacterInfoFrame", true)
		if not characterInfoFrame then
			return
		end

		-- Find the corresponding character info card using the character reference and update the energy values
		for _, card in pairs(characterInfoFrame:GetChildren()) do
			-- Check if the card is a Frame and has the AssociatedCharValue object value, then compare the character reference
			local associatedCharValue = card:FindFirstChild("AssociatedCharValue", true)
			if not card:IsA("Frame") or not associatedCharValue then
				continue
			end

			-- If the associated character value does not match the character whose stats changed, skip this card
			if associatedCharValue.Value ~= statsChangedEvent.char then
				continue
			end

			-- Update the stat values on the character info card based on the changed stats
			for statName, statValue in pairs(statsChangedEvent.data) do
				-- Check if the stat name is one of the stats we are tracking
				if not matchingRealStatsName[statName] then
					continue
				end

				-- Replace the stat value on the character info card with the updated stat value
				local statValueObject =
					card:FindFirstChild("Character" .. matchingRealStatsName[statName] .. "Value", true)
				if statValueObject then
					statValueObject.Value = statValue
				end
			end
			break
		end
	end)

	-- Listen to completed turns to update the turn queue
	Zap.TurnCompleted.On(function(completedTurnData)
		-- Find the corresponding turn card using index and remove it
		local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)
		if turnCardContainer then
			local turnCard = turnCardContainer:FindFirstChild("Turn_Card_" .. completedTurnData.turnId, true)
			if turnCard then
				turnCard:Destroy()
			end
		end

		-- Remove the turn from the local turn list
		for index, turn in pairs(turnQueue) do
			if turn.turnId == completedTurnData.turnId then
				table.remove(turnQueue, index)
				break
			end
		end

		-- Normalise the turn queue after removal
		turnQueue = Utility.NormaliseTurnQueue(turnQueue)
	end)

	-- Listens to added turns
	Zap.TurnAdded.On(function(turnData)
		local turn = {
			turnId = turnData.turnId,
			char = turnData.char :: _TYPES.Character,
			side = turnData.side,
			actionValue = turnData.actionValue,
		}

		-- Add the new turn to the local turn list
		table.insert(turnQueue, turn)

		-- Sort the turn list after adding the new turn
		Utility.SortTurnQueue(turnQueue)

		-- Create a new turn card for the added turn
		local turnCard = Components.Combat.Turns.createTurnCard(
			turn.char :: _TYPES.Character,
			turn.turnId,
			findTurnIndex(turn.turnId) or 0,
			turn.side,
			turn.actionValue
		)

		-- Update the turn queue UI after adding the new turn
		QueueUIUtility.UpdateTurnQueueUI(turnQueue)

		-- Parent the turn card to the container
		local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)
		if turnCardContainer then
			turnCard.Parent = turnCardContainer
		end
	end)

	-- Listens to removed turns
	Zap.TurnRemoved.On(function(data)
		-- Find the corresponding turn card using index and remove it
		local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)
		if turnCardContainer then
			local turnCard = turnCardContainer:FindFirstChild("Turn_Card_" .. data.turnId, true)
			if turnCard then
				turnCard:Destroy()
			end
		end

		-- Remove the turn from the local turn list
		for index, turn in pairs(turnQueue) do
			if turn.turnId == data.turnId then
				table.remove(turnQueue, index)
				break
			end
		end

		-- Update the turn queue UI after removing the turn
		QueueUIUtility.UpdateTurnQueueUI(turnQueue)
	end)

	-- Listens to character-wide turn removals (for character deaths, etc.)
	Zap.TurnRemovedForCharacter.On(function(data)
		local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)

		-- Remove all turns for the character from the local turn list
		for index, turn in pairs(turnQueue) do
			if turn.char :: any ~= data.char then
				continue
			end

			-- Remove the entry from the turn queue
			table.remove(turnQueue, index)

			-- Remove the corresponding turn card UI as well
			if turnCardContainer then
				local turnCard = turnCardContainer:FindFirstChild("Turn_Card_" .. turn.turnId)
				if turnCard then
					turnCard:Destroy()
				end
			end
		end

		-- Re-sort the turn list after removal
		Utility.SortTurnQueue(turnQueue)
	end)
end

function HUDController.Init()
	-- Create a screen GUI for the player if it doesn't exist
	if not playerGui:FindFirstChild("ScreenGui", true) then
		local hud = Instance.new("ScreenGui")
		hud.Name = "ScreenGui"
		hud.Parent = playerGui
	end

	local screenGui = playerGui:FindFirstChild("ScreenGui", true)

	-- Create the turn card container if it doesn't exist
	if not screenGui:FindFirstChild("UI_TurnsFrame", true) then
		local turnsFrame = Components.Combat.Turns.createTurnsFrame()
		turnsFrame.Parent = screenGui
	end

	-- Create the character info card container if it doesn't exist
	if not screenGui:FindFirstChild("UI_CharacterInfoFrame", true) then
		local characterInfoFrame = Components.Combat.CharacterCombatInfo.createCharacterCombatInfoFrame()
		characterInfoFrame.Parent = screenGui
	end
end

return HUDController
