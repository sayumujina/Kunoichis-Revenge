local function getHPScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

local FILL_POSITION_OFFSET = 0.008 -- The scale of the healthbar fill relative to the healthbar frame size
local FILL_SIZE_X_OFFSET = FILL_POSITION_OFFSET * 2 -- The scale of the healthbar fill relative to the healthbar frame size
local FILL_SIZE_Y_SCALE = 0.9

--- @param size - The size of the healthbar frame
--- @param position - The position of the healthbar frame
return function(size: UDim2, position: UDim2)
	local characterInfoHealthbarFrame = Instance.new("Frame")
	characterInfoHealthbarFrame.Name = "CharacterInfo_Healthbar"
	characterInfoHealthbarFrame.BackgroundTransparency = 1
	characterInfoHealthbarFrame.Position = position
	characterInfoHealthbarFrame.Size = size

	local characterInfoHealthbarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	characterInfoHealthbarAspectRatioConstraint.Name = "CharacterInfo_HealthbarAspectRatioConstraint"
	characterInfoHealthbarAspectRatioConstraint.AspectRatio = 9.9484

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
	characterInfoHealthbarFill.Position = UDim2.fromScale(FILL_POSITION_OFFSET, 0.5)
	characterInfoHealthbarFill.Size = UDim2.fromScale(
		getHPScale(characterCurrentHPValue.Value, characterMaxHPValue.Value) - FILL_SIZE_X_OFFSET,
		FILL_SIZE_Y_SCALE
	)

	local characterInfoHealthbarFillImageLabel = Instance.new("ImageLabel")
	characterInfoHealthbarFillImageLabel.Name = "ImageLabel"
	characterInfoHealthbarFillImageLabel.BackgroundTransparency = 1
	characterInfoHealthbarFillImageLabel.Image = "rbxassetid://93013412082634"
	characterInfoHealthbarFillImageLabel.Size = UDim2.fromScale(1, 1)

	-- Update the healthbar background size when the absolute size of the healthbar frame changes (e.g. due to screen resizing)
	characterInfoHealthbarFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		characterInfoHealthbarFillImageLabel.Size =
			UDim2.new(1, 0, 0, characterInfoHealthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	end)

	-- Listens to hp changed events to update the healthbar fill
	characterCurrentHPValue.Changed:Connect(function()
		-- Recalculate the healthbar fill size based on the new health value
		local hpScale = getHPScale(characterCurrentHPValue.Value, characterMaxHPValue.Value)

		-- Update the healthbar fill size based on the new health value
		characterInfoHealthbarFill.Size = UDim2.fromScale(hpScale - FILL_SIZE_X_OFFSET, FILL_SIZE_Y_SCALE)

		-- Update the label that shows the current health value
		local characterInfoCard = characterInfoHealthbarFrame.Parent
		if not characterInfoCard then
			return
		end

		local characterInfoHPLabel = characterInfoCard:FindFirstChild("CharacterInfo_HPLabel", true)
		if characterInfoHPLabel then
			characterInfoHPLabel.Text = tostring(math.floor(characterCurrentHPValue.Value)) -- Do not display decimal places for health values
		end
	end)

	local characterInfoHealthbarFillUIGradient = Instance.new("UIGradient")
	characterInfoHealthbarFillUIGradient.Name = "UIGradient"
	characterInfoHealthbarFillUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 175, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 247, 255)),
	})
	characterInfoHealthbarFillUIGradient.Parent = characterInfoHealthbarFillImageLabel

	characterInfoHealthbarFillImageLabel.Parent = characterInfoHealthbarFill

	characterInfoHealthbarFill.Parent = characterInfoHealthbarFrame

	return characterInfoHealthbarFrame
end
