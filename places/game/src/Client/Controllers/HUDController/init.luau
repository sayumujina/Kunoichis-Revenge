local HUDController = {}
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)
local rep = game.ReplicatedStorage
local _TYPES = require(rep.Shared.data_Types)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

-- Helpers
local Helpers = {
	QueueUIUtility = require(script.Helper.QueueUIUtility),
	UpdateCharacterStatValue = require(script.Helper.UpdateCharacterStatValue),
	UpdateCurrentManaValue = require(script.Helper.UpdateCurrentManaValue),
}

-- Components
local ComponentsPath = game.StarterPlayer.StarterPlayerScripts.Client.Controllers.HUDController.Components
local Components = {
	Combat = {
		CharacterCombatInfo = {
			createCharacterCombatInfoFrame = require(
				ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfoFrame
			),
			createCharacterCombatInfoCard = require(ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfoCard),
			createCharacterCombatInfoHealthbar = require(
				ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfo_Healthbar
			),
			createCharacterCombatInfoBillboardGui = require(
				ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfo_BillboardGui
			),
		},
		Mana = {
			createManaFrame = require(ComponentsPath.Combat.Mana.Mana_Frame),
		},
		Turns = {
			createTurnsFrame = require(ComponentsPath.Combat.Turns.Turns_Frame),
			createTurnCard = require(ComponentsPath.Combat.Turns.Turn_Card),
		},
	},
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
		Helpers.QueueUIUtility.UpdateTurnQueueUI(turnQueue)
	end)

	-- Listens to spawn successful events to create character info cards for the spawned characters
	Zap.SpawnSuccessfulForChar.On(function(spawnSuccessfulEvent)
		local components = Components.Combat.CharacterCombatInfo
		local char = spawnSuccessfulEvent.char

		-- If the spawned character is a playable character, create a character info card for them
		if spawnSuccessfulEvent.data.side == "Playable" then
			-- Create a character info card for the spawned character
			local characterInfoCard = components.createCharacterCombatInfoCard(char :: _TYPES.Character)
			local characterInfoFrame = playerGui:FindFirstChild("UI_CharacterInfoFrame", true)
			if characterInfoFrame then
				characterInfoCard.Parent = characterInfoFrame
			end
		-- If it's an enemy, we only the need the health bar floating above thir head
		else
			-- Create a billboard GUI for the spawned enemy character
			components.createCharacterCombatInfoBillboardGui(char :: _TYPES.Character, playerGui)
		end
	end)

	-- Listens to current stats changed events to update the stat values on the character info cards
	Zap.CurrentStatsChanged.On(function(statsChangedEvent)
		Helpers.UpdateCharacterStatValue(
			playerGui,
			statsChangedEvent.char :: _TYPES.Character,
			"currentStats",
			statsChangedEvent.data
		)
	end)

	-- Listens to real stats changed events to update the stat values on the character info cards
	Zap.RealStatsChanged.On(function(statsChangedEvent)
		Helpers.UpdateCharacterStatValue(
			playerGui,
			statsChangedEvent.char :: _TYPES.Character,
			"realStats",
			statsChangedEvent.data
		)
	end)

	-- Listens to player current stats changed events to update the player's stats
	Zap.PlayerCurrentStatsChanged.On(function(playerCurrentStatsChangedEvent)
		-- Check if the changed stat is "mana" and update the mana value accordingly
		for statName, newValue in pairs(playerCurrentStatsChangedEvent.data) do
			if statName == "mana" then
				Helpers.UpdateCurrentManaValue(playerGui, newValue)
			end
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

	-- Listens to turn started event
	Zap.TurnStarted.On(function(startedTurnData)
		-- Reduce the size of the other two character info cards to highlight the current character's turn
		for _, card in pairs(playerGui:GetDescendants()) do
			if not card:IsA("Frame") or not card.Name:match("CharacterInfo_Card_") then
				continue
			end

			local associatedCharValue = card:FindFirstChild("AssociatedCharValue")
			if associatedCharValue and associatedCharValue.Value ~= startedTurnData.char then
				-- Reduce the size of the other character info cards
				card.Size = UDim2.fromScale(0.85, 0.85)
			else
				-- Reset the size of the current character's info card
				card.Size = UDim2.fromScale(1, 1)
			end
		end
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
		turnQueue = Utility.SortTurnQueue(turnQueue)

		-- Create a new turn card for the added turn
		local turnCard = Components.Combat.Turns.createTurnCard(
			turn.char :: _TYPES.Character,
			turn.turnId,
			findTurnIndex(turn.turnId) or 0,
			turn.side,
			turn.actionValue
		)

		-- Update the turn queue UI after adding the new turn
		Helpers.QueueUIUtility.UpdateTurnQueueUI(turnQueue)

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
		Helpers.QueueUIUtility.UpdateTurnQueueUI(turnQueue)
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
		turnQueue = Utility.SortTurnQueue(turnQueue)
	end)

	-- Listens to action advance events
	Zap.ActionAdvance.On(function(data)
		-- Find the corresponding turn in the local turn list and update its action value
		for _, turn in pairs(turnQueue) do
			if turn.char :: any ~= data.char then
				continue
			end

			-- Update the action value for the character's turn
			turn.actionValue = turn.actionValue - (turn.actionValue * data.advancedBy)

			-- Update the corresponding turn card UI as well
			local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)
			if turnCardContainer then
				local turnCard = turnCardContainer:FindFirstChild("Turn_Card_" .. turn.turnId)
				warn(turnCard, "Turn Card for", turn.char.Name, "with Turn ID", turn.turnId, "found:", turnCard ~= nil)
				if turnCard then
					local actionValueLabel = turnCard:FindFirstChild("ActionValueLabel", true)
					if actionValueLabel and actionValueLabel:IsA("TextLabel") then
						actionValueLabel.Text = tostring(math.floor(turn.actionValue))
					end
				end
			end

			break -- Exit the loop after updating the relevant character's turn
		end

		-- Re-sort the turn list after updating the action value
		turnQueue = Utility.SortTurnQueue(turnQueue)

		-- Update the turn queue UI after re-sorting
		Helpers.QueueUIUtility.UpdateTurnQueueUI(turnQueue)
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

	-- Create a folder for character and player UI
	local characterUIFolder = screenGui:FindFirstChild("CharacterUI", true)
	if not characterUIFolder then
		characterUIFolder = Instance.new("Folder")
		characterUIFolder.Name = "CharacterUI"
		characterUIFolder.Parent = screenGui
	end

	local playerUIFolder = screenGui:FindFirstChild("PlayerUI", true)
	if not playerUIFolder then
		playerUIFolder = Instance.new("Folder")
		playerUIFolder.Name = "PlayerUI"
		playerUIFolder.Parent = screenGui
	end

	-- Create a folder to contain the billboard GUIs
	if not screenGui:FindFirstChild("UI_BillboardGui_Folder", true) then
		local billboardGuiContainer = Instance.new("Folder")
		billboardGuiContainer.Name = "UI_BillboardGui_Folder"
		billboardGuiContainer.Parent = screenGui
	end

	-- Create the turn card container if it doesn't exist
	if not screenGui:FindFirstChild("UI_TurnsFrame", true) then
		local turnsFrame = Components.Combat.Turns.createTurnsFrame()
		turnsFrame.Parent = playerUIFolder
	end

	-- Create the character info card container if it doesn't exist
	if not screenGui:FindFirstChild("UI_CharacterInfoFrame", true) then
		local characterInfoFrame = Components.Combat.CharacterCombatInfo.createCharacterCombatInfoFrame()
		characterInfoFrame.Parent = characterUIFolder
	end

	-- Create the mana frame if it doesn't exist
	if not screenGui:FindFirstChild("UI_ManaFrame", true) then
		local manaFrame = Components.Combat.Mana.createManaFrame()
		manaFrame.Parent = playerUIFolder
	end
end

--- Updates the mana preview in the HUD
--- @param previewValue The new mana value to display in the preview
function HUDController.UpdateManaPreview(previewValue: number)
	-- Get the mana frame from the player's GUI
	local manaFrame = playerGui:FindFirstChild("UI_ManaFrame", true)
	if not manaFrame then
		warn("UI_ManaFrame not found in PlayerGui")
		return
	end

	-- Update the current mana preview label
	local currentManaLabel = manaFrame:FindFirstChild("Mana_PreviewLabel", true)
	if currentManaLabel and currentManaLabel:IsA("TextLabel") then
		local sign = previewValue >= 0 and "+" or "-"
		currentManaLabel.Text = sign .. tostring(math.floor(math.abs(previewValue)))
	end
end

return HUDController
