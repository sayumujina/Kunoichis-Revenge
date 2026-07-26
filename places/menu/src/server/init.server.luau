local rep = game:GetService("ReplicatedStorage")
local Loader = require(rep.Modules.GlobalModules.Loader)
-- Services
local MenuServer = script
local Server = game:GetService("ServerScriptService").Server
local Services = Server.Services
local TeleportService = game:GetService("TeleportService")
local GlobalDataStoreService = require(Server.GlobalServices.GlobalDataStoreService)
local LyraService = require(Server.GlobalServices.LyraService)
--
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)
--
local Zap = require(Services.Parent.zap)

-- Place ids
local GAME_PLACE_ID = 137371455542351

-- Disable character autoload
-- game.Players.CharacterAutoLoads = false

GlobalDataStoreService.Init()

-- Load all services
Loader.SpawnAll(
	Loader.LoadDescendants(MenuServer, function(module)
		return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
	end),
	"OnStart"
)

-- Listens to spawn request from clients
Zap.RequestSpawn.On(function(player, spawnData)
	local code = TeleportService:ReserveServer(GAME_PLACE_ID)
	local tpOptions = Instance.new("TeleportOptions")
	tpOptions.ReservedServerAccessCode = code

	local playerData
	local success, _ = pcall(function()
		playerData = LyraService.GetData(player)
	end)
	local spawnChars = {} :: { name: string, level: number } -- Prepare the characters to spawn with their levels
	if not success then
		warn("Failed to get player data for", player.Name, ":", playerData)
		return
	end

	for _, char in pairs(spawnData.chars) do
		if playerData and playerData.OwnedCharacters and playerData.OwnedCharacters[char] then
			table.insert(spawnChars, { name = char, level = playerData.OwnedCharacters[char].Level })
		else
			table.insert(spawnChars, { name = char, level = 1 }) -- Default level if not found
		end
	end

	tpOptions:SetTeleportData({
		chars = spawnChars,
		stageId = spawnData.stageId :: string,
		worldId = spawnData.worldId :: string,
	})

	TeleportService:TeleportAsync(GAME_PLACE_ID, { player }, tpOptions)
end)
