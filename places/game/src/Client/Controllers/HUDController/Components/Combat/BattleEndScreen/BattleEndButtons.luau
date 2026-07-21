local CreateBattleEndButton = require(script.Parent.BattleEndButton)

return function(buttonNames: { "Restart" | "Return" })
	local buttonsFrame = Instance.new("Frame")
	buttonsFrame.Name = "UI_Buttons_Frame"
	buttonsFrame.BackgroundTransparency = 1
	buttonsFrame.LayoutOrder = 1
	buttonsFrame.Position = UDim2.fromScale(0.3, 0.8)
	buttonsFrame.Size = UDim2.fromScale(0.4, 0.06)

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = buttonsFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.Padding = UDim.new(0.03, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = buttonsFrame

	for _, buttonName in pairs(buttonNames) do
		local button = CreateBattleEndButton(buttonName :: "Restart" | "Return")
		button.Parent = buttonsFrame
	end
	return buttonsFrame
end
