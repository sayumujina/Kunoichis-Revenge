local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local GetAvatarImageForCharacter =
	require(StarterPlayerScripts.Client.Controllers.HUDController.Helper.GetAvatarImageForCharacter)

-- Helper function to create a turn card
return function(char: _TYPES.Character, turnId: number, order: number, side: _TYPES.Sides, actionValue: number)
	local actionValueValue = Instance.new("NumberValue")
	actionValueValue.Name = "ActionValue"
	actionValueValue.Value = actionValue

	local sideValue = Instance.new("StringValue")
	sideValue.Name = "SideValue"
	sideValue.Value = side

	local charValue = Instance.new("ObjectValue")
	charValue.Name = "CharValue"
	charValue.Value = char

	-- Create the turn card frame
	local turnCard = Instance.new("Frame")
	turnCard.Name = "MainTurn_Card"
	turnCard.AnchorPoint = Vector2.new(1, 0)
	turnCard.BackgroundTransparency = 1
	-- The HUD controller shifts this forward when extra actions need to render before it.
	turnCard.LayoutOrder = 1
	turnCard.Position = UDim2.fromScale(1, 0)
	turnCard.Size = UDim2.fromScale(0.375, 1)

	actionValueValue.Parent = turnCard
	sideValue.Parent = turnCard
	charValue.Parent = turnCard

	local leftBorder = Instance.new("Frame")
	leftBorder.Name = "Left_Border"
	leftBorder.AnchorPoint = Vector2.new(0, 0.5)
	leftBorder.BackgroundColor3 = Color3.new(1, 1, 1)
	leftBorder.BorderColor3 = Color3.new()
	leftBorder.BorderSizePixel = 0
	leftBorder.Position = UDim2.fromScale(0, 0.5)
	leftBorder.Size = UDim2.new(0, 2, 1, 0)

	local leftBorderUIGradient = Instance.new("UIGradient")
	leftBorderUIGradient.Name = "UIGradient"
	leftBorderUIGradient.Color = if side == "Playable"
		then ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 213)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 213)),
		}) -- Blue for playable characters
		else ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(213, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 0, 0)),
		}) -- Red for npcs
	leftBorderUIGradient.Rotation = 90
	leftBorderUIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, 0.2),
		NumberSequenceKeypoint.new(0.65, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	leftBorderUIGradient.Parent = leftBorder

	leftBorder.Parent = turnCard

	local bg = Instance.new("Frame")
	bg.Name = "BG"
	bg.AnchorPoint = Vector2.new(1, 0)
	bg.BackgroundColor3 = Color3.new(1, 1, 1)
	bg.BorderColor3 = Color3.new()
	bg.BorderSizePixel = 0
	bg.Position = UDim2.fromScale(1, 0)
	bg.Size = UDim2.fromScale(0.95, 1)

	local bgUIGradient = Instance.new("UIGradient")
	bgUIGradient.Name = "BG_UIGradient"
	bgUIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.35, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	bgUIGradient.Parent = bg

	local avatarContainer = Instance.new("Frame")
	avatarContainer.Name = "Avatar_Container"
	avatarContainer.BackgroundTransparency = 1
	avatarContainer.Position = UDim2.fromScale(0.25, 0)
	avatarContainer.Size = UDim2.fromScale(0.95, 1)

	local avatarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	avatarAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	avatarAspectRatioConstraint.Parent = avatarContainer

	local avatarImageLabel = Instance.new("ImageLabel")
	avatarImageLabel.Name = "Avatar"
	avatarImageLabel.BackgroundTransparency = 1
	avatarImageLabel.Image = GetAvatarImageForCharacter(char.Name)
	avatarImageLabel.Size = UDim2.fromScale(1, 1)
	avatarImageLabel.ZIndex = 2
	avatarImageLabel.Parent = avatarContainer

	avatarContainer.Parent = turnCard

	local actionValueContainer = Instance.new("Frame")
	actionValueContainer.Name = "ActionValue_Container"
	actionValueContainer.AnchorPoint = Vector2.new(1, 1)
	actionValueContainer.BackgroundColor3 = Color3.new(1, 1, 1)
	actionValueContainer.BorderColor3 = Color3.new()
	actionValueContainer.BorderSizePixel = 0
	actionValueContainer.Position = UDim2.fromScale(1, 1)
	actionValueContainer.Size = UDim2.fromScale(0.35, 0.35)

	local actionValue_UIGradient = Instance.new("UIGradient")
	actionValue_UIGradient.Name = "UIGradient"
	actionValue_UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	actionValue_UIGradient.Parent = actionValueContainer

	local actionValueLabel = Instance.new("TextLabel")
	actionValueLabel.Name = "ActionValue_Label"
	actionValueLabel.BackgroundTransparency = 1
	actionValueLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	actionValueLabel.Size = UDim2.fromScale(1, 1)
	actionValueLabel.Text = tostring(math.floor(actionValueValue.Value))

	--
	actionValueLabel.TextColor3 = Color3.new(1, 1, 1)
	actionValueLabel.TextScaled = true
	actionValueLabel.Parent = actionValueContainer
	actionValueContainer.Parent = bg

	bg.Parent = turnCard

	-- Update the action value label whenever the value changes
	actionValueValue.Changed:Connect(function()
		actionValueLabel.Text = tostring(math.floor(actionValueValue.Value))
	end)

	return turnCard
end
