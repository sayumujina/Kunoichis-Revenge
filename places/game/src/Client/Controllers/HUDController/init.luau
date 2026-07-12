local HUDController = {}
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)
local rep = game.ReplicatedStorage
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

-- Helpers
local Helpers = {
	QueueUIUtility = require(script.Helper.QueueUIUtility),
	UpdateCharacterStatValue = require(script.Helper.UpdateCharacterStatValue),
	UpdateCurrentManaValue = require(script.Helper.UpdateCurrentManaValue),
	UpdateDamageUI = require(script.Helper.UpdateDamageUI),
	DisplayWarning = require(script.Helper.DisplayWarning),
}

-- Components
local ComponentsPath = game.StarterPlayer.StarterPlayerScripts.Client.Controllers.HUDController.Components
local Components = {
	Combat = {
		CharacterCombatInfo = {
			CreateCharacterCombatInfoFrame = require(
				ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfoFrame
			),
			CreateCharacterCombatInfoCard = require(ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfoCard),
			CharacterCombatInfoHealthbar = require(
				ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfo_Healthbar
			),
			CreateCharacterCombatInfoBillboardGui = require(
				ComponentsPath.Combat.CharacterCombatInfo.CharacterCombatInfo_BillboardGui
			),
		},
		Mana = {
			CreateManaFrame = require(ComponentsPath.Combat.Mana.Mana_Frame),
		},
		Turns = {
			CreateTurnsFrame = require(ComponentsPath.Combat.Turns.Turns_Frame),
			CreateExtraActionCard = require(ComponentsPath.Combat.Turns.ExtraAction_Card),
			CreateMainTurnCard = require(ComponentsPath.Combat.Turns.MainTurn_Card),
			CreateTurnCardsList = require(ComponentsPath.Combat.Turns.Turn_Cards_List),
		},
		DetailedCombatInfo = {
			CharacterSelection = require(
				ComponentsPath.Combat.DetailedCombatInfo.DetailedCombatInfo_CharacterSelection
			),
			ScrollingFrame = require(ComponentsPath.Combat.DetailedCombatInfo.DetailedCombatInfo_ScrollingFrame),
			DetailedStatsFrame = require(ComponentsPath.Combat.DetailedCombatInfo.DetailedStats_Frame),
			StatusListFrame = require(ComponentsPath.Combat.DetailedCombatInfo.StatusList_Frame),
		},
		Damage = {
			CreateDamageCard = require(ComponentsPath.Combat.Damage.Damage_Card),
		},
	},
}

-- Local turn queue to keep track of the order of turns in the battle
local turnQueue = {} :: { _TYPES.TurnEntry }

-- Tracks whether each extra action should render before or after its owning turn card.
local extraActionLayoutInfoByTurnId = {} :: { [number]: { layoutGroup: string, turnId: number } }
local MAIN_TURN_LAYOUT_ORDER = 1

-- PlayerGui reference for creating UI elements
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Helper function to get the turn card container
local function getTurnCardContainer()
	return playerGui:FindFirstChild("UI_TurnCard_Container", true)
end

-- Helper function to find the turn cards list for a specific turnId
local function findTurnCardsList(turnId: number)
	local turnCardContainer = getTurnCardContainer()
	if not turnCardContainer then
		return nil
	end

	return turnCardContainer:FindFirstChild("Turn_Cards_List_" .. turnId)
end

-- Helper function to get the extra action ID from an extra action card
local function getExtraActionId(extraActionCard: Instance): number
	local extraActionIdValue = extraActionCard:FindFirstChild("ExtraActionIdValue")
	if extraActionIdValue and extraActionIdValue:IsA("NumberValue") then
		return extraActionIdValue.Value
	end

	return 0
end

-- Helper function to get the layout info for an extra action by its ID
local function clearExtraActionLayoutInfoForTurn(turnId: number)
	for extraActionId, layoutInfo in pairs(extraActionLayoutInfoByTurnId) do
		if layoutInfo.turnId == turnId then
			extraActionLayoutInfoByTurnId[extraActionId] = nil
		end
	end
end

-- Helper function to update the layout order of turn cards and extra action cards within a turn cards list
local function updateTurnCardsListLayout(turnCardsList: Instance)
	local mainTurnCard = turnCardsList:FindFirstChild("MainTurn_Card")
	if not mainTurnCard or not mainTurnCard:IsA("Frame") then
		return
	end

	local extraActionsBeforeMainTurn = {}
	local extraActionsAfterMainTurn = {}

	for _, child in turnCardsList:GetChildren() do
		if not child:IsA("Frame") or not child.Name:match("^ExtraAction_") then
			continue
		end

		local extraActionId = getExtraActionId(child)
		local layoutInfo = extraActionLayoutInfoByTurnId[extraActionId]
		-- Extra actions created while an attack is still resolving should stay in the left of the turn card.
		if layoutInfo and layoutInfo.layoutGroup == "before" then
			table.insert(extraActionsBeforeMainTurn, child)
		else
			table.insert(extraActionsAfterMainTurn, child)
		end
	end

	local function sortExtraActions(left: Instance, right: Instance): boolean
		return getExtraActionId(left) < getExtraActionId(right)
	end

	table.sort(extraActionsBeforeMainTurn, sortExtraActions)
	table.sort(extraActionsAfterMainTurn, sortExtraActions)

	-- Pack all "before" extra actions on the left of the main turn card.
	for index, extraActionCard in pairs(extraActionsBeforeMainTurn) do
		extraActionCard.LayoutOrder = index
	end

	-- Shift the main turn card right by however many extra actions are currently ahead of it.
	local mainTurnLayoutOrder = MAIN_TURN_LAYOUT_ORDER + #extraActionsBeforeMainTurn
	mainTurnCard.LayoutOrder = mainTurnLayoutOrder

	-- Then place any post-attack extra actions immediately after the main turn card.
	for index, extraActionCard in pairs(extraActionsAfterMainTurn) do
		warn("Setting layout order for extra action card:", extraActionCard.Name, "to", mainTurnLayoutOrder + index)
		extraActionCard.LayoutOrder = mainTurnLayoutOrder + index
	end
end

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
			local characterInfoCard = components.CreateCharacterCombatInfoCard(char :: _TYPES.Character)
			local characterInfoFrame = playerGui:FindFirstChild("UI_CharacterInfoFrame", true)
			if characterInfoFrame then
				characterInfoCard.Parent = characterInfoFrame
			end
		-- If it's an enemy, we only the need the health bar floating above thir head
		else
			-- Create a billboard GUI for the spawned enemy character
			components.CreateCharacterCombatInfoBillboardGui(char :: _TYPES.Character, playerGui)
		end

		-- Create the detailed combat info UI for the spawned character before pushing stat values into the HUD
		local c = Components.Combat.DetailedCombatInfo
		local detailedCombatInfoMenu = playerGui:FindFirstChild("DetailedCombatInfo_ScreenGui", true)
		local characterSelectionFrame = detailedCombatInfoMenu
			and detailedCombatInfoMenu:FindFirstChild("UI_Character_Selection_Frame", true)
		if characterSelectionFrame then
			c.CharacterSelection.AddCharButton(characterSelectionFrame, spawnSuccessfulEvent.char :: _TYPES.Character)
			c.ScrollingFrame.CreateDetailedCombatInfoScrollingFrame(spawnSuccessfulEvent.char :: _TYPES.Character).Parent =
				detailedCombatInfoMenu
		end

		Helpers.UpdateCharacterStatValue(
			playerGui,
			spawnSuccessfulEvent.char :: _TYPES.Character,
			"realStats",
			spawnSuccessfulEvent.data.realStats
		)

		-- Update the character's stat values on the character info cards
		Helpers.UpdateCharacterStatValue(
			playerGui,
			spawnSuccessfulEvent.char :: _TYPES.Character,
			"currentStats",
			spawnSuccessfulEvent.data.currentStats
		)

		-- Replace the stat value on the detailed combat info scrolling frame with the updated stat value
		Components.Combat.DetailedCombatInfo.DetailedStatsFrame.UpdateStatValue(
			spawnSuccessfulEvent.char :: _TYPES.Character,
			spawnSuccessfulEvent.data.realStats
		)
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

		-- Replace the stat value on the detailed combat info scrolling frame with the updated stat value
		Components.Combat.DetailedCombatInfo.DetailedStatsFrame.UpdateStatValue(
			statsChangedEvent.char :: _TYPES.Character,
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

	-- Listens to damage events to update the total damage UI
	Zap.Damage.On(function(damageEvent)
		Helpers.UpdateDamageUI.CreateDamagePopup(playerGui, damageEvent.data :: _TYPES.Damage)

		-- Only shows damage for playable characters
		if damageEvent.origin:GetAttribute("Side") ~= "Playable" then
			return
		end

		-- Only toggle visibility if the damage is positive (i.e., actual damage dealt)
		if damageEvent.data.damage < 0 then
			return
		end

		Helpers.UpdateDamageUI.ToggleDamageUIVisibility(playerGui, true)
		Helpers.UpdateDamageUI.UpdateTotalDamageUI(playerGui, damageEvent.data.damage)
	end)

	-- Listens to shield provided events to update the shield value on the character info cards
	Zap.ShieldProvided.On(function(shieldProvidedEvent)
		Helpers.UpdateDamageUI.CreateShieldPopup(playerGui, {
			target = shieldProvidedEvent.data.target :: _TYPES.Character,
			shieldAmount = shieldProvidedEvent.data.shieldAmount,
		})
	end)

	-- Listens to move end events to reset the total damage UI
	Zap.MoveEnd.On(function(moveEndData)
		Helpers.UpdateDamageUI.ToggleDamageUIVisibility(playerGui, false)
		Helpers.UpdateDamageUI.ResetTotalDamage()

		-- Tween the damage fill
		for _, target in pairs(moveEndData.data.recordedTargets) do
			Components.Combat.CharacterCombatInfo.CharacterCombatInfoHealthbar.UpdateBarSize(
				target :: _TYPES.Character,
				"Damage",
				true
			)
		end
	end)

	-- Listen to completed turns to update the turn queue
	Zap.TurnCompleted.On(function(completedTurnData)
		-- Find the corresponding turn card using index and remove it
		local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)
		if not turnCardContainer then
			return
		end

		-- Find the corresponding turn cards list for the completed turn and remove it
		local turnCardsList = findTurnCardsList(completedTurnData.turnId)
		if not turnCardsList then
			return
		end

		-- Remove the main turn card from the turn cards list
		turnCardsList:FindFirstChild("MainTurn_Card", true):Destroy()

		-- Remove the turn from the local turn list
		for index, turn in pairs(turnQueue) do
			if turn.turnId == completedTurnData.turnId then
				clearExtraActionLayoutInfoForTurn(turn.turnId)
				table.remove(turnQueue, index)
				break
			end
		end

		-- Normalise the turn queue after removal and update the turn queue UI
		turnQueue = Utility.NormaliseTurnQueue(turnQueue)
		Helpers.QueueUIUtility.UpdateTurnQueueUI(turnQueue)
	end)

	-- Listens to turn started event
	Zap.TurnStarted.On(function(startedTurnData)
		-- Find the corresponding turn cards list for the previous turn and destroy it
		if startedTurnData.previousTurnId then
			local turnCardsList = findTurnCardsList(startedTurnData.previousTurnId)
			if turnCardsList then
				turnCardsList:Destroy()
			end
		end

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
		local turnCardsList = Components.Combat.Turns.CreateTurnCardsList(
			turn.char :: _TYPES.Character,
			turn.turnId,
			findTurnIndex(turn.turnId) or 0,
			turn.side,
			turn.actionValue
		)

		-- Parent the turn card to the container
		local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)
		if turnCardContainer then
			turnCardsList.Parent = turnCardContainer
		end

		-- Update the turn queue UI after adding the new turn
		Helpers.QueueUIUtility.UpdateTurnQueueUI(turnQueue)
	end)

	-- Listens to extra action added events
	Zap.ExtraActionAdded.On(function(extraActionData)
		local turnCardsList = findTurnCardsList(extraActionData.currentTurnId)
		if not turnCardsList then
			warn("Turn card list not found for extra action currentTurnId:", extraActionData.currentTurnId)
			return
		end

		-- Remember which side of the main turn card this extra action belongs on for future reflows.
		extraActionLayoutInfoByTurnId[extraActionData.extraActionId] = {
			layoutGroup = if extraActionData.isProcessingAttack then "after" else "before",
			turnId = extraActionData.currentTurnId,
		}

		local extraActionCard = Components.Combat.Turns.CreateExtraActionCard(
			extraActionData.char :: _TYPES.Character,
			extraActionData.extraActionId,
			MAIN_TURN_LAYOUT_ORDER
		)
		extraActionCard.Parent = turnCardsList
		-- Recompute the whole row so multiple extra actions stay ordered consistently.
		updateTurnCardsListLayout(turnCardsList)
	end)

	-- Listens to extra action completed events
	Zap.ExtraActionCompleted.On(function(extraActionData)
		local turnCardContainer = getTurnCardContainer()
		if not turnCardContainer then
			return
		end

		local extraActionCard = turnCardContainer:FindFirstChild("ExtraAction_" .. extraActionData.extraActionId, true)
		if extraActionCard then
			local turnCardsList = extraActionCard.Parent
			extraActionCard:Destroy()
			extraActionLayoutInfoByTurnId[extraActionData.extraActionId] = nil
			if turnCardsList then
				-- Closing a gap can change the main turn card's slot, so reflow the row after removal.
				updateTurnCardsListLayout(turnCardsList)
			end
		end
	end)

	-- Listens to removed turns
	Zap.TurnRemoved.On(function(data)
		-- Find the corresponding turn card using index and remove it
		local turnCardContainer = playerGui:FindFirstChild("UI_TurnCard_Container", true)
		if turnCardContainer then
			local mainTurnCard = turnCardContainer:FindFirstChild("MainTurn_Card", true)
			if mainTurnCard then
				mainTurnCard:Destroy()
			end
		end

		-- Remove the turn from the local turn list
		for index, turn in pairs(turnQueue) do
			if turn.turnId == data.turnId then
				clearExtraActionLayoutInfoForTurn(turn.turnId)
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

			clearExtraActionLayoutInfoForTurn(turn.turnId)

			-- Remove the entry from the turn queue
			table.remove(turnQueue, index)

			-- Remove the corresponding turn card UI as well
			if not turnCardContainer then
				continue
			end

			-- Find the corresponding turn cards list for the character's turn and remove it
			local turnCardsList = turnCardContainer:FindFirstChild("Turn_Cards_List_" .. turn.turnId, true)
			if not turnCardsList then
				continue
			end

			turnCardsList:Destroy()
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
			if not turnCardContainer then
				return
			end

			-- Find the corresponding turn cards list for the character's turn and remove it
			local turnCardsList = turnCardContainer:FindFirstChild("Turn_Cards_List_" .. turn.turnId, true)
			if not turnCardsList then
				return
			end
			local mainTurnCard = turnCardContainer:FindFirstChild("MainTurn_Card")

			-- Update the action value label on the main turn card
			if mainTurnCard then
				local actionValueLabel = mainTurnCard:FindFirstChild("ActionValueLabel", true)
				if actionValueLabel and actionValueLabel:IsA("TextLabel") then
					actionValueLabel.Text = tostring(math.floor(turn.actionValue))
				end
			end

			break -- Exit the loop after updating the relevant character's turn
		end

		-- Re-sort the turn list after updating the action value
		turnQueue = Utility.SortTurnQueue(turnQueue)

		-- Update the turn queue UI after re-sorting
		Helpers.QueueUIUtility.UpdateTurnQueueUI(turnQueue)
	end)

	-- Listens to warning events
	Zap.Warning.On(function(warningEvent)
		Helpers.DisplayWarning(playerGui, warningEvent.message)
	end)

	-- Listens to the status added event
	Zap.StatusAdded.On(function(statusAddedEvent)
		task.defer(function()
			warn("Status added for character:", statusAddedEvent.char, "Status ID:", statusAddedEvent.data.id)
			Components.Combat.DetailedCombatInfo.StatusListFrame.AddStatusToList(
				statusAddedEvent.char :: _TYPES.Character,
				statusAddedEvent.data.id,
				statusAddedEvent.data.status.info.name,
				statusAddedEvent.data.status.info.description
			)
		end)
		Components.Combat.DetailedCombatInfo.StatusListFrame.AddStatusToList(
			statusAddedEvent.char :: _TYPES.Character,
			statusAddedEvent.data.id,
			statusAddedEvent.data.status.info.name,
			statusAddedEvent.data.status.info.description
		)
	end)

	-- Listens to the status removed event
	Zap.StatusRemoved.On(function(statusRemovedEvent)
		warn("Status removed for character:", statusRemovedEvent.char, "Status ID:", statusRemovedEvent.data.id)
		Components.Combat.DetailedCombatInfo.StatusListFrame.RemoveStatusFromList(
			statusRemovedEvent.char :: _TYPES.Character,
			statusRemovedEvent.data.id
		)
	end)

	-- Listens to death events
	Zap.Death.On(function(deathEvent)
		-- Remove the character from the selected character list in the detailed combat info menu
		local detailedCombatInfoMenu = playerGui:FindFirstChild("DetailedCombatInfo_ScreenGui", true)
		local characterSelectionFrame = detailedCombatInfoMenu
			and detailedCombatInfoMenu:FindFirstChild("UI_Character_Selection_Frame", true)
		if characterSelectionFrame then
			Components.Combat.DetailedCombatInfo.CharacterSelection.RemoveCharButton(
				characterSelectionFrame,
				deathEvent.char :: _TYPES.Character
			)
		end
	end)
end

--- Initializes the HUD for the player
function HUDController.Init()
	-- Create a screen GUI for the player if it doesn't exist
	if not playerGui:FindFirstChild("Combat_ScreenGui", true) then
		local hud = Instance.new("ScreenGui")
		hud.Name = "Combat_ScreenGui"
		hud.Parent = playerGui
	end

	local combatScreenGui = playerGui:FindFirstChild("Combat_ScreenGui", true)

	-- Create a folder for character and player UI
	local characterUIFolder = combatScreenGui:FindFirstChild("CharacterUI", true)
	if not characterUIFolder then
		characterUIFolder = Instance.new("Folder")
		characterUIFolder.Name = "CharacterUI"
		characterUIFolder.Parent = combatScreenGui
	end

	local playerUIFolder = combatScreenGui:FindFirstChild("PlayerUI", true)
	if not playerUIFolder then
		playerUIFolder = Instance.new("Folder")
		playerUIFolder.Name = "PlayerUI"
		playerUIFolder.Parent = combatScreenGui
	end

	-- Create a folder to contain the billboard GUIs
	if not combatScreenGui:FindFirstChild("UI_BillboardGui_Folder", true) then
		local billboardGuiContainer = Instance.new("Folder")
		billboardGuiContainer.Name = "UI_BillboardGui_Folder"
		billboardGuiContainer.Parent = combatScreenGui
	end

	-- Create the turn card container if it doesn't exist
	if not combatScreenGui:FindFirstChild("UI_TurnsFrame", true) then
		local turnsFrame = Components.Combat.Turns.CreateTurnsFrame()
		turnsFrame.Parent = playerUIFolder
	end

	-- Create the character info card container if it doesn't exist
	if not combatScreenGui:FindFirstChild("UI_CharacterInfoFrame", true) then
		local characterInfoFrame = Components.Combat.CharacterCombatInfo.CreateCharacterCombatInfoFrame()
		characterInfoFrame.Parent = characterUIFolder
	end

	-- Create the mana frame if it doesn't exist
	if not combatScreenGui:FindFirstChild("UI_ManaFrame", true) then
		local manaFrame = Components.Combat.Mana.CreateManaFrame()
		manaFrame.Parent = playerUIFolder
	end

	-- Create the damage card if it doesn't exist
	if not combatScreenGui:FindFirstChild("UI_DamageCard", true) then
		local damageCard = Components.Combat.Damage.CreateDamageCard()
		damageCard.Parent = playerUIFolder
	end

	-- Create a detailed combat info screen gui for the player if it doesn't exist
	if not playerGui:FindFirstChild("DetailedCombatInfo_ScreenGui", true) then
		local hud = Instance.new("ScreenGui")
		hud.Name = "DetailedCombatInfo_ScreenGui"
		hud.Parent = playerGui

		-- Turn it off by default
		hud.Enabled = false
	end

	local detailedCombatScreenGui = playerGui:FindFirstChild("DetailedCombatInfo_ScreenGui", true)

	-- Create the detailed combat info menu if it doesn't exist
	if not detailedCombatScreenGui:FindFirstChild("UI_Character_Selection_Frame", true) then
		local detailedMenuCharacterList = Components.Combat.DetailedCombatInfo.CharacterSelection.CreateCharacterList()
		detailedMenuCharacterList.Parent = detailedCombatScreenGui

		-- Every time the detailed combat info GUI is shown, default the selection to be the active character
		detailedCombatScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if not detailedCombatScreenGui.Enabled then
				return
			end

			local activeChar = game.Players.LocalPlayer.ActiveCharacter.Value
			if not activeChar then
				return
			end

			Components.Combat.DetailedCombatInfo.CharacterSelection.SwitchCharButton("CurrentChar")
		end)
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

--- Toggles the visibility of a specific ScreenGui in the player's PlayerGui
---  @param screenGuiName -- The name of the ScreenGui to toggle
---  @param isVisible -- A boolean indicating whether to show (true) or hide (false
function HUDController.ToggleScreenGuiVisibility(screenGuiName: string, isVisible: boolean)
	local screenGui = playerGui:FindFirstChild(screenGuiName, true)
	if screenGui and screenGui:IsA("ScreenGui") then
		screenGui.Enabled = isVisible
	else
		warn("ScreenGui named '" .. screenGuiName .. "' not found in PlayerGui")
	end
end

return HUDController
