local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
--
local CharacterCard = require(script.Parent.Character_Card)
local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
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
-- Toggle the selection of a character card
local function toggleSelection(charName: string)
	local globalScreenGui = playerGui.Global_ScreenGui
	local characterFrame = globalScreenGui:FindFirstChild("Character_Frame_" .. charName, true)
	warn("Character_Frame_" .. charName)

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
		local charToReplaceFrame = globalScreenGui:FindFirstChild("Character_Frame_" .. charToReplace, true)
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

	warn("Selecting character: " .. charName .. " at index: " .. indexToSelect)
	-- Create the selection overlay for the selected index
	selectedIndexes[indexToSelect :: number] = charName
	CharacterCard.CreateSelectedOverlay(indexToSelect :: number).Parent = characterFrame

	return selectedIndexes
end

return function(chars: { Name: string, Level: number?, Owned: boolean })
	local stageCharacterSelectionFrame = Instance.new("Frame")
	stageCharacterSelectionFrame.Name = "UI_StageCharacterSelection_Frame"
	stageCharacterSelectionFrame.BackgroundTransparency = 1
	stageCharacterSelectionFrame.Position = UDim2.fromScale(0.63, 0.155)
	stageCharacterSelectionFrame.Size = UDim2.fromScale(0.35, 0.82)

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
	startBattleButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
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

		warn(spawnChars)
		Zap.RequestSpawn.Fire({ stageId = "1-1", chars = spawnChars :: { string } })
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
