-- Services
local TweenService = game:GetService("TweenService")

local function getShieldScale(currentShield: number, maxHP: number): number
	if maxHP <= 0 then
		return 0
	end

	return math.clamp(currentShield / maxHP, 0, 1)
end

local FILL_POSITION_OFFSET = 0.008 -- The scale of the shieldbar fill relative to the shieldbar frame size
local FILL_SIZE_X_OFFSET = 1 - (FILL_POSITION_OFFSET * 2) -- The scale of the shieldbar fill relative to the shieldbar frame size
local FILL_SIZE_Y_SCALE = 0.9

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

return function(size: UDim2?, position: UDim2?)
	local shieldbarFrame = Instance.new("Frame")
	shieldbarFrame.Name = "CharacterInfo_Shieldbar"
	shieldbarFrame.BackgroundTransparency = 1
	shieldbarFrame.Position = position or UDim2.fromScale(0.005, 0.669)
	shieldbarFrame.Size = size or UDim2.fromScale(0.964, 0.1344)
	shieldbarFrame.Visible = false
	shieldbarFrame.ZIndex = 2

	local currentShieldValue = Instance.new("NumberValue")
	currentShieldValue.Name = "CharacterCurrentShieldValue"
	currentShieldValue.Parent = shieldbarFrame

	local shieldbarFill = Instance.new("Frame")
	shieldbarFill.Name = "CharacterInfo_ShieldbarFill"
	shieldbarFill.AnchorPoint = Vector2.new(0, 0.5)
	shieldbarFill.BackgroundTransparency = 1
	shieldbarFill.ClipsDescendants = true
	shieldbarFill.Position = UDim2.fromScale(FILL_POSITION_OFFSET, 0.5)
	shieldbarFill.Size = UDim2.fromScale(0, 1)

	local shieldbarFillImageLabel = Instance.new("ImageLabel")
	shieldbarFillImageLabel.Name = "ImageLabel"
	shieldbarFillImageLabel.BackgroundTransparency = 1
	shieldbarFillImageLabel.Image = "rbxassetid://93013412082634"
	shieldbarFillImageLabel.ImageColor3 = Color3.new(1, 1, 1)
	shieldbarFillImageLabel.ImageTransparency = 0.1
	shieldbarFillImageLabel.Size = UDim2.new(1, 0, 0, shieldbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	shieldbarFillImageLabel.ZIndex = 3

	shieldbarFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		shieldbarFillImageLabel.Size = UDim2.new(1, 0, 0, shieldbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	end)

	local shieldbarFillUIGradient = Instance.new("UIGradient")
	shieldbarFillUIGradient.Name = "UIGradient"
	shieldbarFillUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	shieldbarFillUIGradient.Parent = shieldbarFillImageLabel

	shieldbarFillImageLabel.Parent = shieldbarFill
	shieldbarFill.Parent = shieldbarFrame

	local maxHPChangedConnection: RBXScriptConnection? = nil
	local ownerDescendantAddedConnection: RBXScriptConnection? = nil

	local currentTween: Tween? = nil
	local function updateShieldbar()
		local ownerContainer = findOwnerContainer(shieldbarFrame.Parent)
		local characterMaxHPValue = findDescendantInContainer(ownerContainer, "CharacterMaxHPValue", "NumberValue")
		if not characterMaxHPValue or not characterMaxHPValue:IsA("NumberValue") then
			return
		end

		local shieldScale = getShieldScale(currentShieldValue.Value, characterMaxHPValue.Value)
		-- Tween the shieldbar fill size to the new shield scale
		if currentTween then
			currentTween:Cancel()
		end

		currentTween = TweenService:Create(
			shieldbarFill,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.fromScale(math.max(shieldScale * FILL_SIZE_X_OFFSET, 0), FILL_SIZE_Y_SCALE) }
		)

		-- If the current shield value is 0 or less, play the tween before hiding the shieldbar and vice versa
		if currentShieldValue.Value <= 0 then
			currentTween:Play()
			currentTween.Completed:Once(function()
				shieldbarFrame.Visible = false
				currentTween = nil
			end)
		else
			shieldbarFrame.Visible = true
			currentTween:Play()
			currentTween.Completed:Once(function()
				currentTween = nil
			end)
		end
	end

	local function bindMaxHPListener()
		if maxHPChangedConnection then
			maxHPChangedConnection:Disconnect()
			maxHPChangedConnection = nil
		end

		local ownerContainer = findOwnerContainer(shieldbarFrame.Parent)
		local characterMaxHPValue = findDescendantInContainer(ownerContainer, "CharacterMaxHPValue", "NumberValue")
		if not characterMaxHPValue or not characterMaxHPValue:IsA("NumberValue") then
			return
		end

		maxHPChangedConnection = characterMaxHPValue.Changed:Connect(updateShieldbar)
		updateShieldbar()
	end

	local function bindOwnerContainerListeners()
		if ownerDescendantAddedConnection then
			ownerDescendantAddedConnection:Disconnect()
			ownerDescendantAddedConnection = nil
		end

		local ownerContainer = findOwnerContainer(shieldbarFrame.Parent)
		if not ownerContainer then
			return
		end

		ownerDescendantAddedConnection = ownerContainer.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "CharacterMaxHPValue" and descendant:IsA("NumberValue") then
				bindMaxHPListener()
			end
		end)
	end

	currentShieldValue.Changed:Connect(updateShieldbar)
	bindOwnerContainerListeners()
	bindMaxHPListener()

	return shieldbarFrame
end
