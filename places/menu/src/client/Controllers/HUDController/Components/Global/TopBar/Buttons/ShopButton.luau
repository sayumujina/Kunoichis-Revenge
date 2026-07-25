local rep = game:GetService("ReplicatedStorage")
local icons = require(rep.Assets.Asphalt.Icons)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local HUDController = StarterPlayerScripts.Client.Controllers.HUDController
-- Packages
local TopBarIcons = require(rep.Packages.topbarplus)
local Zap = require(StarterPlayerScripts.Client.zap)
-- Components
local ShopFrame = require(HUDController.Components.Shop.Shop_Frame)
local ShopMenu = require(HUDController.Components.Shop.ShopMenu)
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)

return function()
	-- Create a campaign icon
	local shopIcon = TopBarIcons.new()
	shopIcon:setImage(icons.menu.UI_Icons_Store)
	shopIcon:setLabel("Shop")
	shopIcon:align("Right")
	shopIcon:modifyTheme({ "IconLabel", "FontFace", Font.new("rbxasset://fonts/families/Balthazar.json") })
	shopIcon.selected:Connect(function()
		-- Lock the icon
		shopIcon:lock()

		-- Create a black screen
		CreateBlackScreen(0.6, 1, 0.4, function()
			Zap.RequestGlobalstoreData.Fire()

			local receiveDataConnection
			receiveDataConnection = Zap.GlobalstoreDataResponse.On(function(globalData)
				local shopScreenGui =
					game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Shop_ScreenGui", true)
				if not shopScreenGui then
					return
				end

				-- Create the shop frame with the received global data
				local shopFrame = shopScreenGui:FindFirstChild("UI_Shop_Frame", true)
				if shopFrame then
					ShopMenu.ToggleShopScreenGui(true)
				else
					ShopFrame.CreateShopFrame("CharacterShop", globalData.Shops["CharacterShop"]).Parent = shopScreenGui
				end

				-- Disconnect the event listener after receiving the data
				receiveDataConnection()
			end)

			shopIcon:unlock()
		end, nil)
	end)

	shopIcon.deselected:Connect(function()
		-- Lock the icon
		shopIcon:lock()

		-- Create a black screen
		CreateBlackScreen(0.6, 1, 0.4, function()
			-- Hide the shop screen GUI when the shop icon is deselected
			ShopMenu.ToggleShopScreenGui(false)

			shopIcon:unlock()
		end, nil)
	end)
end
