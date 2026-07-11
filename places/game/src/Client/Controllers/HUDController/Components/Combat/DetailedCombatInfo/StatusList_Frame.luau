local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)

local function getNumberOfStatusesFor(statusFrame: Frame)
	local count = 0
	for _, child in pairs(statusFrame:GetChildren()) do
		if child:IsA("Frame") and child.Name == "Status" then
			count += 1
		end
	end
	return count
end

local function getStatusListFrameForCharacter(char: _TYPES.Character): Frame?
	local detailedCombatInfoScreenGui =
		game.Players.LocalPlayer.PlayerGui:FindFirstChild("DetailedCombatInfo_ScreenGui")
	if not detailedCombatInfoScreenGui then
		warn("DetailedCombatInfo_ScreenGui not found in PlayerGui")
		return nil
	end
	warn(
		"number of chars ",
		#game.Players:GetPlayers(),
		"number of children in statusListFrame: ",
		#detailedCombatInfoScreenGui:QueryDescendants("#StatusList_Frame")
	)

	for _, statusListFrame in pairs(detailedCombatInfoScreenGui:QueryDescendants("#StatusList_Frame")) do
		if statusListFrame.Name ~= "StatusList_Frame" then
			continue
		end

		local associatedCharValue = statusListFrame:FindFirstChild("AssociatedCharValue")
		warn("Checking statusListFrame:", statusListFrame, "AssociatedCharValue:", associatedCharValue.Value, char)
		if associatedCharValue and associatedCharValue:IsA("ObjectValue") and associatedCharValue.Value == char then
			return statusListFrame
		end
	end

	warn("StatusList_Frame not found for character", char)
	return nil
end

--- Creates a status frame for the status list.
--- @param name -- The name of the status.
--- @param description -- The description of the status.
local function createStatusFrame(id: string, name: string, description: string)
	local statusFrame = Instance.new("Frame")
	statusFrame.Name = "Status"
	statusFrame.AutomaticSize = Enum.AutomaticSize.Y
	statusFrame.BackgroundTransparency = 1
	statusFrame.LayoutOrder = getNumberOfStatusesFor(statusFrame)
	statusFrame.Size = UDim2.fromScale(1, 0)

	local statusInfoLabel = Instance.new("TextLabel")
	statusInfoLabel.Name = "StatusInfo_Label"
	statusInfoLabel.AutomaticSize = Enum.AutomaticSize.Y
	statusInfoLabel.BackgroundTransparency = 1
	statusInfoLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	statusInfoLabel.Interactable = false
	statusInfoLabel.LayoutOrder = 2
	statusInfoLabel.Position = UDim2.fromScale(0, 0.35)
	statusInfoLabel.Size = UDim2.fromScale(1, 0)
	statusInfoLabel.Text = description
	statusInfoLabel.TextColor3 = Color3.new(1, 1, 1)
	statusInfoLabel.TextDirection = Enum.TextDirection.LeftToRight
	statusInfoLabel.TextSize = 24
	statusInfoLabel.TextWrapped = true
	statusInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
	statusInfoLabel.Parent = statusFrame

	local statusIdValue = Instance.new("StringValue")
	statusIdValue.Name = "StatusId"
	statusIdValue.Value = id
	statusIdValue.Parent = statusFrame

	local statusNameFrame = Instance.new("Frame")
	statusNameFrame.Name = "StatusName"
	statusNameFrame.AutomaticSize = Enum.AutomaticSize.XY
	statusNameFrame.BackgroundTransparency = 1
	statusNameFrame.LayoutOrder = 1
	statusNameFrame.Size = UDim2.fromScale(1, 0)

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImageLabel"
	imageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	imageLabel.BorderColor3 = Color3.new()
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	imageLabel.Size = UDim2.fromScale(1, 1)

	local uISizeConstraint = Instance.new("UISizeConstraint")
	uISizeConstraint.Name = "UISizeConstraint"
	uISizeConstraint.MinSize = Vector2.new(50, 50)
	uISizeConstraint.Parent = imageLabel

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint.Parent = imageLabel

	imageLabel.Parent = statusNameFrame

	local statusNameLabel = Instance.new("TextLabel")
	statusNameLabel.Name = "StatusName_Label"
	statusNameLabel.AutomaticSize = Enum.AutomaticSize.X
	statusNameLabel.BackgroundTransparency = 1
	statusNameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	statusNameLabel.Interactable = false
	statusNameLabel.Position = UDim2.fromScale(0.13, 0)
	statusNameLabel.Size = UDim2.fromScale(0.9, 1)
	statusNameLabel.Text = name
	statusNameLabel.TextColor3 = Color3.new(1, 1, 1)
	statusNameLabel.TextDirection = Enum.TextDirection.LeftToRight
	statusNameLabel.TextSize = 36
	statusNameLabel.TextWrapped = true
	statusNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusNameLabel.Parent = statusNameFrame

	statusNameFrame.Parent = statusFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = statusFrame

	return statusFrame
end

--- Adds a status to the status list frame.
--- @param statusId -- The ID of the status.
--- @param statusName -- The name of the status.
--- @param statusDescription -- The description of the status.
local function addStatusToList(char: _TYPES.Character, statusId: string, statusName: string, statusDescription: string)
	local statusListFrame = getStatusListFrameForCharacter(char)
	if not statusListFrame then
		return
	end

	for _, existingStatusFrame in pairs(statusListFrame:GetChildren()) do
		if not existingStatusFrame:IsA("Frame") then
			continue
		end

		local statusIdValue = existingStatusFrame:FindFirstChild("StatusId")
		if statusIdValue and statusIdValue:IsA("StringValue") and statusIdValue.Value == statusId then
			return
		end
	end

	local statusFrame = createStatusFrame(statusId, statusName, statusDescription)
	statusFrame.LayoutOrder = getNumberOfStatusesFor(statusListFrame) + 1
	statusFrame.Parent = statusListFrame
end

--- Removes a status from the status list frame.
--- @param statusId -- The ID of the status to remove.
local function removeStatusFromList(char: _TYPES.Character, statusId: string)
	local statusListFrame = getStatusListFrameForCharacter(char)
	if not statusListFrame then
		return
	end

	local removedLayoutOrder = nil

	-- Remove the status frame with the given ID
	for _, statusFrame in pairs(statusListFrame:GetChildren()) do
		if not statusFrame:IsA("Frame") then
			continue
		end

		local statusIdValue = statusFrame:FindFirstChild("StatusId")
		if statusIdValue and statusIdValue.Value == statusId then
			removedLayoutOrder = statusFrame.LayoutOrder
			statusFrame:Destroy()
			break
		end
	end

	-- Reorder the remaining status frames
	-- Subtract 1 from the LayoutOrder of each remaining status frame that has a LayoutOrder greater than the removed status frame's LayoutOrder
	for _, statusFrame in ipairs(statusListFrame:GetChildren()) do
		if not statusFrame:IsA("Frame") then
			continue
		end

		if removedLayoutOrder and statusFrame.LayoutOrder > removedLayoutOrder then
			statusFrame.LayoutOrder -= 1
		end
	end
end

--- Creates a status list frame for the character.
--- @param char -- The character for whom the status list frame is created.
local function createStatusListFrame(char: _TYPES.Character)
	local statusListFrame = Instance.new("Frame")
	statusListFrame.Name = "StatusList_Frame"
	statusListFrame.AutomaticSize = Enum.AutomaticSize.Y
	statusListFrame.BackgroundColor3 = Color3.fromRGB(185, 185, 185)
	statusListFrame.BackgroundTransparency = 0.7
	statusListFrame.Interactable = false
	statusListFrame.LayoutOrder = 4
	statusListFrame.Size = UDim2.fromScale(0.9, 0)

	local associatedCharValue = Instance.new("ObjectValue")
	associatedCharValue.Name = "AssociatedCharValue"
	associatedCharValue.Value = char
	associatedCharValue.Parent = statusListFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.Padding = UDim.new(0, 30)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = statusListFrame

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingBottom = UDim.new(0, 30)
	uIPadding.PaddingLeft = UDim.new(0.04, 0)
	uIPadding.PaddingRight = UDim.new(0.04, 0)
	uIPadding.PaddingTop = UDim.new(0, 30)
	uIPadding.Parent = statusListFrame

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = statusListFrame

	return statusListFrame
end

return {
	CreateStatusListFrame = createStatusListFrame,
	AddStatusToList = addStatusToList,
	RemoveStatusFromList = removeStatusFromList,
}
