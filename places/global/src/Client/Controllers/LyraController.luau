-- Core services
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
-- Remotes
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)

--- @class LyraController
--- @tag Controller
--- @client
--- Manages core Lyra framework functionalities on the client side.

local LyraController = {}

LyraController.Loaded = false

--- @function LyraController.OnStart
--- @within LyraController
--- Initializes the Lyra controller and connects event listeners.
function LyraController.OnStart()
	Zap.PlayerDatastoreLoaded.On(function(event)
		print("LyraController: Loaded player datastore", event)
		LyraController.Loaded = true
	end)

	Zap.RequestPlayerstoreData.Fire()
end

return LyraController
