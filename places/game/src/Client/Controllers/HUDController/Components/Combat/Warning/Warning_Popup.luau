return function(message: string)
	local warningPopup = Instance.new("Frame")
	warningPopup.Name = "Warning_Popup"
	warningPopup.BackgroundColor3 = Color3.new(1, 1, 1)
	warningPopup.BorderColor3 = Color3.new()
	warningPopup.BorderSizePixel = 0
	warningPopup.ClipsDescendants = true
	warningPopup.Position = UDim2.fromScale(0.2, 0.2)
	warningPopup.Size = UDim2.fromScale(0.6, 0.05)
	warningPopup.BackgroundTransparency = 1

	local warningBG = Instance.new("UIGradient")
	warningBG.Name = "Warning_BG"
	warningBG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	warningBG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.35, 0.7),
		NumberSequenceKeypoint.new(0.805486, 0.70625),
		NumberSequenceKeypoint.new(1, 1),
	})
	warningBG.Parent = warningPopup

	local warningLabel = Instance.new("TextLabel")
	warningLabel.Name = "Warning_Label"
	warningLabel.BackgroundTransparency = 1
	warningLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	warningLabel.Position = UDim2.fromScale(0.2, 0.2)
	warningLabel.Size = UDim2.fromScale(0.6, 0.6)
	warningLabel.Text = message
	warningLabel.TextColor3 = Color3.new(1, 1, 1)
	warningLabel.TextScaled = true
	warningLabel.Parent = warningPopup

	return warningPopup
end
