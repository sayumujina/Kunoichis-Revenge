local rep = game:GetService("ReplicatedStorage")
local GetAvatarImageForCharacter = require(rep.Shared.GlobalUtility.GetAvatarImageForCharacter)
local GetIconImageForItem = require(rep.Shared.GlobalUtility.GetIconImageForItem)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local WarningController = require(StarterPlayerScripts.Client.GlobalControllers.WarningController)
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Components
local ItemDetailsFrame = require(script.Parent.ItemDetails)

local function createPriceLabel(price: number, currency: string)
	local priceFrame = Instance.new("Frame")
	priceFrame.Name = "Price_Frame"
	priceFrame.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	priceFrame.Position = UDim2.fromScale(0, 0.8)
	priceFrame.Size = UDim2.fromScale(1, 0.2)
	priceFrame.ZIndex = 4

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "Price_Label"
	priceLabel.AutomaticSize = Enum.AutomaticSize.X
	priceLabel.BackgroundTransparency = 1
	priceLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	priceLabel.LayoutOrder = 1
	priceLabel.Position = UDim2.fromScale(0, 0.8)
	priceLabel.RichText = true
	priceLabel.Size = UDim2.fromScale(0, 1)
	priceLabel.Text = tostring(price)
	priceLabel.TextColor3 = Color3.new()
	priceLabel.TextScaled = true
	priceLabel.ZIndex = 4
	priceLabel.Parent = priceFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = priceFrame

	local currencyImage = Instance.new("ImageLabel")
	currencyImage.Name = "Currency_Image"
	currencyImage.AutomaticSize = Enum.AutomaticSize.X
	currencyImage.BackgroundTransparency = 1
	currencyImage.Image = GetIconImageForItem(currency)
	currencyImage.LayoutOrder = 2
	currencyImage.Size = UDim2.fromScale(0.9, 0.9)
	currencyImage.ZIndex = 4

	local uIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint1.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint1.Parent = currencyImage

	currencyImage.Parent = priceFrame

	local uICorner1 = Instance.new("UICorner")
	uICorner1.Name = "UICorner"
	uICorner1.BottomLeftRadius = UDim.new(0, 12)
	uICorner1.BottomRightRadius = UDim.new(0, 12)
	uICorner1.CornerRadius = UDim.new(0, 12)
	uICorner1.TopLeftRadius = UDim.new(0, 12)
	uICorner1.TopRightRadius = UDim.new(0, 12)
	uICorner1.Parent = priceFrame

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingTop = UDim.new(0.05, 0)
	uIPadding.Parent = priceFrame

	return priceFrame
end

local function createSoldOutOverlay()
	local soldOutFrame = Instance.new("Frame")
	soldOutFrame.Name = "SoldOut_Frame"
	soldOutFrame.BackgroundColor3 = Color3.new()
	soldOutFrame.BackgroundTransparency = 0.5
	soldOutFrame.Size = UDim2.fromScale(1, 1)
	soldOutFrame.ZIndex = 4

	local soldOutLabel = Instance.new("TextLabel")
	soldOutLabel.Name = "SoldOut_Label"
	soldOutLabel.BackgroundColor3 = Color3.new()
	soldOutLabel.BackgroundTransparency = 1
	soldOutLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	soldOutLabel.Position = UDim2.fromScale(0.15, 0.15)
	soldOutLabel.Size = UDim2.fromScale(0.7, 0.7)
	soldOutLabel.Text = "Sold Out"
	soldOutLabel.TextColor3 = Color3.new(1, 1, 1)
	soldOutLabel.TextScaled = true
	soldOutLabel.ZIndex = 4
	soldOutLabel.Parent = soldOutFrame

	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "UICorner"
	uICorner2.BottomLeftRadius = UDim.new(0, 12)
	uICorner2.BottomRightRadius = UDim.new(0, 12)
	uICorner2.CornerRadius = UDim.new(0, 12)
	uICorner2.TopLeftRadius = UDim.new(0, 12)
	uICorner2.TopRightRadius = UDim.new(0, 12)
	uICorner2.Parent = soldOutFrame

	return soldOutFrame
end
--- Update the selected item in the shop frame
--- @param itemId -- The ID of the item to set as selected
local function updateSelectedItem(itemId: string)
	local shopScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Shop_ScreenGui")
	local shopFrame = shopScreenGui:FindFirstChild("UI_Shop_Frame")
	local selectedItemValue = shopFrame:FindFirstChild("SelectedItem_Value")

	if selectedItemValue then
		selectedItemValue.Value = itemId
	end
end

--- Update the item's remaining purchases in the shop frame
--- @param itemId -- The ID of the item to update
--- @param purchasesLeft -- The number of purchases left for the item
local function updateItemRemainingPurchases(itemId: string, purchasesLeft: number)
	local shopScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Shop_ScreenGui")
	local shopFrame = shopScreenGui:FindFirstChild("UI_Shop_Frame")

	-- Find the item frame for the given itemId
	local itemList = shopFrame:FindFirstChild("Item_List")

	-- Update the remaining purchases value for the item frame
	local itemFrame = itemList:FindFirstChild(itemId .. "_Item_Frame")
	if itemFrame then
		local remainingPurchasesValue = itemFrame:FindFirstChild("RemainingPurchases_Value")
		if remainingPurchasesValue then
			remainingPurchasesValue.Value = purchasesLeft
		end
	end
end

--- Creates an item card for the shop with the given item details
--- @param itemId -- The ID of the item
--- @param itemName -- The name of the item
--- @param itemType -- The type of the item (e.g., "Character", "Weapon")
--- @param price -- The price of the item
--- @param currency -- The currency type for the price (e.g., "Coins", "Gems")
--- @param itemDescription -- A description of the item
--- @param purchasesLeft -- The number of purchases left for the item
--- @param itemOrder -- The order of the item in the shop layout
local function createItemCard(
	itemId: string,
	itemName: string,
	itemType: string,
	price: number,
	currency: string,
	itemDescription: string,
	purchasesLeft: number,
	itemOrder: number
)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = itemId .. "_Item_Frame"
	itemFrame.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	itemFrame.BackgroundTransparency = 0.8
	itemFrame.Size = UDim2.fromScale(0.268, 0.268)
	itemFrame.ZIndex = 3
	itemFrame.LayoutOrder = itemOrder

	local remainingPurchasesValue = Instance.new("IntValue")
	remainingPurchasesValue.Name = "RemainingPurchases_Value"
	remainingPurchasesValue.Value = purchasesLeft
	remainingPurchasesValue.Parent = itemFrame

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.Parent = itemFrame

	local itemImage = Instance.new("ImageLabel")
	itemImage.Name = "Item_Image"
	itemImage.BackgroundTransparency = 1
	itemImage.Image = if itemType == "Character"
		then GetAvatarImageForCharacter(itemId)
		else GetIconImageForItem(itemId)
	itemImage.Size = UDim2.fromScale(1, 1)
	itemImage.ZIndex = 3
	itemImage.Parent = itemFrame

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = itemFrame

	if purchasesLeft > 0 then
		local priceFrame = createPriceLabel(price, currency)
		priceFrame.Parent = itemFrame
	end

	if purchasesLeft <= 0 then
		local soldOutOverlay = createSoldOutOverlay()
		soldOutOverlay.Parent = itemFrame
	end

	local invisibleImageButton = Instance.new("ImageButton")
	invisibleImageButton.Name = "InvisibleImageButton"
	invisibleImageButton.BackgroundTransparency = 1
	invisibleImageButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	invisibleImageButton.ImageTransparency = 1
	invisibleImageButton.Size = UDim2.fromScale(1, 1)
	invisibleImageButton.ZIndex = itemFrame.ZIndex + 1
	invisibleImageButton.MouseButton1Click:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		if purchasesLeft <= 0 then
			WarningController.DisplayWarning(false, "This item is sold out.")
		else
			updateSelectedItem(itemId)

			-- Update the stage details to show the item details and purchase options
			local shopSelectionGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Shop_ScreenGui")
			local itemDetailsFrame = shopSelectionGui:FindFirstChild("UI_ItemDetail_Frame")

			-- Create the item detail frame and display it in the shop selection GUI
			if not itemDetailsFrame then
				ItemDetailsFrame.CreateItemDetailsFrame(itemName, purchasesLeft, itemDescription).Parent =
					shopSelectionGui
			end

			-- Just update the item details frame if it already exists
			ItemDetailsFrame.UpdateItemDetailsFrame(itemName, purchasesLeft, itemDescription)
		end
	end)
	invisibleImageButton.Parent = itemFrame

	-- Listen for changes in the remaining purchases value and update the UI accordingly
	remainingPurchasesValue.Changed:Connect(function()
		purchasesLeft = remainingPurchasesValue.Value
		if purchasesLeft <= 0 then
			-- Destroy the price frame if it exists
			local priceFrame = itemFrame:FindFirstChild("Price_Frame", true)
			if priceFrame then
				warn("Destroying price frame for item: " .. itemId)
				priceFrame:Destroy()
			else
				warn("Price frame not found for item: " .. itemId)
			end

			-- Create the sold-out overlay if it doesn't already exist
			local soldOutOverlay = itemFrame:FindFirstChild("SoldOut_Frame", true)
			if not soldOutOverlay then
				soldOutOverlay = createSoldOutOverlay()
				soldOutOverlay.Parent = itemFrame
			end
		else
			-- Destroy the sold-out overlay if it exists
			local soldOutOverlay = itemFrame:FindFirstChild("SoldOut_Frame", true)
			if soldOutOverlay then
				soldOutOverlay:Destroy()
			end

			-- Create the price frame if it doesn't already exist
			local priceFrame = itemFrame:FindFirstChild("Price_Frame", true)
			if not priceFrame then
				priceFrame = createPriceLabel(price, currency)
				priceFrame.Parent = itemFrame
			end
		end
	end)

	return itemFrame
end

return {
	CreateItemCard = createItemCard,
	UpdateSelectedItem = updateSelectedItem,
	UpdateItemRemainingPurchases = updateItemRemainingPurchases,
}
