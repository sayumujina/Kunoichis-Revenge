local TweenService = game:GetService("TweenService")
--
local rep = game:GetService("ReplicatedStorage")
local Stages = require(rep.Data.data_Stages)
--
local CreateBattleEndButtons = require(script.Parent.BattleEndButtons)

local VICTORY_OBJECTIVE_POSITION = UDim2.fromScale(0.27, 0.32)
local VICTORY_OBJECTIVE_SIZE = UDim2.fromScale(0.46, 0.2)
local VICTORY_OBJECTIVEDESC_SIZE = UDim2.fromScale(0.6, 0.8)
local VICTORY_OBJECTIVEDESC_POSITION = UDim2.fromScale(0.1, 0.1)
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

local function cloneObjectiveFrameFromCombatScreen(
	worldId: string,
	stageId: string,
	playerGui,
	battleEndScreen,
	tweens,
	previouslyClearedExtraObjectives,
	clearedObjectives
)
	local clonedObjectiveFrame =
		playerGui:FindFirstChild("Combat_ScreenGui"):FindFirstChild("UI_ObjectivesFrame"):Clone()
	clonedObjectiveFrame.Name = "UI_BattleEnd_ObjectivesFrame"
	clonedObjectiveFrame.Position = VICTORY_OBJECTIVE_POSITION
	clonedObjectiveFrame.Size = VICTORY_OBJECTIVE_SIZE
	clonedObjectiveFrame.Parent = battleEndScreen
	clonedObjectiveFrame.BackgroundTransparency = 1
	--
	for _, child in pairs(clonedObjectiveFrame:GetChildren()) do
		-- Reset the size of the objective labels to fit within the new frame
		local objectiveDesc = child:FindFirstChild("ObjectiveDesc")
		if objectiveDesc then
			objectiveDesc.Size = VICTORY_OBJECTIVEDESC_SIZE
			objectiveDesc.Position = VICTORY_OBJECTIVEDESC_POSITION
		end

		-- Get the objective name from the child name by removing the "_Card" suffix
		local objectiveName = string.gsub(child.Name, "_Card", "")
		local objectivePassed = table.find(clearedObjectives, objectiveName)
		local objectivePreviouslyCleared = table.find(previouslyClearedExtraObjectives, objectiveName)
		local rewardText
		-- 1. If objective is passed for the first time, display the rewards amount
		-- 2. If objective is passed but has been previously cleared, display "Claimed"
		-- 3. If objective is not passed, do not display the rewards amount
		warn(
			"Objective Name: ",
			objectiveName,
			" | Passed: ",
			objectivePassed,
			" | Previously Cleared: ",
			objectivePreviouslyCleared
		)
		if objectivePassed then
			if objectivePreviouslyCleared then
				rewardText = "Claimed"

			-- If the objective passed this run and has been previously cleared, display the reward value in a lower opacity
			else
				rewardText = tostring(
					Stages[worldId].stages[stageId].firstClearReward.extraObjectives[objectiveName].rewardValue
				)
			end
		else
			-- If the objective failed this run, but has already been cleared in a previous run, treat iut as passed
			if objectivePreviouslyCleared then
				rewardText = "Claimed"

			-- Otherwise, if the objective failed this run and has not been cleared in a previous run, display "Failed"
			else
				rewardText = "Failed"
			end
		end

		-- Add the objective rewards frame to each objective
		local objectiveRewards = Instance.new("Frame")
		objectiveRewards.Name = "ObjectiveRewards"
		objectiveRewards.AnchorPoint = Vector2.new(1, 0)
		objectiveRewards.BackgroundTransparency = 1
		objectiveRewards.Position = UDim2.fromScale(1, 0.2)
		objectiveRewards.Size = UDim2.fromScale(0.2, 0.6)

		local rewardsAmountLabel = Instance.new("TextLabel")
		rewardsAmountLabel.Name = "RewardsAmount_Label"
		rewardsAmountLabel.AutomaticSize = Enum.AutomaticSize.Y
		rewardsAmountLabel.BackgroundTransparency = 1
		rewardsAmountLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
		rewardsAmountLabel.LayoutOrder = 1
		rewardsAmountLabel.Size = UDim2.fromScale(0.5, 1)

		rewardsAmountLabel.Text = rewardText
		rewardsAmountLabel.TextTransparency = 0
		rewardsAmountLabel.TextColor3 = Color3.new(1, 1, 1)
		rewardsAmountLabel.TextScaled = true
		rewardsAmountLabel.TextXAlignment = Enum.TextXAlignment.Right
		rewardsAmountLabel.Parent = objectiveRewards

		-- Only show the rewards icon if the objective has not been previously cleared
		if objectivePassed and not objectivePreviouslyCleared then
			local rewardsIcon = Instance.new("ImageLabel")
			rewardsIcon.Name = "RewardsIcon"
			rewardsIcon.BackgroundTransparency = 1
			rewardsIcon.Image = "rbxassetid://99648493271139"
			rewardsIcon.LayoutOrder = 2
			rewardsIcon.Position = UDim2.fromScale(1, 0)
			rewardsIcon.Size = UDim2.fromScale(1, 1)

			local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
			uIAspectRatioConstraint.Parent = rewardsIcon

			rewardsIcon.Parent = objectiveRewards
		end

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		uIListLayout.Padding = UDim.new(0.02, 0)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = objectiveRewards
		--
		objectiveRewards.Parent = child

		rewardsAmountLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
		rewardsAmountLabel.LayoutOrder = 1

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

	return clonedObjectiveFrame
end

--- Creates a battle end screen with the given parameters.
--- @param worldId -- The ID of the world where the battle took place.
--- @param stageId -- The ID of the stage where the battle took place.
--- @param passed -- Whether the player passed the challenge.
--- @param clearedExtraObjectives -- The list of extra objectives that were cleared by the player.
--- @param previouslyClearedExtraObjectives -- The list of extra objectives that were previously cleared by the player.
local function createBattleEndScreen(
	worldId: string,
	stageId: string,
	passed: boolean,
	clearedExtraObjectives: { string }?,
	previouslyClearedExtraObjectives: { string }?
)
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
		clonedObjectiveFrame = cloneObjectiveFrameFromCombatScreen(
			worldId,
			stageId,
			playerGui,
			battleEndScreen,
			tweens,
			previouslyClearedExtraObjectives,
			clearedExtraObjectives
		)
		clonedObjectiveFrame.Parent = battleEndScreen

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
		if clearedExtraObjectives and #clearedExtraObjectives == numberOfExtraObjectives then
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
