local function getEnergyScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

return function()
    local characterInfoEnergyFrame = Instance.new("Frame")
    characterInfoEnergyFrame.Name = "CharacterInfo_Energy"
    characterInfoEnergyFrame.BackgroundTransparency = 1
    characterInfoEnergyFrame.Position = UDim2.fromScale(0.51, 0)
    characterInfoEnergyFrame.Size = UDim2.fromScale(0.63, 0.63)

    local characterCurrentEnergyValue = Instance.new("NumberValue")
    characterCurrentEnergyValue.Name = "CharacterCurrentEnergyValue"
    characterCurrentEnergyValue.Parent = characterInfoEnergyFrame

    local characterMaxEnergyValue = Instance.new("NumberValue")
    characterMaxEnergyValue.Name = "CharacterMaxEnergyValue"
    characterMaxEnergyValue.Parent = characterInfoEnergyFrame

    local characterInfoEnergyAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    characterInfoEnergyAspectRatioConstraint.Name = "UIAspectRatioConstraint"
    characterInfoEnergyAspectRatioConstraint.Parent = characterInfoEnergyFrame

    local characterInfoEnergyBackground = Instance.new("Frame")
    characterInfoEnergyBackground.Name = "CharacterInfo_EnergyBackground"
    characterInfoEnergyBackground.BackgroundTransparency = 1
    characterInfoEnergyBackground.ClipsDescendants = true
    characterInfoEnergyBackground.Size = UDim2.fromScale(1, 1)
    characterInfoEnergyBackground.ZIndex = 2 -- Place it on top of the energy fill

    local characterInfoEnergyBackgroundImageLabel = Instance.new("ImageLabel")
    characterInfoEnergyBackgroundImageLabel.Name = "CharacterInfo_EnergyBackground_BG"
    characterInfoEnergyBackgroundImageLabel.BackgroundTransparency = 1
    characterInfoEnergyBackgroundImageLabel.Image = "rbxassetid://75345050398965"
    characterInfoEnergyBackgroundImageLabel.Size = UDim2.new(1, 0, 0, characterInfoEnergyFrame.AbsoluteSize.Y)
    characterInfoEnergyBackgroundImageLabel.ZIndex = 2 -- Place it on top of the energy fill

      -- Update the energy background size when the absolute size of the energy frame changes (e.g. due to screen resizing)
    characterInfoEnergyFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        characterInfoEnergyBackgroundImageLabel.Size = UDim2.new(1, 0, 0, characterInfoEnergyFrame.AbsoluteSize.Y)
    end)

    local characterInfoEnergyGradient = Instance.new("UIGradient")
    characterInfoEnergyGradient.Name = "UIGradient"
    characterInfoEnergyGradient.Parent = characterInfoEnergyBackgroundImageLabel

    characterInfoEnergyBackgroundImageLabel.Parent = characterInfoEnergyBackground

    characterInfoEnergyBackground.Parent = characterInfoEnergyFrame

    local characterInfoEnergyFill = Instance.new("Frame")
    characterInfoEnergyFill.Name = "CharacterInfo_EnergyFill"
    characterInfoEnergyFill.AnchorPoint = Vector2.new(0.5, 1)
    characterInfoEnergyFill.BackgroundTransparency = 1
    characterInfoEnergyFill.Position = UDim2.fromScale(0.5, 1)
    characterInfoEnergyFill.Size = UDim2.fromScale(1, 1)

    -- Listens to energy changed events to update the energy fill
    -- Since roblox scales frames downwards for some reason, resize the background instead to achieve the similar effect of the energy bar
    -- increasing in size
    characterCurrentEnergyValue.Changed:Connect(function()
        -- Recalculate the energy fill size based on the new energy value
        local energyScale = getEnergyScale(characterCurrentEnergyValue.Value, characterMaxEnergyValue.Value)
        -- Reverse the energy scale since we are resizing the background instead of the fill
        characterInfoEnergyBackground.Size = UDim2.fromScale(1, 1 - energyScale) 
    end)

    local characterInfoEnergyFillImageLabel = Instance.new("ImageLabel")
    characterInfoEnergyFillImageLabel.Name = "CharacterInfo_EnergyFill_BG"
    characterInfoEnergyFillImageLabel.BackgroundTransparency = 1
    characterInfoEnergyFillImageLabel.Image = "rbxassetid://119247488685815"
    characterInfoEnergyFillImageLabel.Size = UDim2.fromScale(1, 1)
    characterInfoEnergyFillImageLabel.ZIndex = 1 -- Place it below the energy background

    local characterInfoEnergyFillUIGradient = Instance.new("UIGradient")
    characterInfoEnergyFillUIGradient.Name = "UIGradient"
    characterInfoEnergyFillUIGradient.Parent = characterInfoEnergyFillImageLabel

    characterInfoEnergyFillImageLabel.Parent = characterInfoEnergyFill

    characterInfoEnergyFill.Parent = characterInfoEnergyFrame

    return characterInfoEnergyFrame
end