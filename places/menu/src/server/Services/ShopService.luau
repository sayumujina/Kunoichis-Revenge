local Server = game:GetService("ServerScriptService").Server
local Services = Server.Services
local GlobalDatastoreService = require(Server.GlobalServices.GlobalDataStoreService)
local LyraService = require(Server.GlobalServices.LyraService)

local ShopService = {}

--- Loads the shop data for a player and returns the available items.
--- @param player -- The player for whom to load the shop data.
--- @param shopName -- The name of the shop to load.
function ShopService.LoadShop(player: Player, shopName: string)
	local globalDataStore = GlobalDatastoreService.GetAsync()
	if not globalDataStore then
		warn("[ShopService] Failed to load shop data for player:", player.Name, "Shop Name:", shopName)
		return
	end

	-- Get the shop items
	local shopData = globalDataStore.Shops[shopName]
	local playerData = LyraService.GetData(player)
	local purchasedItemsFromShops = if playerData then (playerData.PurchasedItemsFromShops or {}) else {}
	local boughtItems = purchasedItemsFromShops[shopName] or {}
	local availableItems = {}
	for itemName, itemData in pairs(shopData.Items) do
		if not boughtItems[itemName] then
			table.insert(availableItems, itemData)
		end
	end

	return availableItems
end

return ShopService
