local rep = game:GetService("ReplicatedStorage")
local Loader = require(rep.Modules.GlobalModules.Loader)
-- Services
local MenuServer = script
local Services = game:GetService("ServerScriptService").Server.Services
local TeleportService = game:GetService("TeleportService")
--
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)
--
local Zap = require(Services.Parent.zap)

-- Place ids
local GAME_PLACE_ID = 137371455542351

-- Disable character autoload
game.Players.CharacterAutoLoads = false

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
	tpOptions:SetTeleportData({
		chars = spawnData.chars,
		stageId = spawnData.stageId :: string,
		worldId = spawnData.worldId :: string,
	})

	warn(
		"Teleporting player",
		player.Name,
		"to game place with stageId:",
		spawnData.stageId,
		"and worldId:",
		spawnData.worldId
	)
	TeleportService:TeleportAsync(GAME_PLACE_ID, { player }, tpOptions)
end)
