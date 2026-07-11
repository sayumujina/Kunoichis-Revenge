local function getEnergyScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

return function(size: UDim2?, position: UDim2?)
	local energyFrame = Instance.new("Frame")
	energyFrame.Name = "CharacterInfo_Energy"
	energyFrame.BackgroundTransparency = 1
	energyFrame.Position = position or UDim2.fromScale(0.51, 0)
	energyFrame.Size = size or UDim2.fromScale(0.63, 0.63)

	local currentEnergyValue = Instance.new("NumberValue")
	currentEnergyValue.Name = "CharacterCurrentEnergyValue"
	currentEnergyValue.Parent = energyFrame

	local maxEnergyValue = Instance.new("NumberValue")
	maxEnergyValue.Name = "CharacterMaxEnergyValue"
	maxEnergyValue.Parent = energyFrame

	local energyAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	energyAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	energyAspectRatioConstraint.Parent = energyFrame

	local energyBackground = Instance.new("Frame")
	energyBackground.Name = "CharacterInfo_EnergyBackground"
	energyBackground.BackgroundTransparency = 1
	energyBackground.ClipsDescendants = true
	energyBackground.Size = UDim2.fromScale(1, 1 - getEnergyScale(currentEnergyValue.Value, maxEnergyValue.Value))
	energyBackground.ZIndex = 2 -- Place it on top of the energy fill

	local energyBackgroundImageLabel = Instance.new("ImageLabel")
	energyBackgroundImageLabel.Name = "CharacterInfo_EnergyBackground_BG"
	energyBackgroundImageLabel.BackgroundTransparency = 1
	energyBackgroundImageLabel.Image = "rbxassetid://75345050398965"
	energyBackgroundImageLabel.Size = UDim2.new(1, 0, 0, energyFrame.AbsoluteSize.Y)
	energyBackgroundImageLabel.ZIndex = 2 -- Place it on top of the energy fill

	-- Update the energy background size when the absolute size of the energy frame changes (e.g. due to screen resizing)
	energyFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		energyBackgroundImageLabel.Size = UDim2.new(1, 0, 0, energyFrame.AbsoluteSize.Y)
	end)

	local energyGradient = Instance.new("UIGradient")
	energyGradient.Name = "UIGradient"
	energyGradient.Parent = energyBackgroundImageLabel

	energyBackgroundImageLabel.Parent = energyBackground

	energyBackground.Parent = energyFrame

	local energyFill = Instance.new("Frame")
	energyFill.Name = "CharacterInfo_EnergyFill"
	energyFill.AnchorPoint = Vector2.new(0.5, 1)
	energyFill.BackgroundTransparency = 1
	energyFill.Position = UDim2.fromScale(0.5, 1)
	energyFill.Size = UDim2.fromScale(1, 1)

	-- Listens to energy changed events to update the energy fill
	-- Since roblox scales frames downwards for some reason, resize the background instead to achieve the similar effect of the energy bar
	-- increasing in size
	currentEnergyValue.Changed:Connect(function()
		-- Recalculate the energy fill size based on the new energy value
		local energyScale = getEnergyScale(currentEnergyValue.Value, maxEnergyValue.Value)
		-- Reverse the energy scale since we are resizing the background instead of the fill
		energyBackground.Size = UDim2.fromScale(1, 1 - energyScale)
	end)

	local energyFillImageLabel = Instance.new("ImageLabel")
	energyFillImageLabel.Name = "CharacterInfo_EnergyFill_BG"
	energyFillImageLabel.BackgroundTransparency = 1
	energyFillImageLabel.Image = "rbxassetid://119247488685815"
	energyFillImageLabel.Size = UDim2.fromScale(1, 1)
	energyFillImageLabel.ZIndex = 1 -- Place it below the energy background

	local energyFillUIGradient = Instance.new("UIGradient")
	energyFillUIGradient.Name = "UIGradient"
	energyFillUIGradient.Parent = energyFillImageLabel

	energyFillImageLabel.Parent = energyFill

	energyFill.Parent = energyFrame

	return energyFrame
end
