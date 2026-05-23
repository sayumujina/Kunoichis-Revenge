local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

-- Helper function to create a turn card
return function(char: _TYPES.Character, turnId: number, order: number, side: _TYPES.Sides, actionValue: number)
	local actionValueValue = Instance.new("NumberValue")
	actionValueValue.Name = "ActionValue"
	actionValueValue.Value = actionValue

	local idValue = Instance.new("NumberValue")
	idValue.Name = "TurnIdValue"
	idValue.Value = turnId

	local orderValue = Instance.new("NumberValue")
	orderValue.Name = "OrderValue"
	orderValue.Value = order

	local sideValue = Instance.new("StringValue")
	sideValue.Name = "SideValue"
	sideValue.Value = side

	local charNameValue = Instance.new("StringValue")
	charNameValue.Name = "CharNameValue"
	charNameValue.Value = char.Name

	-- Create the turn card frame
	local turnCard = Instance.new("Frame")
	turnCard.Name = "Turn_Card_" .. turnId
	turnCard.LayoutOrder = orderValue.Value
	turnCard.AnchorPoint = Vector2.new(1, 0)
	turnCard.BackgroundTransparency = 1
	turnCard.Position = UDim2.fromScale(1, 0)
	turnCard.Size = UDim2.fromScale(1, 0.08)

	actionValueValue.Parent = turnCard
	idValue.Parent = turnCard
	sideValue.Parent = turnCard
	orderValue.Parent = turnCard
	charNameValue.Parent = turnCard

	local leftBorder = Instance.new("Frame")
	leftBorder.Name = "Left_Border"
	leftBorder.AnchorPoint = Vector2.new(0, 0.5)
	leftBorder.BackgroundColor3 = Color3.new(1, 1, 1)
	leftBorder.BorderColor3 = Color3.new()
	leftBorder.BorderSizePixel = 0
	leftBorder.Position = UDim2.fromScale(0, 0.5)
	leftBorder.Size = UDim2.new(0, 2, 1, 0)

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Name = "UIGradient"
	uiGradient.Color = if side == "Allies"
		then ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 213)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 213)),
		}) -- Blue for allies
		else ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(213, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 0, 0)),
		}) -- Red for enemies
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, 0.2),
		NumberSequenceKeypoint.new(0.65, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	uiGradient.Parent = leftBorder

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

	-- Update the turn card's layout order whenever the order changes
	orderValue.Changed:Connect(function()
		turnCard.LayoutOrder = orderValue.Value
	end)

	return turnCard
end
