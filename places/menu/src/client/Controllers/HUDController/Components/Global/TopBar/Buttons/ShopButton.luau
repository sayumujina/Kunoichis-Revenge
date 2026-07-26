local rep = game:GetService("ReplicatedStorage")
local icons = require(rep.Assets.Asphalt.Icons)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local HUDController = StarterPlayerScripts.Client.Controllers.HUDController
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Packages
local TopBarIcons = require(rep.Packages.topbarplus)
local Zap = require(StarterPlayerScripts.Client.zap)
-- Components
local ShopFrame = require(HUDController.Components.Shop.Shop_Frame)
local ShopMenu = require(HUDController.Components.Shop.ShopMenu)
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)
local SelectionState = require(script.Parent.SelectionState)

local shopIcon = TopBarIcons.new()

--- Creates the shop button in the top bar
local function createShopButton()
	-- Create a campaign icon
	shopIcon:setImage(icons.menu.UI_Icons_Store)
	shopIcon:setLabel("Shop")
	shopIcon:align("Right")
	shopIcon:modifyTheme({ "IconLabel", "FontFace", Font.new("rbxasset://fonts/families/Balthazar.json") })
	SelectionState.Register(shopIcon)
	shopIcon.selected:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		SelectionState.LockAll()

		-- Create a black screen
		CreateBlackScreen(0.6, 1, 0.4, function()
			local pendingGlobalData
			local pendingPlayerData
			local receiveGlobalDataConnection
			local receivePlayerDataConnection

			local function tryCreateShop()
				if not pendingGlobalData or not pendingPlayerData then
					return
				end

				local shopScreenGui =
					game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Shop_ScreenGui", true)
				if not shopScreenGui then
					return
				end

				-- Create the shop frame with the received data
				local shopFrame = shopScreenGui:FindFirstChild("UI_Shop_Frame", true)
				if shopFrame then
					ShopMenu.ToggleShopScreenGui(true)
				else
					ShopFrame.CreateShopFrame(
						"CharacterShop",
						pendingGlobalData.Shops["CharacterShop"],
						pendingPlayerData
					).Parent =
						shopScreenGui
				end

				receiveGlobalDataConnection()
				receivePlayerDataConnection()
			end

			receiveGlobalDataConnection = Zap.GlobalstoreDataResponse.On(function(globalData)
				pendingGlobalData = globalData
				tryCreateShop()
			end)

			receivePlayerDataConnection = Zap.PlayerstoreDataResponse.On(function(playerData)
				pendingPlayerData = playerData
				tryCreateShop()
			end)

			Zap.RequestGlobalstoreData.Fire()
			Zap.RequestPlayerstoreData.Fire()

			SelectionState.ApplySelectionLocks()
		end, nil)
	end)

	shopIcon.deselected:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		SelectionState.LockAll()

		-- Create a black screen
		CreateBlackScreen(0.6, 1, 0.4, function()
			-- Hide the shop screen GUI when the shop icon is deselected
			ShopMenu.ToggleShopScreenGui(false)

			SelectionState.ApplySelectionLocks()
		end, nil)
	end)
end

--- Toggles the shop button's selection state
--- @param select -- Whether to select or deselect the shop button
local function toggleShopButton(select: boolean)
	if select then
		shopIcon:select()
	else
		shopIcon:deselect()
	end
end

return {
	CreateShopButton = createShopButton,
	ToggleShopButton = toggleShopButton,
}
