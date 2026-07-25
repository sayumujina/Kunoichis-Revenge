-- Core services
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
-- Remotes
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)

--- @class GlobalDataStoreController
--- @tag Controller
--- @client
--- Manages core Lyra framework functionalities on the client side.

local GlobalDataStoreController = {}

GlobalDataStoreController.Loaded = false

--- @function GlobalDataStoreController.OnStart
--- @within GlobalDataStoreController
--- Initializes the GlobalDataStore controller and connects event listeners.
function GlobalDataStoreController.OnStart()
	Zap.GlobalDatastoreLoaded.On(function(event)
		print("GlobalDataStoreController: Loaded player datastore", event)
		GlobalDataStoreController.Loaded = true
	end)

	Zap.RequestGlobalstoreData.Fire()
end

return GlobalDataStoreController
