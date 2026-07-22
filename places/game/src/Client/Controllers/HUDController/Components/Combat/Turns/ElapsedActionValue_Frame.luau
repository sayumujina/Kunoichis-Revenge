return function()
	local elapsedActionValue = Instance.new("Frame")
	elapsedActionValue.Name = "UI_ElapsedActionValue"
	elapsedActionValue.BackgroundColor3 = Color3.new(1, 1, 1)
	elapsedActionValue.BorderColor3 = Color3.new()
	elapsedActionValue.BorderSizePixel = 0
	elapsedActionValue.Position = UDim2.fromScale(0.02, 0.02)
	elapsedActionValue.Size = UDim2.fromScale(0.18, 0.04)

	local elapsedActionValueValue = Instance.new("NumberValue")
	elapsedActionValueValue.Name = "ElapsedActionValue_Value"
	elapsedActionValueValue.Value = 0
	elapsedActionValueValue.Parent = elapsedActionValue

	local elapsedActionValueLabel = Instance.new("TextLabel")
	elapsedActionValueLabel.Name = "ElapsedActionValue_Label"
	elapsedActionValueLabel.BackgroundTransparency = 1
	elapsedActionValueLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	elapsedActionValueLabel.Position = UDim2.fromScale(0.052, 0.1)
	elapsedActionValueLabel.Size = UDim2.fromScale(0.8, 0.8)
	elapsedActionValueLabel.Text = "Consumed AV: 0"
	elapsedActionValueLabel.TextColor3 = Color3.new(1, 1, 1)
	elapsedActionValueLabel.TextScaled = true
	elapsedActionValueLabel.TextXAlignment = Enum.TextXAlignment.Left
	elapsedActionValueValue.Changed:Connect(function()
		elapsedActionValueLabel.Text = "Consumed AV: " .. tostring(math.ceil(elapsedActionValueValue.Value))
	end)

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.Parent = elapsedActionValueLabel

	elapsedActionValueLabel.Parent = elapsedActionValue

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "UIGradient"
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.35, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	uIGradient.Parent = elapsedActionValue

	return elapsedActionValue
end
