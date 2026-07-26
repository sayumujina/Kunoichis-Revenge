local rep = game:GetService("ReplicatedStorage")
local icons = require(rep.Assets.Asphalt.Icons)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local HUDController = StarterPlayerScripts.Client.Controllers.HUDController
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Packages
local TopBarIcons = require(rep.Packages.topbarplus)
-- Components
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
			ShopMenu.ToggleShopScreenGui(true)
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
