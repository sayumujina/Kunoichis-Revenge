local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
--
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)
local CharacterCard = require(script.Parent.Character_Card)
local StageDetails = require(script.Parent.Parent.StageSelection.Stage_Details)
local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)
--
local TeleportService = game:GetService("TeleportService")
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
--
local Zap = require(StarterPlayerScripts.Client.zap)
--
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Store the selected character indexes
local selectedIndexes = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
} :: { [number]: string? }

local function findCharSelectedIndex(selectedIndexes: { [number]: string? }, charName: string): number?
	for i = 1, 3 do
		if selectedIndexes[i] == charName then
			return i
		end
	end

	return nil
end

local function findFirstAvailableIndex(): number?
	for i = 1, 3 do
		if not selectedIndexes[i] then
			return i
		end
	end

	return nil
end

local cardFramesByName = {} :: { [string]: Frame }

local function compactSelectedIndexes()
	local orderedSelectedChars = {}

	for i = 1, 3 do
		if selectedIndexes[i] then
			table.insert(orderedSelectedChars, selectedIndexes[i])
		end
	end

	for i = 1, 3 do
		selectedIndexes[i] = orderedSelectedChars[i]
	end
end

local function rebuildSelectionOverlays()
	compactSelectedIndexes()
	local removedMissingSelection = false

	for _, cardFrame in cardFramesByName do
		local selectionOverlay = cardFrame:FindFirstChild("Selection_Overlay")
		if selectionOverlay then
			selectionOverlay:Destroy()
		end
	end

	for i = 1, 3 do
		local charName = selectedIndexes[i]
		if not charName then
			continue
		end

		local characterFrame = cardFramesByName[charName]
		if characterFrame then
			CharacterCard.CreateSelectedOverlay(i).Parent = characterFrame
		else
			selectedIndexes[i] = nil
			removedMissingSelection = true
		end
	end

	if removedMissingSelection then
		compactSelectedIndexes()
		rebuildSelectionOverlays()
	end
end

-- Toggle the selection of a character card
local function toggleSelection(charName: string)
	local stageSelectionScreenGui = playerGui.StageSelection_ScreenGui
	local characterFrame = stageSelectionScreenGui:FindFirstChild("Character_Frame_" .. charName, true)

	-- If that character is already selected, deselect it
	local selectedIndex = findCharSelectedIndex(selectedIndexes, charName)
	if selectedIndex then
		-- Destroy the selection overlay for that index
		local selectionOverlay = characterFrame:FindFirstChild("Selection_Overlay")
		if selectionOverlay then
			selectionOverlay:Destroy()
		end

		selectedIndexes[selectedIndex] = nil
		return selectedIndexes
	end

	-- If all indexes are selected, and the new character is not already selected, replace the current highest index
	if selectedIndexes[1] and selectedIndexes[2] and selectedIndexes[3] then
		local highestIndex = #selectedIndexes
		local charToReplace = selectedIndexes[highestIndex]
		local charToReplaceFrame = stageSelectionScreenGui:FindFirstChild("Character_Frame_" .. charToReplace, true)
		local selectionOverlay = charToReplaceFrame:FindFirstChild("Selection_Overlay")

		-- Destroy the selection overlay for the character being replaced
		if selectionOverlay then
			selectionOverlay:Destroy()
		end

		-- Replace the character at the highest index with the new character
		selectedIndexes[highestIndex] = charName
		CharacterCard.CreateSelectedOverlay(highestIndex).Parent = characterFrame

		return selectedIndexes
	end

	-- If not all indexes are selected, select the first available index
	local indexToSelect = findFirstAvailableIndex()

	-- If all indexes are selected, replace the current highest index
	if not indexToSelect then
		indexToSelect = 3
	end

	-- Create the selection overlay for the selected index
	selectedIndexes[indexToSelect :: number] = charName
	CharacterCard.CreateSelectedOverlay(indexToSelect :: number).Parent = characterFrame

	return selectedIndexes
end

--- Exits the character selection screen and returns to the stage selection screen
--- @param fade boolean? -- Whether to fade out the character selection screen (default: true)
local function exitCharacterSelection(fade: boolean?)
	local function hide()
		-- Hide the character selection screen
		playerGui.StageSelection_ScreenGui:FindFirstChild("UI_StageCharacterSelection_Frame").Visible = false

		-- Destroy the stage details frame if it exists
		local stageDetailsFrame = playerGui.StageSelection_ScreenGui:FindFirstChild("UI_StageDetails_Frame")
		if stageDetailsFrame then
			stageDetailsFrame:Destroy()
		end

		-- Show the stage lists of the selected world and world list
		local stageListFolder = playerGui.StageSelection_ScreenGui:FindFirstChild("Stages")
		local selectedWorldValue = playerGui.StageSelection_ScreenGui.UI_WorldList_Frame.SelectedWorld.Value
		local selectedStageListFrame = stageListFolder:FindFirstChild("UI_" .. selectedWorldValue .. "_StageList_Frame")
		if selectedStageListFrame then
			selectedStageListFrame.Visible = true
		end
		playerGui.StageSelection_ScreenGui:FindFirstChild("UI_WorldList_Frame").Visible = true
	end

	-- If fade is false, hide immediately; otherwise, create a black screen transition before hiding
	if fade then
		CreateBlackScreen(0.6, nil, 0.4, hide)
	else
		hide()
	end
end

--- Creates the character selection frame with the given characters
--- @param chars -- The list of characters to display in the selection frame
local function createCharacterSelectionFrame(chars: { Name: string, Level: number?, Owned: boolean })
	local stageCharacterSelectionFrame = Instance.new("Frame")
	stageCharacterSelectionFrame.Name = "UI_StageCharacterSelection_Frame"
	stageCharacterSelectionFrame.BackgroundTransparency = 1
	stageCharacterSelectionFrame.Position = UDim2.fromScale(0.63, 0.155)
	stageCharacterSelectionFrame.Size = UDim2.fromScale(0.35, 0.82)
	stageCharacterSelectionFrame.Visible = false

	local returnButton = Instance.new("ImageButton")
	returnButton.Name = "Return_Button"
	returnButton.BackgroundTransparency = 1
	returnButton.Image = ui.hud.Menu.UI_Menu_ReturnArrow
	returnButton.Position = UDim2.fromScale(0.83, 0.056)
	returnButton.Size = UDim2.fromScale(0.1, 0.1)
	returnButton.ZIndex = 3

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.Parent = returnButton
	returnButton.Parent = stageCharacterSelectionFrame
	returnButton.MouseButton1Click:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		exitCharacterSelection(true)
	end)

	local characterList = Instance.new("ScrollingFrame")
	characterList.Name = "Character_List"
	characterList.Active = true
	characterList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	characterList.BackgroundTransparency = 1
	characterList.CanvasSize = UDim2.fromScale(0, 1)
	characterList.LayoutOrder = 3
	characterList.Position = UDim2.fromScale(0.07, 0.15)
	characterList.ScrollBarImageColor3 = Color3.new()
	characterList.ScrollingDirection = Enum.ScrollingDirection.Y
	characterList.Size = UDim2.fromScale(0.88, 0.69)
	characterList.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	characterList.ZIndex = 2

	characterList.Parent = stageCharacterSelectionFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Padding = UDim.new(0.02, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Wraps = true

	uIListLayout.Parent = characterList

	local bg = Instance.new("ImageLabel")
	bg.Name = "BG"
	bg.BackgroundTransparency = 1
	bg.Image = ui.hud.Menu.UI_Menu_CharacterSelection
	bg.ScaleType = Enum.ScaleType.Slice
	bg.Size = UDim2.fromScale(1, 1)
	bg.SliceCenter = Rect.new(32, 45, 849, 936)
	bg.Parent = stageCharacterSelectionFrame
	bg.ZIndex = 1

	local selectCharLabel = Instance.new("TextLabel")
	selectCharLabel.Name = "SelectChar_Label"
	selectCharLabel.BackgroundTransparency = 1
	selectCharLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	selectCharLabel.Position = UDim2.fromScale(0.15, 0.06)
	selectCharLabel.Size = UDim2.fromScale(0.7, 0.06)
	selectCharLabel.Text = "Select Characters"
	selectCharLabel.TextColor3 = Color3.new(1, 1, 1)
	selectCharLabel.TextScaled = true
	selectCharLabel.TextStrokeTransparency = 0
	selectCharLabel.Parent = stageCharacterSelectionFrame

	for _, char in pairs(chars) do
		local characterCard = CharacterCard.CreateCharacterCard(char.Owned, char.Name, char.Level, toggleSelection)
		cardFramesByName[char.Name] = characterCard
		characterCard.Parent = characterList
	end

	local startBattleButton = Instance.new("TextButton")
	startBattleButton.Name = "StartBattle_Button"
	startBattleButton.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	startBattleButton.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	startBattleButton.Position = UDim2.fromScale(0.3, 0.88)
	startBattleButton.Size = UDim2.fromScale(0.4, 0.06)
	startBattleButton.Text = "Start"
	startBattleButton.TextColor3 = Color3.fromRGB(43, 26, 16)
	startBattleButton.TextScaled = true
	startBattleButton.TextStrokeColor3 = Color3.new(1, 1, 1)
	startBattleButton.TextStrokeTransparency = 0
	startBattleButton.AutoButtonColor = false
	-- Upon clicking the start battle button, send a request to the server to spawn the selected characters
	startBattleButton.MouseButton1Click:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		local spawnChars = {}
		for _, char in pairs(selectedIndexes) do
			if char then
				table.insert(spawnChars, char)
			end
		end

		-- Disallow if no characters are selected
		if #spawnChars <= 0 then
			warn("No characters selected. Cannot start battle.")
			return
		end

		-- Get the selected stage and world IDs from the StageSelection_ScreenGui
		local selectedWorldValue = playerGui.StageSelection_ScreenGui.UI_WorldList_Frame.SelectedWorld.Value
		if not selectedWorldValue then
			warn("No world selected. Cannot start battle.")
			return
		end

		local blackScreenGui, forwardTween = CreateBlackScreen(0.6, nil, 0.4, function() end, nil, true)

		forwardTween.Completed:Once(function()
			TeleportService:SetTeleportGui(blackScreenGui)

			local selectedWorldFrameName = "UI_" .. selectedWorldValue .. "_StageList_Frame"
			local selectedStageValue =
				playerGui.StageSelection_ScreenGui.Stages[selectedWorldFrameName].SelectedStage.Value
			--

			Zap.RequestSpawn.Fire({
				stageId = selectedStageValue,
				worldId = selectedWorldValue,
				chars = spawnChars,
			})
		end)
	end)

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = startBattleButton

	startBattleButton.Parent = stageCharacterSelectionFrame

	return stageCharacterSelectionFrame
end

--- Updates the character selection frame with the given characters
--- @param stageCharacterSelectionFrame -- The character selection frame to update
--- @param chars -- The list of characters to display in the selection frame
local function updateCharacterSelectionFrame(
	stageCharacterSelectionFrame: Frame,
	chars: { Name: string, Level: number?, Owned: boolean }
)
	local characterList = stageCharacterSelectionFrame:FindFirstChild("Character_List")
	if not characterList or not characterList:IsA("ScrollingFrame") then
		return
	end

	local ownedCharacters = {}
	for _, char in chars do
		if char.Owned then
			ownedCharacters[char.Name] = true
		end
	end

	for i = 1, 3 do
		local selectedChar = selectedIndexes[i]
		if selectedChar and not ownedCharacters[selectedChar] then
			selectedIndexes[i] = nil
		end
	end
	compactSelectedIndexes()

	for _, child in characterList:GetChildren() do
		if child:IsA("Frame") and child.Name:match("^Character_Frame_") then
			child:Destroy()
		end
	end

	table.clear(cardFramesByName)

	for _, char in chars do
		local characterCard = CharacterCard.CreateCharacterCard(char.Owned, char.Name, char.Level, toggleSelection)
		cardFramesByName[char.Name] = characterCard
		characterCard.Parent = characterList
	end

	rebuildSelectionOverlays()
end

return {
	CreateCharacterSelectionFrame = createCharacterSelectionFrame,
	UpdateCharacterSelectionFrame = updateCharacterSelectionFrame,
	ExitCharacterSelection = exitCharacterSelection,
}
