local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Conrollers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
-- Helpers
local Helpers = StarterPlayerScripts.Client.Controllers.HUDController.Helper
local GetAvatarImageForCharacter = require(rep.Shared.GlobalUtility.GetAvatarImageForCharacter)
-- Components
local DetailedCombatInfoScrollingFrame = require(script.Parent.DetailedCombatInfo_ScrollingFrame)

local PLAYABLES_BG_COLOR = Color3.fromRGB(2, 234, 255)
local NPCS_BG_COLOR = Color3.fromRGB(255, 0, 0)
local SELECTED_BG_COLOR = Color3.fromRGB(0, 0, 0)

local function getDefaultBackgroundColor(char: _TYPES.Character): Color3
	return if char:GetAttribute("Side") == "Playable" then PLAYABLES_BG_COLOR else NPCS_BG_COLOR
end

local function getNumberOfScrollingFrames(): number
	local detailedCombatInfoScreenGui =
		game.Players.LocalPlayer.PlayerGui:FindFirstChild("DetailedCombatInfo_ScreenGui")
	if not detailedCombatInfoScreenGui then
		return 0
	end

	local count = 0
	for _, child in pairs(detailedCombatInfoScreenGui:GetChildren()) do
		if child:IsA("ScrollingFrame") then
			count += 1
		end
	end

	return count
end
--- Selects a character button in the character list frame and updates the selected character value
--- @param characterListFrame -- The frame containing the character buttons
--- @param char -- The character to select
local function selectCharButton(characterListFrame: Frame, order: number)
	local selectedButtonLayoutOrder = characterListFrame:FindFirstChild("SelectedButtonLayoutOrder")
	if not selectedButtonLayoutOrder or not selectedButtonLayoutOrder:IsA("NumberValue") then
		return
	end

	-- Get the selected character value to the newly selected character
	local previouslySelectedLayoutOrder = selectedButtonLayoutOrder.Value

	-- Loop through all the buttons in the character list frame and reset their background color
	for _, frame in pairs(characterListFrame:GetChildren()) do
		local associatedCharValue = frame:FindFirstChild("AssociatedCharacter")
		if not frame:IsA("Frame") or not associatedCharValue or not associatedCharValue:IsA("ObjectValue") then
			continue
		end

		-- Find the currently selected button and reset its background color
		if frame.LayoutOrder == previouslySelectedLayoutOrder then
			frame.BackgroundColor3 = getDefaultBackgroundColor(associatedCharValue.Value :: _TYPES.Character)
		end

		-- Find the newly selected button and update its background color to indicate selection
		if frame.LayoutOrder == order then
			frame.BackgroundColor3 = SELECTED_BG_COLOR
			selectedButtonLayoutOrder.Value = order

			-- Update the camera to focus on the associated character and show the detailed combat info for that character
			CameraController.LookAtCharacterInDetailedMenu(associatedCharValue.Value :: _TYPES.Character)
			DetailedCombatInfoScrollingFrame.ShowCharDetailedCombat(associatedCharValue.Value :: _TYPES.Character)
		end
	end
end

--- Switch the selected character button in the character list frame
--- @param mode -- The mode to switch the selected character button, either "Previous" or "Next"
local function switchCharButton(mode: "Previous" | "Next" | "CurrentChar")
	local characterListFrame = game.Players.LocalPlayer.PlayerGui
		:FindFirstChild("DetailedCombatInfo_ScreenGui")
		:FindFirstChild("UI_Character_Selection_Frame")
	if not characterListFrame then
		return
	end

	local selectedLayoutOrderValue = characterListFrame:FindFirstChild("SelectedButtonLayoutOrder")
	if not selectedLayoutOrderValue or not selectedLayoutOrderValue:IsA("NumberValue") then
		return
	end

	-- Clamp the layout order to the range of available buttons
	local order
	if mode == "Previous" then
		order = math.max(1, selectedLayoutOrderValue.Value - 1)
	elseif mode == "Next" then
		order = math.min(getNumberOfScrollingFrames(), selectedLayoutOrderValue.Value + 1)
	elseif mode == "CurrentChar" then
		-- Find the button associated with the player's active character and set the order to its layout order
		local activeChar = game.Players.LocalPlayer.ActiveCharacter.Value
		for _, frame in pairs(characterListFrame:GetChildren()) do
			local associatedCharValue = frame:FindFirstChild("AssociatedCharacter")
			if not frame:IsA("Frame") or not associatedCharValue or not associatedCharValue:IsA("ObjectValue") then
				continue
			end

			if associatedCharValue.Value == activeChar then
				order = frame.LayoutOrder
				break
			end
		end
	end

	-- Skip if the selected layout order is the same as the current selected layout order
	if order == selectedLayoutOrderValue.Value then
		return
	end

	-- Select the character button with the clamped layout order
	selectCharButton(characterListFrame, order)
end

--- Creates a character button for the character selection list
--- @param char -- The character to create the button for
--- @param order -- The layout order of the button in the list
local function createCharButton(characterListFrame: Frame, char: _TYPES.Character, order: number)
	local characterSelectionFrame = Instance.new("Frame")
	characterSelectionFrame.Name = char.Name .. "_Selection_Frame"
	characterSelectionFrame.BackgroundColor3 = getDefaultBackgroundColor(char)
	characterSelectionFrame.BackgroundTransparency = 0.6
	characterSelectionFrame.LayoutOrder = order
	characterSelectionFrame.Position = UDim2.fromScale(0.05, 0)
	characterSelectionFrame.Size = UDim2.fromScale(0.9, 0.9)

	local associatedChar = Instance.new("ObjectValue")
	associatedChar.Name = "AssociatedCharacter"
	associatedChar.Value = char
	associatedChar.Parent = characterSelectionFrame

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.Parent = characterSelectionFrame

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = characterSelectionFrame

	local avatar = Instance.new("ImageButton")
	avatar.Name = "Avatar"
	avatar.BackgroundColor3 = Color3.new(1, 1, 1)
	avatar.BackgroundTransparency = 0.5
	avatar.BorderColor3 = Color3.new()
	avatar.BorderSizePixel = 0
	avatar.Image = GetAvatarImageForCharacter(char.Name)
	avatar.Size = UDim2.fromScale(1, 1)
	-- When clicked,
	-- 1. Select the character button
	-- 2. Update the camera to focus on the associated character
	-- 3. Display the detailed combat info for that character
	avatar.MouseButton1Click:Connect(function()
		selectCharButton(characterListFrame, characterSelectionFrame.LayoutOrder)
	end)
	avatar.Parent = characterSelectionFrame

	return characterSelectionFrame
end

--- Creates the character selection list frame
local function createCharacterList()
	local characterListFrame = Instance.new("Frame")
	characterListFrame.Name = "UI_Character_Selection_Frame"
	characterListFrame.AnchorPoint = Vector2.new(0, 0.5)
	characterListFrame.AutomaticSize = Enum.AutomaticSize.Y
	characterListFrame.BackgroundTransparency = 1
	characterListFrame.Position = UDim2.fromScale(0, 0.5)
	characterListFrame.Size = UDim2.fromScale(0.06, 0)

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.ItemLineAlignment = Enum.ItemLineAlignment.Start
	uIListLayout.Padding = UDim.new(0, 10)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = characterListFrame

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingBottom = UDim.new(0, 6)
	uIPadding.PaddingTop = UDim.new(0, 6)
	uIPadding.Parent = characterListFrame

	local selectedButtonLayoutOrder = Instance.new("NumberValue")
	selectedButtonLayoutOrder.Name = "SelectedButtonLayoutOrder"
	selectedButtonLayoutOrder.Parent = characterListFrame

	return characterListFrame
end

-- Helper function to resort the layout order of character buttons in the character list frame
local function resortButtonsLayoutOrder()
	local detailedCombatScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("DetailedCombatInfo_ScreenGui")
	if not detailedCombatScreenGui then
		return
	end

	-- Get all the buttons in the character list frame and sort them based on their associated character's index
	local buttons = detailedCombatScreenGui:QueryDescendants("ImageButton")
	local playableCount = #workspace.Characters.Playable:GetChildren()

	-- Get the desired layout order for a button
	-- For NPCs, the layout order is their index + the number of playable characters
	local function getDesiredLayoutOrder(button: Frame): number
		local char = button.Parent:FindFirstChild("AssociatedCharacter").Value :: _TYPES.Character
		local charIndex = char:GetAttribute("Index") :: number

		if char:GetAttribute("Side") == "Playable" then
			return charIndex
		end

		return playableCount + charIndex
	end

	for _, button in pairs(buttons) do
		-- The layout order belongs to the parent frame instead
		button.Parent.LayoutOrder = getDesiredLayoutOrder(button)
	end
end

--- Remove a character button from the character list frame
--- @param characterListFrame -- The frame containing the character buttons
--- @param char -- The character to remove the button for
local function removeCharButton(characterListFrame: Frame, char: _TYPES.Character)
	for _, child in pairs(characterListFrame:GetChildren()) do
		local associatedCharValue = child:FindFirstChild("AssociatedCharacter")
		if not child:IsA("Frame") or not associatedCharValue then
			continue
		end

		local associatedChar = associatedCharValue.Value
		if associatedChar == char then
			child:Destroy()
			resortButtonsLayoutOrder()
			break
		end
	end
end

--- Add a character button to the character list frame
--- @param characterListFrame -- The frame containing the character buttons
--- @param char -- The character to add the button for
local function addCharButton(characterListFrame: Frame, char: _TYPES.Character)
	local charButton = createCharButton(characterListFrame, char, 0)
	charButton.Parent = characterListFrame
	resortButtonsLayoutOrder()
end

--- Reset the selected layout order in the character list frame to 0 for the next time the menu is opened
local function resetSelectedLayoutOrder()
	local characterListFrame = game.Players.LocalPlayer.PlayerGui
		:FindFirstChild("DetailedCombatInfo_ScreenGui")
		:FindFirstChild("UI_Character_Selection_Frame")

	if not characterListFrame then
		return
	end

	local selectedButtonLayoutOrder = characterListFrame:FindFirstChild("SelectedButtonLayoutOrder")
	if not selectedButtonLayoutOrder or not selectedButtonLayoutOrder:IsA("NumberValue") then
		return
	end

	-- Deselect the currently selected button by resetting its background color to the default color
	for _, frame in pairs(characterListFrame:GetChildren()) do
		local associatedCharValue = frame:FindFirstChild("AssociatedCharacter")
		if not frame:IsA("Frame") or not associatedCharValue or not associatedCharValue:IsA("ObjectValue") then
			continue
		end

		if frame.LayoutOrder == selectedButtonLayoutOrder.Value then
			frame.BackgroundColor3 = getDefaultBackgroundColor(associatedCharValue.Value :: _TYPES.Character)
		end
	end

	selectedButtonLayoutOrder.Value = 0
end

return {
	CreateCharButton = createCharButton,
	CreateCharacterList = createCharacterList,
	RemoveCharButton = removeCharButton,
	AddCharButton = addCharButton,
	SwitchCharButton = switchCharButton,
	ResetSelectedLayoutOrder = resetSelectedLayoutOrder,
}
