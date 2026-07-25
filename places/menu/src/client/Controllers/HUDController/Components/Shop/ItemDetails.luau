--- Creates a UI frame that displays the details of an item in the shop, including its name, description, and the number of purchases left.
--- @param itemName -- The name of the item to display.
--- @param purchasesLeft -- The number of purchases left for the item.
--- @param itemDescription -- The description of the item to display.
local function createItemDetailsFrame(itemName: string, purchasesLeft: number, itemDescription: string)
	local itemDetailFrame = Instance.new("Frame")
	itemDetailFrame.Name = "UI_ItemDetail_Frame"
	itemDetailFrame.BackgroundTransparency = 1
	itemDetailFrame.Position = UDim2.fromScale(0.26, 0.155)
	itemDetailFrame.Size = UDim2.fromScale(0.35, 0.82)

	local bG = Instance.new("ImageLabel")
	bG.Name = "BG"
	bG.BackgroundTransparency = 1
	bG.Image = "rbxassetid://119027730570633"
	bG.ScaleType = Enum.ScaleType.Slice
	bG.Size = UDim2.fromScale(1, 1)
	bG.SliceCenter = Rect.new(32, 45, 849, 936)
	bG.ZIndex = 0
	bG.Parent = itemDetailFrame

	local itemDetailLabel = Instance.new("TextLabel")
	itemDetailLabel.Name = "ItemDetail_Label"
	itemDetailLabel.BackgroundTransparency = 1
	itemDetailLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	itemDetailLabel.Position = UDim2.fromScale(0.15, 0.06)
	itemDetailLabel.Size = UDim2.fromScale(0.7, 0.06)
	itemDetailLabel.Text = "Item Detail"
	itemDetailLabel.TextColor3 = Color3.new(1, 1, 1)
	itemDetailLabel.TextScaled = true
	itemDetailLabel.TextStrokeTransparency = 0
	itemDetailLabel.Parent = itemDetailFrame

	local line = Instance.new("Frame")
	line.Name = "Line"
	line.BackgroundColor3 = Color3.new(1, 1, 1)
	line.BorderColor3 = Color3.new()
	line.BorderSizePixel = 0
	line.Position = UDim2.fromScale(0.2, 0.13)
	line.Size = UDim2.fromScale(0.6, 0.005)
	line.Parent = itemDetailFrame

	local itemNameLabel = Instance.new("TextLabel")
	itemNameLabel.Name = "ItemName_Label"
	itemNameLabel.BackgroundTransparency = 1
	itemNameLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	itemNameLabel.Position = UDim2.fromScale(0.2, 0.145)
	itemNameLabel.Size = UDim2.fromScale(0.6, 0.04)
	itemNameLabel.Text = itemName
	itemNameLabel.TextColor3 = Color3.new(1, 1, 1)
	itemNameLabel.TextScaled = true
	itemNameLabel.TextStrokeTransparency = 0
	itemNameLabel.Parent = itemDetailFrame

	local itemDescriptionFrame = Instance.new("Frame")
	itemDescriptionFrame.Name = "ItemDescription_Frame"
	itemDescriptionFrame.BackgroundTransparency = 1
	itemDescriptionFrame.Position = UDim2.fromScale(0.07, 0.235)
	itemDescriptionFrame.Size = UDim2.fromScale(0.86, 0.6)

	local itemDescriptionLabel = Instance.new("TextLabel")
	itemDescriptionLabel.Name = "ItemDescription_Label"
	itemDescriptionLabel.AutomaticSize = Enum.AutomaticSize.Y
	itemDescriptionLabel.BackgroundTransparency = 1
	itemDescriptionLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	itemDescriptionLabel.Size = UDim2.fromScale(1, 1)
	itemDescriptionLabel.Text = itemDescription
	itemDescriptionLabel.TextColor3 = Color3.new(1, 1, 1)
	itemDescriptionLabel.TextSize = 24
	itemDescriptionLabel.TextStrokeTransparency = 0
	itemDescriptionLabel.TextWrapped = true
	itemDescriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
	itemDescriptionLabel.Parent = itemDescriptionFrame

	itemDescriptionFrame.Parent = itemDetailFrame

	local itemPurchaseLimitLabel = Instance.new("TextLabel")
	itemPurchaseLimitLabel.Name = "ItemPurchaseLimit_Label"
	itemPurchaseLimitLabel.BackgroundTransparency = 1
	itemPurchaseLimitLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	itemPurchaseLimitLabel.Position = UDim2.fromScale(0.2, 0.19)
	itemPurchaseLimitLabel.Size = UDim2.fromScale(0.6, 0.04)
	itemPurchaseLimitLabel.Text = "Purchases Left: " .. tostring(purchasesLeft)
	itemPurchaseLimitLabel.TextColor3 = Color3.new(1, 1, 1)
	itemPurchaseLimitLabel.TextScaled = true
	itemPurchaseLimitLabel.TextStrokeTransparency = 0
	itemPurchaseLimitLabel.Parent = itemDetailFrame

	return itemDetailFrame
end

--- Updates the item detail frame with the provided item information. If the item detail frame does not exist, it will log a warning.
--- @param itemName -- The name of the item to display.
--- @param purchasesLeft -- The number of purchases left for the item.
--- @param itemDescription -- The description of the item to display.
local function updateItemDetailsFrame(itemName: string, purchasesLeft: number, itemDescription: string)
	local shopScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Shop_ScreenGui")
	local itemDetailFrame = shopScreenGui:FindFirstChild("UI_ItemDetail_Frame")
	if not itemDetailFrame then
		warn("Item detail frame not found.")
		return
	end

	local itemNameLabel = itemDetailFrame:FindFirstChild("ItemName_Label")
	if itemNameLabel and itemNameLabel:IsA("TextLabel") then
		itemNameLabel.Text = itemName
	end

	local itemDescriptionLabel =
		itemDetailFrame:FindFirstChild("ItemDescription_Frame"):FindFirstChild("ItemDescription_Label")
	if itemDescriptionLabel and itemDescriptionLabel:IsA("TextLabel") then
		itemDescriptionLabel.Text = itemDescription
	end

	local itemPurchaseLimitLabel = itemDetailFrame:FindFirstChild("ItemPurchaseLimit_Label")
	if itemPurchaseLimitLabel and itemPurchaseLimitLabel:IsA("TextLabel") then
		itemPurchaseLimitLabel.Text = "Purchases Left: " .. tostring(purchasesLeft)
	end
end

return {
	CreateItemDetailsFrame = createItemDetailsFrame,
	UpdateItemDetailsFrame = updateItemDetailsFrame,
}
