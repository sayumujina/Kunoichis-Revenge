local rep = game:GetService("ReplicatedStorage")
local Stages = require(rep.Data.data_Stages)
local GetAvatarImageForCharacter = require(rep.Shared.GlobalUtility.GetAvatarImageForCharacter)
local GetIconImageForItem = require(rep.Shared.GlobalUtility.GetIconImageForItem)
local ui = require(rep.Assets.Asphalt.UI)

local PASSED_OBJECTIVE_COLOR = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(253, 246, 140)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(244, 205, 42)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(237, 163, 35)),
})
local UNPASSED_OBJECTIVE_COLOR = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(118, 118, 118)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(118, 118, 118)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 118, 118)),
})

local function createEnemiesList(enemies: { string })
	local enemiesList = Instance.new("Frame")
	enemiesList.Name = "EnemiesList"
	enemiesList.BackgroundTransparency = 1
	enemiesList.Position = UDim2.fromScale(0.05, 0.81)
	enemiesList.Size = UDim2.fromScale(0.9, 0.13)

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.Padding = UDim.new(0.01, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = enemiesList

	local function createCharacterFrame(charName: string)
		local characterFrame = Instance.new("Frame")
		characterFrame.Name = "Character_Frame"
		characterFrame.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
		characterFrame.BackgroundTransparency = 0.8
		characterFrame.Size = UDim2.fromScale(1, 1)
		characterFrame.ZIndex = 3

		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
		uIAspectRatioConstraint.Parent = characterFrame

		local avatar = Instance.new("ImageLabel")
		avatar.Name = "Avatar"
		avatar.BackgroundTransparency = 1
		avatar.Image = GetAvatarImageForCharacter(charName)
		avatar.Size = UDim2.fromScale(1, 1)
		avatar.ZIndex = 3
		avatar.Parent = characterFrame

		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.BottomLeftRadius = UDim.new(0, 12)
		uICorner.BottomRightRadius = UDim.new(0, 12)
		uICorner.CornerRadius = UDim.new(0, 12)
		uICorner.TopLeftRadius = UDim.new(0, 12)
		uICorner.TopRightRadius = UDim.new(0, 12)
		uICorner.Parent = characterFrame
		characterFrame.Parent = enemiesList
	end

	for _, enemyName in pairs(enemies) do
		createCharacterFrame(enemyName)
	end

	return enemiesList
end

local function createObjectiveList(worldId: string, stageId: string, passedObjectives: { string })
	local objectivesFrame = Instance.new("Frame")
	objectivesFrame.Name = "Objectives_Frame"
	objectivesFrame.BackgroundTransparency = 1
	objectivesFrame.Position = UDim2.fromScale(0.05, 0.265)
	objectivesFrame.Size = UDim2.fromScale(0.9, 0.15)

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.Padding = UDim.new(0.03, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = objectivesFrame

	local stageInfo = Stages[worldId].stages[stageId]
	local objectiveList = stageInfo.extraObjectives
	warn(objectiveList)
	local function createObjectiveFrame(objectiveId: string, passed: boolean)
		local objective = Instance.new("Frame")
		objective.Name = objectiveId
		objective.BackgroundTransparency = 1
		objective.Size = UDim2.fromScale(1, 0.3)
		objective.LayoutOrder = objectiveList[objectiveId].objectiveOrder

		local objectiveIcon = Instance.new("ImageLabel")
		objectiveIcon.Name = "ObjectiveIcon"
		objectiveIcon.BackgroundTransparency = 1
		objectiveIcon.Image = ui.hud.Combat.UI_CombatHud_ObjectiveIcon
		objectiveIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		objectiveIcon.Position = UDim2.fromScale(0.01, 0)
		objectiveIcon.Size = UDim2.fromScale(1, 1)

		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
		uIAspectRatioConstraint.Parent = objectiveIcon

		local uIGradient = Instance.new("UIGradient")
		uIGradient.Name = "UIGradient"
		uIGradient.Color = if passed then PASSED_OBJECTIVE_COLOR else UNPASSED_OBJECTIVE_COLOR
		uIGradient.Parent = objectiveIcon

		objectiveIcon.Parent = objective

		local objectiveDesc = Instance.new("TextLabel")
		objectiveDesc.Name = "ObjectiveDesc"
		objectiveDesc.BackgroundTransparency = 1
		objectiveDesc.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
		objectiveDesc.Position = UDim2.fromScale(0.06, 0.1)
		objectiveDesc.Size = UDim2.fromScale(0.6, 0.8)
		objectiveDesc.Text = objectiveList[objectiveId].description
		objectiveDesc.TextColor3 = Color3.new(1, 1, 1)
		objectiveDesc.TextScaled = true
		objectiveDesc.TextXAlignment = Enum.TextXAlignment.Left
		objectiveDesc.Parent = objective

		local objectiveRewards = Instance.new("Frame")
		objectiveRewards.Name = "ObjectiveRewards"
		objectiveRewards.AnchorPoint = Vector2.new(1, 0)
		objectiveRewards.BackgroundTransparency = 1
		objectiveRewards.Position = UDim2.fromScale(1, 0.1)
		objectiveRewards.Size = UDim2.fromScale(0.3, 0.8)

		local rewardsAmountLabel = Instance.new("TextLabel")
		rewardsAmountLabel.Name = "RewardsAmount_Label"
		rewardsAmountLabel.AutomaticSize = Enum.AutomaticSize.Y
		rewardsAmountLabel.BackgroundTransparency = 1
		rewardsAmountLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
		rewardsAmountLabel.LayoutOrder = 1
		rewardsAmountLabel.Size = UDim2.fromScale(0.2, 1)
		rewardsAmountLabel.Text = stageInfo.firstClearReward.extraObjectives[objectiveId].rewardValue
		rewardsAmountLabel.TextColor3 = Color3.new(1, 1, 1)
		rewardsAmountLabel.TextScaled = true
		rewardsAmountLabel.TextXAlignment = Enum.TextXAlignment.Right
		rewardsAmountLabel.TextTransparency = if passed then 0.5 else 0
		rewardsAmountLabel.Parent = objectiveRewards

		local rewardsIcon = Instance.new("ImageLabel")
		rewardsIcon.Name = "RewardsIcon"
		rewardsIcon.BackgroundTransparency = 1
		rewardsIcon.Image = GetIconImageForItem(stageInfo.firstClearReward.extraObjectives[objectiveId].rewardName)
		rewardsIcon.ImageTransparency = if passed then 0.5 else 0
		rewardsIcon.LayoutOrder = 2
		rewardsIcon.Position = UDim2.fromScale(1, 0)
		rewardsIcon.Size = UDim2.fromScale(1, 1)

		local rewardsIconspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		rewardsIconspectRatioConstraint.Name = "UIAspectRatioConstraint"
		rewardsIconspectRatioConstraint.Parent = rewardsIcon
		rewardsIcon.Parent = objectiveRewards

		local rewardsIconUIListLayout = Instance.new("UIListLayout")
		rewardsIconUIListLayout.Name = "UIListLayout"
		rewardsIconUIListLayout.FillDirection = Enum.FillDirection.Horizontal
		rewardsIconUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		rewardsIconUIListLayout.Padding = UDim.new(0.02, 0)
		rewardsIconUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rewardsIconUIListLayout.Parent = objectiveRewards
		--
		objectiveRewards.Parent = objective

		objective.Parent = objectivesFrame
	end

	for objectiveId, objectiveData in pairs(objectiveList) do
		createObjectiveFrame(objectiveId, table.find(passedObjectives, objectiveId) ~= nil)
	end

	return objectivesFrame
end

local function createFirstClearRewardsFrame(worldId: string, stageId: string, stageCleared: boolean)
	local firstClearRewardFrame = Instance.new("Frame")
	firstClearRewardFrame.Name = "FirstClearReward_Frame"
	firstClearRewardFrame.BackgroundTransparency = 1
	firstClearRewardFrame.Position = UDim2.fromScale(0.05, 0.22)
	firstClearRewardFrame.Size = UDim2.fromScale(0.9, 0.045)

	local firstClearRewardLabel = Instance.new("TextLabel")
	firstClearRewardLabel.Name = "FirstClearReward_Label"
	firstClearRewardLabel.BackgroundTransparency = 1
	firstClearRewardLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	firstClearRewardLabel.Position = UDim2.fromScale(0.06, 0.1)
	firstClearRewardLabel.Size = UDim2.fromScale(0.6, 0.8)
	firstClearRewardLabel.Text = "First clear"
	firstClearRewardLabel.TextColor3 = Color3.new(1, 1, 1)
	firstClearRewardLabel.TextScaled = true
	firstClearRewardLabel.TextXAlignment = Enum.TextXAlignment.Left
	firstClearRewardLabel.Parent = firstClearRewardFrame

	local firstClearReward = Instance.new("Frame")
	firstClearReward.Name = "FirstClearReward"
	firstClearReward.AnchorPoint = Vector2.new(1, 0)
	firstClearReward.BackgroundTransparency = 1
	firstClearReward.Position = UDim2.fromScale(1, 0.1)
	firstClearReward.Size = UDim2.fromScale(0.3, 0.8)

	local stageInfo = Stages[worldId].stages[stageId]
	local rewardsAmountLabel = Instance.new("TextLabel")
	rewardsAmountLabel.Name = "RewardsAmount_Label"
	rewardsAmountLabel.AutomaticSize = Enum.AutomaticSize.Y
	rewardsAmountLabel.BackgroundTransparency = 1
	rewardsAmountLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	rewardsAmountLabel.LayoutOrder = 1
	rewardsAmountLabel.Size = UDim2.fromScale(0.2, 1)
	rewardsAmountLabel.Text = stageInfo.firstClearReward.clear.rewardValue
	rewardsAmountLabel.TextColor3 = Color3.new(1, 1, 1)
	rewardsAmountLabel.TextScaled = true
	rewardsAmountLabel.TextXAlignment = Enum.TextXAlignment.Right
	rewardsAmountLabel.TextTransparency = if stageCleared then 0.5 else 0
	rewardsAmountLabel.Parent = firstClearReward

	local rewardsIcon = Instance.new("ImageLabel")
	rewardsIcon.Name = "RewardsIcon"
	rewardsIcon.BackgroundTransparency = 1
	rewardsIcon.Image = GetIconImageForItem(stageInfo.firstClearReward.clear.rewardName)
	rewardsIcon.ImageTransparency = if stageCleared then 0.5 else 0
	rewardsIcon.LayoutOrder = 2
	rewardsIcon.Position = UDim2.fromScale(1, 0)
	rewardsIcon.Size = UDim2.fromScale(1, 1)

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.Parent = rewardsIcon

	rewardsIcon.Parent = firstClearReward

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uIListLayout.Padding = UDim.new(0.02, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = firstClearReward

	firstClearReward.Parent = firstClearRewardFrame

	return firstClearRewardFrame
end

--- Creates the stage details frame for a given stage, including the objectives and enemies list.
--- @param worldId -- The ID of the world the stage belongs to.
--- @param stageId -- The ID of the stage.
--- @param stageDescription -- The description of the stage.
--- @param passedObjectives -- A list of objective IDs that have been passed for the stage.
local function createStageDetailsFrame(
	worldId: string,
	stageId: string,
	stageDescription: string,
	stageCleared: boolean,
	passedObjectives: { string }
)
	local stageDetailsFrame = Instance.new("Frame")
	stageDetailsFrame.Name = "UI_StageDetails_Frame"
	stageDetailsFrame.BackgroundTransparency = 1
	stageDetailsFrame.Position = UDim2.fromScale(0.02, 0.155)
	stageDetailsFrame.Size = UDim2.fromScale(0.59, 0.82)
	stageDetailsFrame.Visible = true

	local bG = Instance.new("ImageLabel")
	bG.Name = "BG"
	bG.BackgroundTransparency = 1
	bG.Image = "rbxassetid://119027730570633"
	bG.ScaleType = Enum.ScaleType.Slice
	bG.Size = UDim2.fromScale(1, 1)
	bG.SliceCenter = Rect.new(32, 45, 849, 936)
	bG.ZIndex = 1
	bG.Parent = stageDetailsFrame

	local stageDetailsLabel = Instance.new("TextLabel")
	stageDetailsLabel.Name = "StageDetails_Label"
	stageDetailsLabel.BackgroundTransparency = 1
	stageDetailsLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	stageDetailsLabel.Position = UDim2.fromScale(0.15, 0.06)
	stageDetailsLabel.Size = UDim2.fromScale(0.7, 0.06)
	stageDetailsLabel.Text = "Stage Details"
	stageDetailsLabel.TextColor3 = Color3.new(1, 1, 1)
	stageDetailsLabel.TextScaled = true
	stageDetailsLabel.TextStrokeTransparency = 0
	stageDetailsLabel.Parent = stageDetailsFrame

	local stageNameLabel = Instance.new("TextLabel")
	stageNameLabel.Name = "StageName_Label"
	stageNameLabel.BackgroundTransparency = 1
	stageNameLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	stageNameLabel.Position = UDim2.fromScale(0.2, 0.145)
	stageNameLabel.Size = UDim2.fromScale(0.6, 0.04)
	stageNameLabel.Text = stageId .. " - " .. stageDescription
	stageNameLabel.TextColor3 = Color3.new(1, 1, 1)
	stageNameLabel.TextScaled = true
	stageNameLabel.TextStrokeTransparency = 0
	stageNameLabel.Parent = stageDetailsFrame

	local line = Instance.new("Frame")
	line.Name = "Line"
	line.BackgroundColor3 = Color3.new(1, 1, 1)
	line.BorderColor3 = Color3.new()
	line.BorderSizePixel = 0
	line.Position = UDim2.fromScale(0.2, 0.13)
	line.Size = UDim2.fromScale(0.6, 0.005)
	line.Parent = stageDetailsFrame

	local enemiesLabel = Instance.new("TextLabel")
	enemiesLabel.Name = "Enemies_Label"
	enemiesLabel.BackgroundTransparency = 1
	enemiesLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	enemiesLabel.Position = UDim2.fromScale(0.2, 0.76)
	enemiesLabel.Size = UDim2.fromScale(0.6, 0.04)
	enemiesLabel.Text = "Enemies"
	enemiesLabel.TextColor3 = Color3.new(1, 1, 1)
	enemiesLabel.TextScaled = true
	enemiesLabel.Parent = stageDetailsFrame

	-- Create the first clear rewards frame and add it to the stage details frame
	createFirstClearRewardsFrame(worldId, stageId, stageCleared).Parent = stageDetailsFrame

	-- Create the objectives list frame and add it to the stage details frame
	createObjectiveList(worldId, stageId, passedObjectives).Parent = stageDetailsFrame

	-- Get the enemies list for the stage
	local enemiesList = Stages[worldId].stages[stageId].enemies
	createEnemiesList(enemiesList).Parent = stageDetailsFrame

	return stageDetailsFrame
end

return {
	CreateStageDetailsFrame = createStageDetailsFrame,
}
