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
	local healthbarFrame = Instance.new("Frame")
	healthbarFrame.Name = "CharacterInfo_Healthbar"
	healthbarFrame.BackgroundTransparency = 1
	healthbarFrame.Position = position
	healthbarFrame.Size = size

	local healthbarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	healthbarAspectRatioConstraint.Name = "CharacterInfo_HealthbarAspectRatioConstraint"
	healthbarAspectRatioConstraint.AspectRatio = 9.9484

	local maxHPValue = Instance.new("NumberValue")
	maxHPValue.Name = "CharacterMaxHPValue"
	maxHPValue.Parent = healthbarFrame

	local currentHPValue = Instance.new("NumberValue")
	currentHPValue.Name = "CharacterCurrentHPValue"
	currentHPValue.Parent = healthbarFrame

	local healthbarBorder = Instance.new("Frame")
	healthbarBorder.Name = "CharacterInfo_HealthbarBorder"
	healthbarBorder.BackgroundTransparency = 1
	healthbarBorder.Size = UDim2.fromScale(1, 1)

	local healthbarBorderImageLabel = Instance.new("ImageLabel")
	healthbarBorderImageLabel.Name = "ImageLabel"
	healthbarBorderImageLabel.BackgroundTransparency = 1
	healthbarBorderImageLabel.Image = "rbxassetid://84100549722129"
	healthbarBorderImageLabel.Size = UDim2.fromScale(1, 1)

	local healthbarBorderUIGradient = Instance.new("UIGradient")
	healthbarBorderUIGradient.Name = "UIGradient"
	healthbarBorderUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	healthbarBorderUIGradient.Parent = healthbarBorderImageLabel

	healthbarBorderImageLabel.Parent = healthbarBorder

	healthbarBorder.Parent = healthbarFrame

	local healthbarFill = Instance.new("Frame")
	healthbarFill.Name = "CharacterInfo_HealthbarFill"
	healthbarFill.AnchorPoint = Vector2.new(0, 0.5)
	healthbarFill.BackgroundTransparency = 1
	healthbarFill.ClipsDescendants = true
	healthbarFill.Position = UDim2.fromScale(FILL_POSITION_OFFSET, 0.5)
	healthbarFill.Size =
		UDim2.fromScale(getHPScale(currentHPValue.Value, maxHPValue.Value) - FILL_SIZE_X_OFFSET, FILL_SIZE_Y_SCALE)

	local healthbarFillImageLabel = Instance.new("ImageLabel")
	healthbarFillImageLabel.Name = "ImageLabel"
	healthbarFillImageLabel.BackgroundTransparency = 1
	healthbarFillImageLabel.Image = "rbxassetid://93013412082634"
	healthbarFillImageLabel.Size = UDim2.new(1, 0, 0, healthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)

	-- Update the healthbar background size when the absolute size of the healthbar frame changes (e.g. due to screen resizing)
	healthbarFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		healthbarFillImageLabel.Size = UDim2.new(1, 0, 0, healthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	end)

	-- Listens to hp changed events to update the healthbar fill
	currentHPValue.Changed:Connect(function()
		-- Recalculate the healthbar fill size based on the new health value
		local hpScale = getHPScale(currentHPValue.Value, maxHPValue.Value)

		-- Update the healthbar fill size based on the new health value
		healthbarFill.Size = UDim2.fromScale(hpScale - FILL_SIZE_X_OFFSET, FILL_SIZE_Y_SCALE)

		-- Update the label that shows the current health value
		local characterInfoCard = healthbarFrame.Parent
		if not characterInfoCard then
			return
		end

		local hpLabel = characterInfoCard:FindFirstChild("CharacterInfo_HPLabel", true)
		if hpLabel then
			hpLabel.Text = tostring(math.floor(currentHPValue.Value)) -- Do not display decimal places for health values
		end
	end)

	local healthbarFillUIGradient = Instance.new("UIGradient")
	healthbarFillUIGradient.Name = "UIGradient"
	healthbarFillUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 175, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 247, 255)),
	})
	healthbarFillUIGradient.Parent = healthbarFillImageLabel

	healthbarFillImageLabel.Parent = healthbarFill

	healthbarFill.Parent = healthbarFrame

	return healthbarFrame
end
