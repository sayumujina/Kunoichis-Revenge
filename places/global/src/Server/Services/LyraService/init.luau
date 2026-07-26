-- Packages
local rep = game:GetService("ReplicatedStorage")
local Lyra = require(rep.Packages.Lyra)
-- Remotes
local Zap = require(game:GetService("ServerScriptService").Server.Services.Parent.zap)
-- Services
local Players = game:GetService("Players")
local Signal = require(rep.Packages.Signal)
local Loader = require(rep.Modules.GlobalModules.Loader)
local _TYPES = require(rep.Data.data_Types)
--
local template = require(script.template)
local schema = require(script.schema)
local mocks = require(script.mocks)

--- @class LyraService
--- @tag Service
--- @server
--- Do not access this service directly. Instead, use intemediary services or systems to interact with it.
--- Handles player data management using Lyra framework.
local LyraService = {}

local DATASTORE_NAME = "DEV_PlayerDatastore_21_07_2026"

-- In Studio, use Lyra's in-memory mock DataStore
local USE_MOCK = false

LyraService.InitialDataLoaded = Signal.new() -- Fires when initial data is loaded for a player. Passes the player and their data.

local function createPlayerStore()
	return Lyra.createPlayerStore({
		name = DATASTORE_NAME,
		useDSSLocking = true,
		useMock = USE_MOCK,
		--
		template = USE_MOCK and mocks or template,
		schema = schema, --TODO: add schema validation once prod is up,
		changedCallbacks = {
			function(key, newData, oldData)
				local player = Players:GetPlayerByUserId(tonumber(key))
				if not player then
					return
				end
				-- Fires the entire player data changed event.
				-- TODO: This is not efficient for large data, consider diffing changes.
				warn("Player data changed for ", player.Name, " with new data: ", newData)
				Zap.PlayerDatastoreChanged.Fire(player, newData :: { [string]: any })
			end,
		},
	})
end
-- Create a new store
local store = createPlayerStore()

--- Get the player store.
--- @error Because this returns the store directly, be cautious when using it to avoid unintended side effects.
--- @within LyraService
--- @param player Player -- return the player
--- @return The playerStore instance
function LyraService.GetPlayerStore()
	return store
end

--- Get player data
--- @within LyraService
--- @param player -- The player whose data to get
function LyraService.GetData(player: Player)
	return store:getAsync(player)
end

--- Peeks at player data
--- @within LyraService
--- @param player Player -- The player whose data to peek at
function LyraService.PeekData(player: Player)
	return store:peekAsync(player.UserId)
end

--- Initializes the LyraService
--- @within LyraService
function LyraService.OnStart()
	-- Call the onstart of all children handler
	Loader.SpawnAllWithArgs(
		Loader.LoadDescendants(script, function(module)
			return (module.Name:match("Handler$") ~= nil)
		end),
		"OnStart"
	)
	-- Helper function to handle player joining
	local function onPlayerAdded(player: Player)
		-- Load player data
		store:load(player):andThen(function()
			local playerData = store:getAsync(player)
			-- warn(playerData)
			-- Sends initial data to player once loaded
			LyraService.InitialDataLoaded:Fire(player, playerData)
			Zap.PlayerDatastoreLoaded.Fire(player, playerData)
		end, function(err)
			warn("Error loading player data for " .. player.Name .. ": " .. err)
			-- Handle loading error (e.g., kick player, retry, etc.)
			player:Kick("Error loading your data:" .. err)
		end)

		-- DEBUG: Reset data for testing
		store:updateImmutableAsync(player, function(data)
			if data then
				warn(template)
				return template
			end
			return false
		end)
	end

	-- Listens to player joining event
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)

	-- Listens to player leaving event
	Players.PlayerRemoving:Connect(function(player)
		-- Clear the internal PlayersData table and unload the player data
		store:unloadAsync(player)
	end)

	Zap.RequestPlayerstoreData.On(function(player)
		local playerData = store:getAsync(player)
		warn("[LyraService] Player Data:", playerData)
		--
		Zap.PlayerstoreDataResponse.Fire(player, playerData)
	end)

	-- Ensure data is saved when the server shuts down
	game:BindToClose(function()
		store:closeAsync()
	end)
end

return LyraService
