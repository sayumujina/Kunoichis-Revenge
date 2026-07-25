-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local HUDController = StarterPlayerScripts.Client.Controllers.HUDController
local WarningController = require(StarterPlayerScripts.Client.GlobalControllers.WarningController)
-- Components
local CreateTopInfoBar = require(HUDController.Components.Global.TopInfoBar_Frame)
local ItemFrame = require(script.Parent.Item)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)

--- Creates the shop frame with the given shop data
--- @param shopData -- The data for the shop, including items and purchased players
local function createShopFrame(shopId: string, shopData)
	local shopFrame = Instance.new("Frame")
	shopFrame.Name = "UI_Shop_Frame"
	shopFrame.BackgroundTransparency = 1
	shopFrame.Position = UDim2.fromScale(0.63, 0.155)
	shopFrame.Size = UDim2.fromScale(0.35, 0.82)

	local selectedItemValue = Instance.new("StringValue")
	selectedItemValue.Name = "SelectedItem_Value"
	selectedItemValue.Parent = shopFrame

	local shopBG = Instance.new("ImageLabel")
	shopBG.Name = "Shop_BG"
	shopBG.BackgroundTransparency = 1
	shopBG.Image = "rbxassetid://119027730570633"
	shopBG.ScaleType = Enum.ScaleType.Slice
	shopBG.Size = UDim2.fromScale(1, 1)
	shopBG.SliceCenter = Rect.new(32, 45, 849, 936)
	shopBG.ZIndex = 0
	--
	shopBG.Parent = shopFrame

	local shopScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Shop_ScreenGui")
	local function createBackground()
		local background = Instance.new("Frame")
		background.Name = "BG"
		background.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		background.BackgroundTransparency = 0.1
		background.Size = UDim2.fromScale(1, 1)
		background.Parent = shopScreenGui
		background.ZIndex = 0

		return background
	end
	createBackground()

	local shopNameLabel = Instance.new("TextLabel")
	shopNameLabel.Name = "ShopName_Label"
	shopNameLabel.BackgroundTransparency = 1
	shopNameLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	shopNameLabel.Position = UDim2.fromScale(0.15, 0.06)
	shopNameLabel.Size = UDim2.fromScale(0.7, 0.06)
	shopNameLabel.Text = "Character Shop"
	shopNameLabel.TextColor3 = Color3.new(1, 1, 1)
	shopNameLabel.TextScaled = true
	shopNameLabel.TextStrokeTransparency = 0
	--
	shopNameLabel.Parent = shopFrame

	local itemList = Instance.new("ScrollingFrame")
	itemList.Name = "Item_List"
	itemList.Active = true
	itemList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	itemList.BackgroundTransparency = 1
	itemList.CanvasSize = UDim2.fromScale(0, 1)
	itemList.LayoutOrder = 3
	itemList.Position = UDim2.fromScale(0.07, 0.15)
	itemList.ScrollBarImageColor3 = Color3.new()
	itemList.ScrollingDirection = Enum.ScrollingDirection.Y
	itemList.Size = UDim2.fromScale(0.88, 0.69)
	itemList.VerticalScrollBarInset = Enum.ScrollBarInset.Always

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Padding = UDim.new(0.02, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Wraps = true
	uIListLayout.Parent = itemList

	local player = game.Players.LocalPlayer
	local playerPurchasedItems = shopData.PurchasedPlayers[tostring(player.UserId)] or {}
	local sortedItems = {}

	-- Sort the items based on whether the player has purchased them or not, and then by item order
	for id, item in pairs(shopData.Items) do
		local purchases = playerPurchasedItems[item.Name] or 0

		table.insert(sortedItems, {
			Id = id,
			Item = item,
			Purchased = purchases,
			PurchasesLeft = item.PurchaseLimit :: number - purchases,
		})
	end

	table.sort(sortedItems, function(a, b)
		if a.PurchasesLeft == b.PurchasesLeft then
			return (a.Item.ItemOrder :: number) < (b.Item.ItemOrder :: number)
		end
		return a.PurchasesLeft > 0
	end)

	for layoutOrder, itemEntry in pairs(sortedItems) do
		local item = itemEntry.Item

		local itemFrame = ItemFrame.CreateItemCard(
			itemEntry.Id,
			item.Name,
			item.Type,
			item.Price,
			item.CurrencyType,
			item.Description,
			itemEntry.PurchasesLeft,
			layoutOrder
		)
		itemFrame.Parent = itemList
	end

	itemList.Parent = shopFrame

	local purchaseButton = Instance.new("TextButton")
	purchaseButton.Name = "Purchase_Button"
	purchaseButton.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	purchaseButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	purchaseButton.Position = UDim2.fromScale(0.3, 0.88)
	purchaseButton.Size = UDim2.fromScale(0.4, 0.06)
	purchaseButton.Text = "Purchase"
	purchaseButton.AutoButtonColor = false
	purchaseButton.TextColor3 = Color3.fromRGB(43, 26, 16)
	purchaseButton.TextScaled = true
	purchaseButton.TextStrokeColor3 = Color3.new(1, 1, 1)
	purchaseButton.TextStrokeTransparency = 0
	--
	purchaseButton.MouseButton1Click:Connect(function()
		local selectedItemId = selectedItemValue.Value
		if selectedItemId == "" then
			WarningController.DisplayWarning("No item selected for purchase.")
			return
		end

		local selectedItem = shopData.Items[selectedItemId]
		if not selectedItem then
			WarningController.DisplayWarning("Selected item does not exist.")
			return
		end

		-- Notify the server about the purchase attempt
		Zap.RequestPurchaseItem.Fire({
			shopId = shopId,
			itemId = selectedItemId,
		})
	end)

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = purchaseButton
	--
	purchaseButton.Parent = shopFrame

	local shopScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Shop_ScreenGui")
	CreateTopInfoBar.CreateTopInfoBar("SHOP").Parent = shopScreenGui

	return shopFrame
end

return {
	CreateShopFrame = createShopFrame,
}
