local TweenService = game:GetService("TweenService")
local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)
--

local function getEnergyScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

local NOT_FULL_ENERGY_TRANSPARENCY = 0.3
local FULL_ENERGY_TRANSPARENCY = 0

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
	energyBackgroundImageLabel.Image = ui.hud.Combat.UI_CombatHud_EnergyCircle
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

	local energyFillImageLabel = Instance.new("ImageLabel")
	energyFillImageLabel.Name = "CharacterInfo_EnergyFill_BG"
	energyFillImageLabel.BackgroundTransparency = 1
	energyFillImageLabel.Image = ui.hud.Combat.UI_CombatHud_EnergyFill
	energyFillImageLabel.Size = UDim2.fromScale(1, 1)
	energyFillImageLabel.ZIndex = 1 -- Place it below the energy background

	-- Listens to energy changed events to update the energy fill
	-- Since roblox scales frames downwards for some reason, resize the background instead to achieve the similar effect of the energy bar
	-- increasing in size
	currentEnergyValue.Changed:Connect(function()
		-- Recalculate the energy fill size based on the new energy value
		local energyScale = getEnergyScale(currentEnergyValue.Value, maxEnergyValue.Value)
		-- Reverse the energy scale since we are resizing the background instead of the fill
		energyBackground.Size = UDim2.fromScale(1, 1 - energyScale)

		-- If the energy is not at full, set a lower transparency
		if energyScale < 1 then
			energyFillImageLabel.ImageTransparency = NOT_FULL_ENERGY_TRANSPARENCY
		else
			-- Create a duplicate of the energy fill
			local energyPulse = energyFillImageLabel:Clone()
			energyPulse.Parent = energyFill
			energyPulse.Name = "CharacterInfo_EnergyPulse"
			energyPulse.Image = ui.hud.Combat.UI_CombatHud_EnergyPulse
			energyPulse.ImageTransparency = 0
			energyPulse.Size = UDim2.fromScale(1, 1)
			energyPulse.Position = UDim2.fromScale(0.5, 0.5)
			energyPulse.AnchorPoint = Vector2.new(0.5, 0.5)
			warn("Energy is full! Triggering energy fill animation!")

			-- Fade the energy fill duplicate to full, and then tween it back to a lower transparency after a short delay
			-- 1. Enlarge the duplicate to 1.02x its size and set its transparency to 0
			local energyPulseTween = TweenService:Create(
				energyPulse,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(1.6, 1.6) }
			)

			-- Destroy the duplicate after the tween completes
			energyPulseTween.Completed:Connect(function()
				energyPulse:Destroy()
			end)
			energyPulseTween:Play()

			-- 2. Tween the energy fill to the full energy transparency
			TweenService:Create(
				energyFillImageLabel,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{ ImageTransparency = FULL_ENERGY_TRANSPARENCY }
			):Play()

			-- 3. When the energyPulseTween is about to complete, fade the dupicate
			task.delay(0.3, function()
				TweenService:Create(
					energyPulse,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 1 }
				):Play()
			end)
		end
	end)

	local energyFillUIGradient = Instance.new("UIGradient")
	energyFillUIGradient.Name = "UIGradient"
	energyFillUIGradient.Parent = energyFillImageLabel

	energyFillImageLabel.Parent = energyFill

	energyFill.Parent = energyFrame

	return energyFrame
end
