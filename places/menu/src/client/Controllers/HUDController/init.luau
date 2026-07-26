local rep = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local WarningController = require(StarterPlayerScripts.Client.GlobalControllers.WarningController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Components
local CreateTopBar = require(script.Components.Global.TopBar)
local StageSelectionMenu = require(script.Components.Stages.StageSelectionMenu)
local ShopFrame = require(script.Components.Shop.Shop_Frame)

local HUDController = {}

--- Called when the controller starts
function HUDController.OnStart()
	CreateTopBar()

	-- Listens to purchase success events from the server and updates the shop UI accordingly
	Zap.PurchaseResponse.On(function(purchaseData)
		local shopScreenGui = playerGui:FindFirstChild("Shop_ScreenGui")
		if not shopScreenGui then
			return
		end

		if not purchaseData.success then
			WarningController.DisplayWarning("Purchase failed for item: " .. purchaseData.itemId)
			return
		else
			WarningController.DisplayWarning("Purchase successful for item: " .. purchaseData.itemId)
		end

		local shopFrame = shopScreenGui:FindFirstChild("UI_Shop_Frame")
		if shopFrame then
			local itemId = purchaseData.itemId
			local purchasesLeft = purchaseData.purchasesLeft
			-- Update the item's remaining purchases in the shop frame
			local ItemFrame = require(script.Components.Shop.Item)
			ItemFrame.UpdateItemRemainingPurchases(itemId, purchasesLeft)
		end
	end)

	Zap.PlayerDatastoreChanged.On(function(playerData)
		local kobanAmount = playerData.Currencies.Koban or 0
		ShopFrame.UpdateKobanAmount(kobanAmount)
	end)
end

--- Initializes the HUDController
function HUDController.Init()
	-- Create a screen GUI for the player if it doesn't exist
	if not playerGui:FindFirstChild("Global_ScreenGui", true) then
		local globalScreenGui = Instance.new("ScreenGui")
		globalScreenGui.Name = "Global_ScreenGui"
		globalScreenGui.Parent = playerGui
		globalScreenGui.ScreenInsets = Enum.ScreenInsets.None
		globalScreenGui.DisplayOrder = 1000
	end

	-- Create a screen GUI for the player if it doesn't exist
	if not playerGui:FindFirstChild("Shop_ScreenGui", true) then
		local shopScreenGui = Instance.new("ScreenGui")
		shopScreenGui.Name = "Shop_ScreenGui"
		shopScreenGui.Parent = playerGui
		shopScreenGui.ScreenInsets = Enum.ScreenInsets.None
		shopScreenGui.DisplayOrder = 2
	end

	local globalScreenGui = playerGui:FindFirstChild("Global_ScreenGui", true)

	-- Initialize the stage selection menu
	StageSelectionMenu.InitStageSelectionMenu()
end

return HUDController
