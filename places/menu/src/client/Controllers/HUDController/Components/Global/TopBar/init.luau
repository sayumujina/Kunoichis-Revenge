local CreateShopButton = require(script.Buttons.ShopButton)
local CreateCampaignButton = require(script.Buttons.CampaignButton)

return function()
	CreateShopButton.CreateShopButton()
	CreateCampaignButton.CreateCampaignButton()

	-- Open the shop button by default when the game starts
	CreateShopButton.ToggleShopButton(true)
end
