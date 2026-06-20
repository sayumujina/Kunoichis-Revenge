local function getHPScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

return function()
	local characterInfoHealthbarFrame = Instance.new("Frame")
	characterInfoHealthbarFrame.Name = "CharacterInfo_Healthbar"
	characterInfoHealthbarFrame.BackgroundTransparency = 1
	characterInfoHealthbarFrame.Position = UDim2.fromScale(0.005, 0.669)
	characterInfoHealthbarFrame.Size = UDim2.fromScale(0.964, 0.1344)

	local characterMaxHPValue = Instance.new("NumberValue")
	characterMaxHPValue.Name = "CharacterMaxHPValue"
	characterMaxHPValue.Parent = characterInfoHealthbarFrame

	local characterCurrentHPValue = Instance.new("NumberValue")
	characterCurrentHPValue.Name = "CharacterCurrentHPValue"
	characterCurrentHPValue.Parent = characterInfoHealthbarFrame

	local characterInfoHealthbarBorder = Instance.new("Frame")
	characterInfoHealthbarBorder.Name = "CharacterInfo_HealthbarBorder"
	characterInfoHealthbarBorder.BackgroundTransparency = 1
	characterInfoHealthbarBorder.Size = UDim2.fromScale(1, 1)

	local characterInfoHealthbarBorderImageLabel = Instance.new("ImageLabel")
	characterInfoHealthbarBorderImageLabel.Name = "ImageLabel"
	characterInfoHealthbarBorderImageLabel.BackgroundTransparency = 1
	characterInfoHealthbarBorderImageLabel.Image = "rbxassetid://84100549722129"
	characterInfoHealthbarBorderImageLabel.Size = UDim2.fromScale(1, 1)

	local characterInfoHealthbarBorderUIGradient = Instance.new("UIGradient")
	characterInfoHealthbarBorderUIGradient.Name = "UIGradient"
	characterInfoHealthbarBorderUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	characterInfoHealthbarBorderUIGradient.Parent = characterInfoHealthbarBorderImageLabel

	characterInfoHealthbarBorderImageLabel.Parent = characterInfoHealthbarBorder

	characterInfoHealthbarBorder.Parent = characterInfoHealthbarFrame

	local characterInfoHealthbarFill = Instance.new("Frame")
	characterInfoHealthbarFill.Name = "CharacterInfo_HealthbarFill"
	characterInfoHealthbarFill.AnchorPoint = Vector2.new(0, 0.5)
	characterInfoHealthbarFill.BackgroundTransparency = 1
	characterInfoHealthbarFill.ClipsDescendants = true
	characterInfoHealthbarFill.Position = UDim2.fromScale(-2.84956e-08, 0.5)
	characterInfoHealthbarFill.Size =
		UDim2.fromScale(getHPScale(characterCurrentHPValue.Value, characterMaxHPValue.Value), 1)

	local characterInfoHealthbarFillImageLabel = Instance.new("ImageLabel")
	characterInfoHealthbarFillImageLabel.Name = "ImageLabel"
	characterInfoHealthbarFillImageLabel.BackgroundTransparency = 1
	characterInfoHealthbarFillImageLabel.Image = "rbxassetid://93013412082634"
	characterInfoHealthbarFillImageLabel.Size = UDim2.fromScale(1, 1)

	-- Update the healthbar background size when the absolute size of the healthbar frame changes (e.g. due to screen resizing)
	characterInfoHealthbarFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		characterInfoHealthbarFillImageLabel.Size = UDim2.new(1, 0, 0, characterInfoHealthbarFrame.AbsoluteSize.Y)
	end)

	-- Listens to hp changed events to update the healthbar fill
	characterCurrentHPValue.Changed:Connect(function()
		-- Recalculate the healthbar fill size based on the new health value
		local hpScale = getHPScale(characterCurrentHPValue.Value, characterMaxHPValue.Value)

		-- Update the healthbar fill size based on the new health value
		characterInfoHealthbarFill.Size = UDim2.fromScale(hpScale, 1)

		-- Update the label that shows the current health value
		local characterInfoCard = characterInfoHealthbarFrame.Parent
		if not characterInfoCard then
			return
		end

		local characterInfoHPLabel = characterInfoCard:FindFirstChild("CharacterInfo_HPLabel", true)
		if characterInfoHPLabel then
			characterInfoHPLabel.Text = tostring(characterCurrentHPValue.Value)
		end
	end)

	local characterInfoHealthbarFillUIGradient = Instance.new("UIGradient")
	characterInfoHealthbarFillUIGradient.Name = "UIGradient"
	characterInfoHealthbarFillUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0.066667, 0.901961, 0.760784)),
		ColorSequenceKeypoint.new(1, Color3.new(0.066667, 0.901961, 0.760784)),
	})
	characterInfoHealthbarFillUIGradient.Parent = characterInfoHealthbarFillImageLabel

	characterInfoHealthbarFillImageLabel.Parent = characterInfoHealthbarFill

	characterInfoHealthbarFill.Parent = characterInfoHealthbarFrame

	return characterInfoHealthbarFrame
end
