return function()
	local characterInfoFrame = Instance.new("Frame")
	characterInfoFrame.Name = "UI_CharacterInfoFrame"
	characterInfoFrame.Active = true
	characterInfoFrame.AnchorPoint = Vector2.new(0, 0.5)
	characterInfoFrame.BackgroundColor3 = Color3.new()
	characterInfoFrame.BackgroundTransparency = 0.9
	characterInfoFrame.BorderSizePixel = 0
	characterInfoFrame.Position = UDim2.fromScale(0.02, 0.88)
	characterInfoFrame.Size = UDim2.fromScale(0.8, 0.246)

	local characterInfoFrameAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	characterInfoFrameAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	characterInfoFrameAspectRatioConstraint.AspectRatio = 4.28
	characterInfoFrameAspectRatioConstraint.Parent = characterInfoFrame

	local characterInfoFrameListLayout = Instance.new("UIListLayout")
	characterInfoFrameListLayout.Name = "UIListLayout"
	characterInfoFrameListLayout.FillDirection = Enum.FillDirection.Horizontal
	characterInfoFrameListLayout.Padding = UDim.new(0.01, 0)
	characterInfoFrameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	characterInfoFrameListLayout.Parent = characterInfoFrame
	characterInfoFrameListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

	return characterInfoFrame
end
