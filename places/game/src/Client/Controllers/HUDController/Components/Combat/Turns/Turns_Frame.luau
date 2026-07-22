local CreateElapsedActionValue = require(script.Parent.ElapsedActionValue_Frame)

-- Helper function to create the turn card container
return function()
	local uiTurnsFrame = Instance.new("Frame")
	uiTurnsFrame.Name = "UI_TurnsFrame"
	uiTurnsFrame.Active = true
	uiTurnsFrame.BackgroundTransparency = 1
	uiTurnsFrame.Position = UDim2.fromScale(0.02, 0.07)
	uiTurnsFrame.Size = UDim2.fromScale(0.2, 0.6)
	uiTurnsFrame.ClipsDescendants = true

	local leftBorder = Instance.new("Frame")
	leftBorder.Name = "Left_Border"
	leftBorder.AnchorPoint = Vector2.new(0, 0.5)
	leftBorder.BackgroundColor3 = Color3.new(1, 1, 1)
	leftBorder.BorderColor3 = Color3.new()
	leftBorder.BorderSizePixel = 0
	leftBorder.Position = UDim2.fromScale(0, 0.5)
	leftBorder.Size = UDim2.new(0, 2, 1.05, 0)

	local turnCardContainer = Instance.new("Frame")
	turnCardContainer.Name = "UI_TurnCard_Container"
	turnCardContainer.AnchorPoint = Vector2.new(1, 0)
	turnCardContainer.BackgroundTransparency = 1
	turnCardContainer.Position = UDim2.fromScale(0.94, 0)
	turnCardContainer.Size = UDim2.fromScale(0.9, 1)

	leftBorder.Parent = uiTurnsFrame
	turnCardContainer.Parent = uiTurnsFrame

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Name = "UIListLayout"
	uiListLayout.Padding = UDim.new(0.02, 0)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Parent = turnCardContainer

	uiListLayout.Parent = turnCardContainer

	return uiTurnsFrame
end
