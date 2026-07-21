local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)

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

--- Creates an objective card with the given name, description, and passed state
--- @param id -- The ID of the objective card
--- @param description -- The description of the objective card
--- @param passed -- Whether the objective card is passed
local function createObjectiveCard(id: string, description: string, passed: boolean)
	local objectiveCard = Instance.new("Frame")
	objectiveCard.Name = id .. "_Card"
	objectiveCard.BackgroundTransparency = 1
	objectiveCard.Size = UDim2.fromScale(1, 0.3)

	local objectiveDesc = Instance.new("TextLabel")
	objectiveDesc.Name = "ObjectiveDesc"
	objectiveDesc.BackgroundTransparency = 1
	objectiveDesc.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	objectiveDesc.Position = UDim2.fromScale(0.17, 0.1)
	objectiveDesc.Size = UDim2.fromScale(0.8, 0.8)
	objectiveDesc.Text = description
	objectiveDesc.TextColor3 = Color3.new(1, 1, 1)
	objectiveDesc.TextScaled = true
	objectiveDesc.TextXAlignment = Enum.TextXAlignment.Left
	objectiveDesc.Parent = objectiveCard

	local objectiveIcon = Instance.new("ImageLabel")
	objectiveIcon.Name = "ObjectiveIcon"
	objectiveIcon.BackgroundTransparency = 1
	objectiveIcon.Image = ui.hud.Combat.UI_CombatHud_ObjectiveIcon
	objectiveIcon.Position = UDim2.fromScale(0.01, 0)
	objectiveIcon.Size = UDim2.fromScale(1, 1)

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.Parent = objectiveIcon

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "UIGradient"
	uIGradient.Color = if passed then PASSED_OBJECTIVE_COLOR else UNPASSED_OBJECTIVE_COLOR
	uIGradient.Parent = objectiveIcon

	objectiveIcon.Parent = objectiveCard

	return objectiveCard
end

--- Changes the state of the objective card to passed or unpassed
--- @param objectiveCard -- The objective card to change the state of
--- @param passed -- Whether the objective card is passed
local function changeObjectiveCardState(objectiveId: string, passed: boolean)
	local playerGui = game.Players.LocalPlayer.PlayerGui
	local objectiveFrame = playerGui.Combat_ScreenGui:FindFirstChild("UI_ObjectivesFrame")
	if not objectiveFrame then
		warn("Objective frame not found.")
		return
	end

	local objectiveCard = objectiveFrame:FindFirstChild(objectiveId .. "_Card", true)
	if not objectiveCard then
		warn("Objective card with ID " .. objectiveId .. " not found.")
		return
	end

	local objectiveIcon = objectiveCard:FindFirstChild("ObjectiveIcon")
	if not objectiveIcon then
		warn("Objective icon not found in card with ID " .. objectiveId)
		return
	end

	local uIGradient = objectiveIcon:FindFirstChild("UIGradient")
	if uIGradient then
		uIGradient.Color = if passed then PASSED_OBJECTIVE_COLOR else UNPASSED_OBJECTIVE_COLOR
	end
end

return {
	CreateObjectiveCard = createObjectiveCard,
	ChangeObjectiveCardState = changeObjectiveCardState,
}
