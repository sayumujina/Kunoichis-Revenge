local function getHPScale(current: number, max: number): number
	if max == 0 then
		return 0
	end

	return current / max
end

local FILL_POSITION_OFFSET = 0.008 -- The scale of the healthbar fill relative to the healthbar frame size
local FILL_SIZE_X_OFFSET = FILL_POSITION_OFFSET * 2 -- The scale of the healthbar fill relative to the healthbar frame size
local FILL_SIZE_Y_SCALE = 0.9
local SHIELD_TEXT_COLOR = Color3.fromRGB(255, 170, 0)

local function findOwnerContainer(container: Instance?): Instance?
	local current = container
	while current do
		local associatedCharValue = current:FindFirstChild("AssociatedCharValue")
		if associatedCharValue and associatedCharValue:IsA("ObjectValue") then
			return current
		end

		current = current.Parent
	end

	return nil
end

local function findDescendantInContainer(container: Instance?, name: string, className: string?): Instance?
	if not container then
		return nil
	end

	local descendant = container:FindFirstChild(name, true)
	if descendant and (not className or descendant:IsA(className)) then
		return descendant
	end

	return nil
end

local function updateHPLabel(container: Instance?, currentHPValue: number, maxHPValue: number)
	local ownerContainer = findOwnerContainer(container)
	local hpLabel = findDescendantInContainer(ownerContainer, "CharacterInfo_HPLabel", "TextLabel")
	if not hpLabel or not hpLabel:IsA("TextLabel") then
		return
	end

	hpLabel.RichText = true

	local currentShieldValue = findDescendantInContainer(ownerContainer, "CharacterCurrentShieldValue", "NumberValue")
	if currentShieldValue and currentShieldValue:IsA("NumberValue") and currentShieldValue.Value > 0 then
		hpLabel.Text = string.format(
			'%d + <font color="rgb(%d,%d,%d)">%d</font> / %d',
			math.ceil(currentHPValue),
			SHIELD_TEXT_COLOR.R * 255,
			SHIELD_TEXT_COLOR.G * 255,
			SHIELD_TEXT_COLOR.B * 255,
			math.ceil(currentShieldValue.Value),
			math.ceil(maxHPValue)
		)
	else
		hpLabel.Text = string.format("%d / %d", math.ceil(currentHPValue), math.ceil(maxHPValue))
	end
end

--- @param size - The size of the healthbar frame
--- @param position - The position of the healthbar frame
--- @param ignoreBorder - Whether to skip rendering the healthbar border
return function(size: UDim2, position: UDim2, ignoreBorder: boolean?)
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

	if not ignoreBorder then
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
	end

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

	healthbarFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		healthbarFillImageLabel.Size = UDim2.new(1, 0, 0, healthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	end)

	local shieldValueChangedConnection: RBXScriptConnection? = nil
	local ownerDescendantAddedConnection: RBXScriptConnection? = nil
	local ownerDescendantRemovingConnection: RBXScriptConnection? = nil

	local function bindShieldValueListener()
		if shieldValueChangedConnection then
			shieldValueChangedConnection:Disconnect()
			shieldValueChangedConnection = nil
		end

		local ownerContainer = findOwnerContainer(healthbarFrame.Parent)
		local currentShieldValue = findDescendantInContainer(ownerContainer, "CharacterCurrentShieldValue", "NumberValue")
		if currentShieldValue and currentShieldValue:IsA("NumberValue") then
			shieldValueChangedConnection = currentShieldValue.Changed:Connect(function()
				updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
			end)
		end
	end

	local function bindOwnerContainerListeners()
		if ownerDescendantAddedConnection then
			ownerDescendantAddedConnection:Disconnect()
			ownerDescendantAddedConnection = nil
		end

		if ownerDescendantRemovingConnection then
			ownerDescendantRemovingConnection:Disconnect()
			ownerDescendantRemovingConnection = nil
		end

		local ownerContainer = findOwnerContainer(healthbarFrame.Parent)
		if not ownerContainer then
			return
		end

		ownerDescendantAddedConnection = ownerContainer.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "CharacterCurrentShieldValue" and descendant:IsA("NumberValue") then
				bindShieldValueListener()
				updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
			end
		end)

		ownerDescendantRemovingConnection = ownerContainer.DescendantRemoving:Connect(function(descendant)
			if descendant.Name == "CharacterCurrentShieldValue" and descendant:IsA("NumberValue") then
				bindShieldValueListener()
				updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
			end
		end)
	end

	local function updateHealthbar()
		local hpScale = getHPScale(currentHPValue.Value, maxHPValue.Value)
		healthbarFill.Size = UDim2.fromScale(math.max(hpScale - FILL_SIZE_X_OFFSET, 0), FILL_SIZE_Y_SCALE)
		updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
	end

	currentHPValue.Changed:Connect(updateHealthbar)
	maxHPValue.Changed:Connect(updateHealthbar)
	healthbarFrame:GetPropertyChangedSignal("Parent"):Connect(function()
		bindOwnerContainerListeners()
		bindShieldValueListener()
		updateHealthbar()
	end)
	healthbarFrame.AncestryChanged:Connect(function()
		bindOwnerContainerListeners()
		bindShieldValueListener()
		updateHealthbar()
	end)
	bindOwnerContainerListeners()
	bindShieldValueListener()
	updateHealthbar()

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
