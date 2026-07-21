local function getManaScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

local FILL_POSITION_OFFSET = 0.008 -- The scale of the mana bar fill relative to the mana bar frame size
local FILL_SIZE_X_OFFSET = 1 - (FILL_POSITION_OFFSET * 2) -- The scale of the mana bar fill relative to the mana bar frame size
local FILL_SIZE_Y_SCALE = 0.9

return function()
	local manaFrame = Instance.new("Frame")
	manaFrame.Name = "UI_ManaFrame"
	manaFrame.BackgroundTransparency = 1
	manaFrame.Position = UDim2.fromScale(0.63, 0.85)
	manaFrame.Size = UDim2.fromScale(0.173, 0.072)

	local playerMaxManaValue = Instance.new("NumberValue")
	playerMaxManaValue.Name = "PlayerMaxManaValue"
	playerMaxManaValue.Value = 100 -- Set the default max mana value to 100
	playerMaxManaValue.Parent = manaFrame

	local playerCurrentManaValue = Instance.new("NumberValue")
	playerCurrentManaValue.Name = "PlayerCurrentManaValue"
	playerCurrentManaValue.Parent = manaFrame

	local manaCount = Instance.new("TextLabel")
	manaCount.Name = "Mana_Count"
	manaCount.BackgroundTransparency = 1
	manaCount.Position = UDim2.fromScale(0.36, 0.2)
	manaCount.Size = UDim2.fromScale(0.4, 0.4)
	manaCount.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	manaCount.Text = "80/100"
	manaCount.TextColor3 = Color3.new(1, 1, 1)
	manaCount.TextSize = 17
	manaCount.TextStrokeColor3 = Color3.new(1, 1, 1)
	manaCount.TextScaled = true
	manaCount.Parent = manaFrame

	local manaBar = Instance.new("Frame")
	manaBar.Name = "PlayerInfo_ManaBar"
	manaBar.BackgroundTransparency = 1
	manaBar.Position = UDim2.fromScale(0, 0.6)
	manaBar.Size = UDim2.fromScale(1, 0.5)
	manaBar.ClipsDescendants = true

	local manaBorder = Instance.new("Frame")
	manaBorder.Name = "PlayerInfo_ManaBorder"
	manaBorder.BackgroundTransparency = 1
	manaBorder.Size = UDim2.fromScale(1, 1)

	local manaBorderImageLabel = Instance.new("ImageLabel")
	manaBorderImageLabel.Name = "ImageLabel"
	manaBorderImageLabel.BackgroundTransparency = 1
	manaBorderImageLabel.Image = "rbxassetid://84100549722129"
	manaBorderImageLabel.Size = UDim2.fromScale(1, 1)

	local manaBorderUIGradient = Instance.new("UIGradient")
	manaBorderUIGradient.Name = "UIGradient"
	manaBorderUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	manaBorderUIGradient.Parent = manaBorderImageLabel

	manaBorderImageLabel.Parent = manaBorder

	manaBorder.Parent = manaBar

	local manaFill = Instance.new("Frame")
	manaFill.Name = "PlayerInfo_ManaFill"
	manaFill.AnchorPoint = Vector2.new(0, 0.5)
	manaFill.BackgroundTransparency = 1
	manaFill.ClipsDescendants = true
	manaFill.Position = UDim2.fromScale(0.008, 0.5)
	manaFill.Size = UDim2.fromScale(0.984, 0.9)

	local manaFillImageLabel = Instance.new("ImageLabel")
	manaFillImageLabel.Name = "ImageLabel"
	manaFillImageLabel.BackgroundTransparency = 1
	manaFillImageLabel.Image = "rbxassetid://93013412082634"
	manaFillImageLabel.Size = UDim2.fromScale(1, 1)

	-- Update the mana bar background size when the absolute size of the mana bar frame changes (e.g. due to screen resizing)
	manaBorder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		manaFillImageLabel.Size = UDim2.new(1, 0, 0, manaBorder.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	end)

	local manaFillGradient = Instance.new("UIGradient")
	manaFillGradient.Name = "UIGradient"
	manaFillGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 175, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 247, 255)),
	})
	manaFillGradient.Parent = manaFillImageLabel

	manaFillImageLabel.Parent = manaFill

	manaFill.Parent = manaBar

	local manaBarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	manaBarAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	manaBarAspectRatioConstraint.AspectRatio = 10.427
	manaBarAspectRatioConstraint.Parent = manaBar

	manaBar.Parent = manaFrame

	-- Listens to mana changed events to update the manabar fill
	playerCurrentManaValue.Changed:Connect(function()
		-- Recalculate the manabar fill size based on the new mana value
		local manaScale = getManaScale(playerCurrentManaValue.Value, playerMaxManaValue.Value)

		-- Update the manabar fill size based on the new mana value
		manaFill.Size = UDim2.fromScale(manaScale * FILL_SIZE_X_OFFSET, FILL_SIZE_Y_SCALE)

		-- Update the label that shows the current mana value
		manaCount.Text = tostring(math.floor(playerCurrentManaValue.Value))
			.. "/"
			.. tostring(math.floor(playerMaxManaValue.Value)) -- Do not display decimal places for mana values
	end)

	local manaPreview = Instance.new("TextLabel")
	manaPreview.Name = "Mana_PreviewLabel"
	manaPreview.BackgroundTransparency = 1
	manaPreview.Position = UDim2.fromScale(0.17, 0.28)
	manaPreview.Size = UDim2.fromScale(0.3, 0.3)
	manaPreview.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	manaPreview.Text = "+15"
	manaPreview.TextSize = 12
	manaPreview.TextStrokeColor3 = Color3.new(1, 1, 1)
	manaPreview.TextScaled = true
	manaPreview.Parent = manaFrame

	return manaFrame
end
