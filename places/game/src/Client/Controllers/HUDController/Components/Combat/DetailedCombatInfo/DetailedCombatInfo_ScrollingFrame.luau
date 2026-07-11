local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)

local StatusListFrame = require(script.Parent.StatusList_Frame)
local CreatePlayablesInfoFrame = require(script.Parent.Playables_Info_Frame)
local CreateNPCsInfoFrame = require(script.Parent.NPCs_Info_Frame)
local DetailedStatsFrame = require(script.Parent.DetailedStats_Frame)

--- Shows the detailed combat info for a character by hiding all other character's detailed combat info scrolling frames and showing the selected character's scrolling frame
--- @param char -- The character to show the detailed combat info for
local function showCharDetailedCombat(char: _TYPES.Character)
	local detailedCombatInfoScreenGui =
		game.Players.LocalPlayer.PlayerGui:FindFirstChild("DetailedCombatInfo_ScreenGui")
	if not detailedCombatInfoScreenGui then
		warn("DetailedCombatInfo_ScreenGui not found in PlayerGui")
		return
	end

	-- Find the currently enabled scrolling frame for the character and hide it, if it exists
	-- And then show the scrolling frame for the newly selected character
	for _, child in pairs(detailedCombatInfoScreenGui:QueryDescendants("ScrollingFrame")) do
		local associatedCharValue = child:FindFirstChild("AssociatedCharValue")
		if associatedCharValue and associatedCharValue.Value == char then
			child.Visible = true
		else
			child.Visible = false
		end
	end
end

local function createDetailedCombatInfoScrollingFrame(char: _TYPES.Character)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "DetailedCombatInfo_ScrollingFrame_" .. char.Name
	scrollingFrame.Active = true
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	scrollingFrame.BackgroundTransparency = 0
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.CanvasSize = UDim2.fromScale(0, 1)
	scrollingFrame.Position = UDim2.fromScale(0.6, 0)
	scrollingFrame.ScrollBarImageColor3 = Color3.new()
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.Size = UDim2.fromScale(0.4, 1)
	scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scrollingFrame.Visible = false

	local associatedCharValue = Instance.new("ObjectValue")
	associatedCharValue.Name = "AssociatedCharValue"
	associatedCharValue.Value = char
	associatedCharValue.Parent = scrollingFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.Padding = UDim.new(0.04, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = scrollingFrame

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingTop = UDim.new(0.04, 0)
	uIPadding.Parent = scrollingFrame

	local infoFrame
	if char:GetAttribute("Side") == "Playable" then
		infoFrame = CreatePlayablesInfoFrame(char)
		infoFrame.Parent = scrollingFrame

		local detailedStatsFrame = DetailedStatsFrame.CreateDetailedStatsFrame(char)
		detailedStatsFrame.Parent = scrollingFrame
	else
		infoFrame = CreateNPCsInfoFrame(char)
		infoFrame.Parent = scrollingFrame
	end

	local statusListFrame = StatusListFrame.CreateStatusListFrame(char)
	statusListFrame.Parent = scrollingFrame

	warn("Created DetailedCombatInfo_ScrollingFrame for character:", char.Name, "with parent:", scrollingFrame.Parent)
	return scrollingFrame
end

return {
	ShowCharDetailedCombat = showCharDetailedCombat,
	CreateDetailedCombatInfoScrollingFrame = createDetailedCombatInfoScrollingFrame,
}
