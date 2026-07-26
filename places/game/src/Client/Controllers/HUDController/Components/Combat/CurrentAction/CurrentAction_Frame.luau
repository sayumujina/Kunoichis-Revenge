local moveTypeToText = {
	["BasicAttack"] = "Basic Attack",
	["Skill"] = "Skill",
	["Ultimate"] = "Ultimate",
}

local function createCurrentActionFrame()
	local selectedMove = Instance.new("Frame")
	selectedMove.Name = "UI_CurrentAction"
	selectedMove.AnchorPoint = Vector2.new(1, 0)
	selectedMove.BackgroundColor3 = Color3.new(1, 1, 1)
	selectedMove.BorderColor3 = Color3.new()
	selectedMove.BorderSizePixel = 0
	selectedMove.Position = UDim2.fromScale(1, 0.38)
	selectedMove.Size = UDim2.fromScale(0.26, 0.04)

	local currentActionLabel = Instance.new("TextLabel")
	currentActionLabel.Name = "CurrentAction_Label"
	currentActionLabel.BackgroundTransparency = 1
	currentActionLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	currentActionLabel.Position = UDim2.fromScale(0.18, 0.1)
	currentActionLabel.Size = UDim2.fromScale(0.8, 0.8)
	currentActionLabel.Text = "Selected Action: Basic Attack"
	currentActionLabel.TextColor3 = Color3.new(1, 1, 1)
	currentActionLabel.TextDirection = Enum.TextDirection.RightToLeft
	currentActionLabel.TextScaled = true
	currentActionLabel.TextXAlignment = Enum.TextXAlignment.Right

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.Parent = currentActionLabel

	currentActionLabel.Parent = selectedMove

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "UIGradient"
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.35, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	uIGradient.Parent = selectedMove

	return selectedMove
end

local function changeCurrentActionText(newAction: string)
	local currentActionFrame = game.Players.LocalPlayer.PlayerGui.Combat_ScreenGui.PlayerUI.UI_CurrentAction
	local currentActionLabel = currentActionFrame:FindFirstChild("CurrentAction_Label") :: TextLabel

	if currentActionLabel then
		currentActionLabel.Text = "Selected Action: " .. (moveTypeToText[newAction] or newAction)
	end
end

return {
	CreateCurrentActionFrame = createCurrentActionFrame,
	ChangeCurrentActionText = changeCurrentActionText,
}
