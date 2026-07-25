-- Services
local Server = game:GetService("ServerScriptService").Server
local Services = Server.Services
local DataStoreService = game:GetService("DataStoreService")
local LyraService = require(Server.GlobalServices.LyraService)
--
local template = require(script.template)
local schema = require(script.schema)
local mocks = require(script.mocks)
-- Packages
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local Zap = require(Services.Parent.zap)
local TableUtil = require(rep.Packages.TableUtil)

--- @class LyraService
--- @tag Service
--- @server
--- Do not access this service directly. Instead, use intemediary services or systems to interact with it.
--- Handles global data management using Lyra framework.
local GlobalDataStoreService = {}

local DATASTORE_NAME = "DEV_GlobalDatastore_21_07_2026"
local DATASTORE_VERSION = "Version_1"
local USE_MOCK = false

local globalStore

function GlobalDataStoreService.Init()
	local success, store = pcall(function()
		return DataStoreService:GetDataStore(DATASTORE_NAME)
	end)

	if success then
		globalStore = store
		-- Zap.GlobalDatastoreLoaded.Fire(globalStore)
		print("[GlobalDataStoreService] Successfully connected to global datastore:", DATASTORE_NAME)
	else
		warn("[GlobalDataStoreService] Failed to connect to global datastore:", DATASTORE_NAME, store)
	end
end

function GlobalDataStoreService.OnStart()
	-- Listen for player leaving to save global data if needed
	game.Players.PlayerRemoving:Connect(function(_)
		-- DEBUG: Reset the global data to the template on server shutdown for testing purposes.
		-- local success, updatedStore = pcall(function()
		-- 	return globalStore:UpdateAsync(DATASTORE_VERSION, function(_)
		-- 		return template
		-- 	end)
		-- end)
		-- if success then
		-- 	warn("Global data saved successfully.", updatedStore)
		-- else
		-- 	warn("Failed to save global data: " .. tostring(updatedStore))
		-- end
	end)

	-- Listen for requests to fetch global data from clients
	Zap.RequestGlobalstoreData.On(function(player)
		local globalData = globalStore:GetAsync(DATASTORE_VERSION)
		warn("[GlobalDataStoreService] Global Data for key '" .. DATASTORE_VERSION .. "':", globalData)
		Zap.GlobalstoreDataResponse.Fire(player, globalData[DATASTORE_VERSION])
	end)

	-- Listen for purchase requests statuses from the client and handle them accordingly
	Zap.RequestPurchaseItem.On(function(player, requestData)
		local itemId = requestData.itemId
		local shopId = requestData.shopId

		-- Fetch the global data
		local globalData = globalStore:GetAsync(DATASTORE_VERSION)
		if not globalData then
			return
		end

		local shopData = globalData[DATASTORE_VERSION].Shops[shopId]
		if not shopData then
			return
		end

		local itemData = shopData.Items[itemId]
		if not itemData then
			return
		end

		-- Check if the player has any purchases left for this item
		local playerPurchasedItems = shopData.PurchasedPlayers[tostring(player.UserId)] or {}
		local purchasesLeft = itemData.PurchaseLimit - (playerPurchasedItems[itemId] or 0)
		if purchasesLeft <= 0 then
			Zap.PurchaseResponse.Fire(player, {
				itemId = itemId,
				success = false,
				purchasesLeft = purchasesLeft,
			})
			return
		end

		-- Check if the player has enough currency to make the purchase
		local itemCurrencyType = itemData.CurrencyType
		local itemPrice = itemData.Price
		local playerCurrency = LyraService.GetData(player).Currencies[itemCurrencyType] or 0

		-- If the player doesn't have enough currency, send a failure response
		if playerCurrency < itemPrice then
			Zap.PurchaseResponse.Fire(player, {
				itemId = itemId,
				success = false,
				purchasesLeft = purchasesLeft,
			})
		-- Else, update the player's currency and the global data to reflect the purchase
		else
			local playerStore = LyraService.GetPlayerStore()
			playerStore:updateImmutableAsync(player, function(playerData)
				local newData = TableUtil.Copy(playerData, true)

				-- Subtract the item price from the player's currency
				newData.Currencies[itemCurrencyType] = newData.Currencies[itemCurrencyType] - itemPrice

				-- Add to owned characters if the item is a character
				if itemData.Type == "Character" then
					local newCharacterInfo = {
						Level = 1,
						Experience = 0,
						AscensionStage = 0,
					}
					newData.OwnedCharacters[itemData.Name] = newCharacterInfo
				end

				return newData
			end)

			-- Append the purchase of the player to the global data store
			globalStore:UpdateAsync(DATASTORE_VERSION, function(oldData)
				local newData = TableUtil.Copy(oldData, true)
				local purchasedPlayersData = newData[DATASTORE_VERSION].Shops[shopId].PurchasedPlayers
				--
				purchasedPlayersData[tostring(player.UserId)] = purchasedPlayersData[tostring(player.UserId)] or {}
				purchasedPlayersData[tostring(player.UserId)][itemId] = (
					purchasedPlayersData[tostring(player.UserId)][itemId] or 0
				) + 1
				return newData
			end)

			-- Send a success response back to the player with the updated number of purchases left
			Zap.PurchaseResponse.Fire(player, {
				itemId = itemId,
				success = true,
				purchasesLeft = purchasesLeft - 1,
			})
			warn("[GlobalDataStoreService] Player purchased ItemId:", itemId, "Remaining purchases:", purchasesLeft - 1)
		end
	end)
end

--- Fetches the global data for the given key from the DataStore.
--- @param key -- The key for the global data to fetch.
function GlobalDataStoreService.GetAsync(): _TYPES.GlobalDataStore?
	local success, data = pcall(function()
		return globalStore:GetAsync(DATASTORE_VERSION)
	end)

	if success then
		return data
	else
		warn("Failed to retrieve global data for key '" .. DATASTORE_VERSION .. "': " .. tostring(data))
		return nil
	end
end

--- Updates the global data for the given key in the DataStore using the provided update function.
--- @param key -- The key for the global data to update.
--- @param updateFunction -- A function that takes the old data and returns the new data.
function GlobalDataStoreService.UpdateAsync(
	updateFunction: (oldData: _TYPES.GlobalDataStore?) -> _TYPES.GlobalDataStore
): _TYPES.GlobalDataStore?
	local success, updatedData = pcall(function()
		return globalStore:UpdateAsync(DATASTORE_VERSION, updateFunction)
	end)

	if success then
		return updatedData
	else
		warn("Failed to update global data for key '" .. DATASTORE_VERSION .. "': " .. tostring(updatedData))
		return nil
	end
end

return GlobalDataStoreService
