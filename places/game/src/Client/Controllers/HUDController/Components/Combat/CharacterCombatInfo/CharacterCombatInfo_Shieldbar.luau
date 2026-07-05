local function getShieldScale(currentShield: number, maxHP: number): number
	if maxHP <= 0 then
		return 0
	end

	return math.clamp(currentShield / maxHP, 0, 1)
end

local FILL_POSITION_OFFSET = 0.008 -- The scale of the shieldbar fill relative to the shieldbar frame size
local FILL_SIZE_X_OFFSET = FILL_POSITION_OFFSET * 2 -- The scale of the shieldbar fill relative to the shieldbar frame size
local FILL_SIZE_Y_SCALE = 0.9

return function()
	local shieldbarFrame = Instance.new("Frame")
	shieldbarFrame.Name = "CharacterInfo_Shieldbar"
	shieldbarFrame.BackgroundTransparency = 1
	shieldbarFrame.Position = UDim2.fromScale(0.005, 0.669)
	shieldbarFrame.Size = UDim2.fromScale(0.964, 0.1344)
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
	shieldbarFill.ZIndex = 2

	local shieldbarFillImageLabel = Instance.new("ImageLabel")
	shieldbarFillImageLabel.Name = "ImageLabel"
	shieldbarFillImageLabel.BackgroundTransparency = 1
	shieldbarFillImageLabel.Image = "rbxassetid://93013412082634"
	shieldbarFillImageLabel.ImageColor3 = Color3.new(1, 1, 1)
	shieldbarFillImageLabel.ImageTransparency = 0.1
	shieldbarFillImageLabel.Size = UDim2.new(1, 0, 0, shieldbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	shieldbarFillImageLabel.ZIndex = 2

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

	local function updateShieldbar()
		local container = shieldbarFrame.Parent
		if not container then
			return
		end

		local characterMaxHPValue = container:FindFirstChild("CharacterMaxHPValue", true)
		if not characterMaxHPValue or not characterMaxHPValue:IsA("NumberValue") then
			return
		end

		local shieldScale = getShieldScale(currentShieldValue.Value, characterMaxHPValue.Value)
		shieldbarFill.Size = UDim2.fromScale(shieldScale - FILL_SIZE_X_OFFSET, FILL_SIZE_Y_SCALE)
		shieldbarFrame.Visible = currentShieldValue.Value > 0
	end

	local maxHPChangedConnection: RBXScriptConnection? = nil
	local function bindMaxHPListener()
		local container = shieldbarFrame.Parent
		if not container then
			return
		end

		local characterMaxHPValue = container:FindFirstChild("CharacterMaxHPValue", true)
		if not characterMaxHPValue or not characterMaxHPValue:IsA("NumberValue") then
			return
		end

		if maxHPChangedConnection then
			maxHPChangedConnection:Disconnect()
		end

		maxHPChangedConnection = characterMaxHPValue.Changed:Connect(updateShieldbar)
		updateShieldbar()
	end

	currentShieldValue.Changed:Connect(updateShieldbar)
	shieldbarFrame:GetPropertyChangedSignal("Parent"):Connect(bindMaxHPListener)

	return shieldbarFrame
end
