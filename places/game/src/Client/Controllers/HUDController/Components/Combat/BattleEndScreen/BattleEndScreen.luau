local TweenService = game:GetService("TweenService")
--
local CreateBattleEndButtons = require(script.Parent.BattleEndButtons)

local VICTORY_OBJECTIVE_POSITION = UDim2.fromScale(0.35, 0.32)
local VICTORY_OBJECTIVE_SIZE = UDim2.fromScale(0.3, 0.24)
--
local VICTORY_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(253, 246, 140)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(244, 205, 42)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(237, 163, 35)),
})
local FAILED_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 22, 22)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 27, 28)),
})

local function createBattleEndScreen(passed: boolean, numberOfSuccessfulExtraObjectives: number)
	local tweens = {}
	local battleEndScreen = Instance.new("Frame")
	battleEndScreen.Name = "UI_BattleEnd_Screen"
	battleEndScreen.BackgroundColor3 = Color3.new()
	battleEndScreen.BackgroundTransparency = 1
	battleEndScreen.BorderColor3 = Color3.new()
	battleEndScreen.BorderSizePixel = 0
	battleEndScreen.Size = UDim2.fromScale(1, 1)
	battleEndScreen.ZIndex = 1
	--
	local battleEndScreenTween = TweenService:Create(
		battleEndScreen,
		TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.05 }
	)
	table.insert(tweens, battleEndScreenTween)

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "BattleEnd_Label"
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	textLabel.Position = UDim2.fromScale(0.15, 0.15)
	textLabel.Size = UDim2.fromScale(0.7, 0.1)
	textLabel.Text = passed and "Defense Successful" or "Defense Infiltrated"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextTransparency = 1
	textLabel.TextScaled = true
	textLabel.Parent = battleEndScreen
	textLabel.ZIndex = 10
	--
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = passed and VICTORY_GRADIENT or FAILED_GRADIENT
	uiGradient.Parent = textLabel
	--
	local textLabelTween = TweenService:Create(
		textLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{ TextTransparency = 0 }
	)
	table.insert(tweens, textLabelTween)

	local playerGui = game.Players.LocalPlayer.PlayerGui

	-- Clone the objective frame from the combat screen and add it to the victory screen
	local clonedObjectiveFrame
	if passed then
		clonedObjectiveFrame = playerGui:FindFirstChild("Combat_ScreenGui"):FindFirstChild("UI_ObjectivesFrame"):Clone()
		clonedObjectiveFrame.Name = "UI_BattleEnd_ObjectivesFrame"
		clonedObjectiveFrame.Position = VICTORY_OBJECTIVE_POSITION
		clonedObjectiveFrame.Size = VICTORY_OBJECTIVE_SIZE
		clonedObjectiveFrame.Parent = battleEndScreen
		clonedObjectiveFrame.BackgroundTransparency = 1
		--
		for _, child in pairs(clonedObjectiveFrame:GetDescendants()) do
			if child:IsA("TextLabel") then
				child.TextTransparency = 1
				local textLabelTween = TweenService:Create(
					child,
					TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{ TextTransparency = 0 }
				)
				table.insert(tweens, textLabelTween)
			elseif child:IsA("ImageLabel") then
				child.ImageTransparency = 1
				local imageLabelTween = TweenService:Create(
					child,
					TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{ ImageTransparency = 0 }
				)
				table.insert(tweens, imageLabelTween)
			end
		end

		local consumedActionValue = Instance.new("Frame")
		consumedActionValue.Name = "UI_ConsumedActionValue"
		consumedActionValue.BackgroundTransparency = 1
		consumedActionValue.Position = UDim2.fromScale(0.3, 0.25)
		consumedActionValue.Size = UDim2.fromScale(0.4, 0.03)

		-- Get the elapsed action value
		local elapsedActionValueFrame = playerGui:FindFirstChild("UI_ElapsedActionValue", true)
		local elapsedActionValueValue = elapsedActionValueFrame:FindFirstChild("ElapsedActionValue_Value")
		local value = elapsedActionValueValue and elapsedActionValueValue.Value or 0

		local consumedActionValueLabel = Instance.new("TextLabel")
		consumedActionValueLabel.Name = "TextLabel"
		consumedActionValueLabel.BackgroundTransparency = 1
		consumedActionValueLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
		consumedActionValueLabel.Size = UDim2.fromScale(1, 1)
		consumedActionValueLabel.Text = "Consumed Action Value: " .. math.ceil(value)
		consumedActionValueLabel.TextColor3 = Color3.new(1, 1, 1)
		consumedActionValueLabel.TextScaled = true
		consumedActionValueLabel.Parent = consumedActionValue
		consumedActionValue.Parent = battleEndScreen

		local consumedActionValueTween = TweenService:Create(
			consumedActionValueLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{ TextTransparency = 0 }
		)
		table.insert(tweens, consumedActionValueTween)
	end

	for _, tween in pairs(tweens) do
		tween.Completed:Once(function()
			tween:Destroy()
		end)
		tween:Play()
	end

	if passed then
		local numberOfExtraObjectives = 0
		for _, extraObjective in pairs(clonedObjectiveFrame:GetChildren()) do
			if extraObjective:IsA("Frame") then
				numberOfExtraObjectives += 1
			end
		end

		-- Show return if challenge was successful with all extra objectives completed
		if numberOfSuccessfulExtraObjectives == numberOfExtraObjectives then
			CreateBattleEndButtons({ "Return" }).Parent = battleEndScreen
		-- Show restart and return if not all extra objectives were completed
		else
			CreateBattleEndButtons({ "Restart", "Return" }).Parent = battleEndScreen
		end
	-- Show restart and return if challenge was failed
	else
		local battleEndButtons = CreateBattleEndButtons({ "Restart", "Return" })
		battleEndButtons.Parent = battleEndScreen
	end

	return battleEndScreen
end

return createBattleEndScreen
