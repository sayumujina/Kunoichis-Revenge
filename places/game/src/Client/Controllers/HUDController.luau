local HUDController = {}

--- Called when the controller starts
function HUDController.OnStart() end

function HUDController.Init()
	local player = game.Players.LocalPlayer

	-- Create a HUD folder within player gui
	local hudFolder = Instance.new("Folder")
	hudFolder.Name = "HUD"
	hudFolder.Parent = player.PlayerGui

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ScreenGui"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = hudFolder

	local UITurnsFrame = Instance.new("Frame")
	UITurnsFrame.Name = "UI_TurnsFrame"
	UITurnsFrame.Active = true
	UITurnsFrame.BackgroundTransparency = 1
	UITurnsFrame.Position = UDim2.fromScale(0.02, 0.02)
	UITurnsFrame.Size = UDim2.fromScale(0.075, 0.6)

	local LeftBorder = Instance.new("Frame")
	LeftBorder.Name = "Left_Border"
	LeftBorder.AnchorPoint = Vector2.new(0, 0.5)
	LeftBorder.BackgroundColor3 = Color3.new(1, 1, 1)
	LeftBorder.BorderColor3 = Color3.new()
	LeftBorder.BorderSizePixel = 0
	LeftBorder.Position = UDim2.fromScale(0, 0.5)
	LeftBorder.Size = UDim2.new(0, 2, 1.05, 0)

	local UIGradient = Instance.new("UIGradient")
	UIGradient.Name = "UIGradient"
	UIGradient.Rotation = 90
	UIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, 0.2),
		NumberSequenceKeypoint.new(0.65, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	UIGradient.Parent = LeftBorder

	LeftBorder.Parent = UITurnsFrame

	local TurnCardContainer = Instance.new("Frame")
	TurnCardContainer.Name = "TurnCard_Container"
	TurnCardContainer.AnchorPoint = Vector2.new(1, 0)
	TurnCardContainer.BackgroundTransparency = 1
	TurnCardContainer.Position = UDim2.fromScale(1, 0)
	TurnCardContainer.Size = UDim2.fromScale(0.9, 1)

	local TurnCard = Instance.new("Frame")
	TurnCard.Name = "Turn_Card"
	TurnCard.AnchorPoint = Vector2.new(1, 0)
	TurnCard.BackgroundTransparency = 1
	TurnCard.Position = UDim2.fromScale(1, 0)
	TurnCard.Size = UDim2.fromScale(1, 0.08)

	local LeftBorder1 = Instance.new("Frame")
	LeftBorder1.Name = "Left_Border"
	LeftBorder1.AnchorPoint = Vector2.new(0, 0.5)
	LeftBorder1.BackgroundColor3 = Color3.new(1, 1, 1)
	LeftBorder1.BorderColor3 = Color3.new()
	LeftBorder1.BorderSizePixel = 0
	LeftBorder1.Position = UDim2.fromScale(0, 0.5)
	LeftBorder1.Size = UDim2.new(0, 2, 1, 0)

	local UIGradient1 = Instance.new("UIGradient")
	UIGradient1.Name = "UIGradient"
	UIGradient1.Rotation = 90
	UIGradient1.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, 0.2),
		NumberSequenceKeypoint.new(0.65, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	UIGradient1.Parent = LeftBorder1

	LeftBorder1.Parent = TurnCard

	local BG = Instance.new("Frame")
	BG.Name = "BG"
	BG.AnchorPoint = Vector2.new(1, 0)
	BG.BackgroundColor3 = Color3.new(1, 1, 1)
	BG.BorderColor3 = Color3.new()
	BG.BorderSizePixel = 0
	BG.Position = UDim2.fromScale(1, 0)
	BG.Size = UDim2.fromScale(0.95, 1)

	local UIGradient2 = Instance.new("UIGradient")
	UIGradient2.Name = "UIGradient"
	UIGradient2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.35, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	UIGradient2.Parent = BG

	BG.Parent = TurnCard

	TurnCard.Parent = TurnCardContainer

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Name = "UIListLayout"
	UIListLayout.Padding = UDim.new(0.02, 0)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = TurnCardContainer

	local TurnCard1 = Instance.new("Frame")
	TurnCard1.Name = "Turn_Card"
	TurnCard1.AnchorPoint = Vector2.new(1, 0)
	TurnCard1.BackgroundTransparency = 1
	TurnCard1.Position = UDim2.fromScale(1, 0)
	TurnCard1.Size = UDim2.fromScale(1, 0.08)

	local LeftBorder2 = Instance.new("Frame")
	LeftBorder2.Name = "Left_Border"
	LeftBorder2.AnchorPoint = Vector2.new(0, 0.5)
	LeftBorder2.BackgroundColor3 = Color3.new(1, 1, 1)
	LeftBorder2.BorderColor3 = Color3.new()
	LeftBorder2.BorderSizePixel = 0
	LeftBorder2.Position = UDim2.fromScale(0, 0.5)
	LeftBorder2.Size = UDim2.new(0, 2, 1, 0)

	local UIGradient3 = Instance.new("UIGradient")
	UIGradient3.Name = "UIGradient"
	UIGradient3.Rotation = 90
	UIGradient3.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, 0.2),
		NumberSequenceKeypoint.new(0.65, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	UIGradient3.Parent = LeftBorder2

	LeftBorder2.Parent = TurnCard1

	TurnCard1.Parent = TurnCardContainer

	TurnCardContainer.Parent = UITurnsFrame

	UITurnsFrame.Parent = ScreenGui
end

return HUDController
