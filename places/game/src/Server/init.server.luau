local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Server = game:GetService("ServerScriptService").Server
local Services = Server.Services
local TeleportService = game:GetService("TeleportService")
local SpawnService = require(Services.SpawnService)
-- local GlobalDataStoreService = require(Server.GlobalServices.GlobalDataStoreService)
-- Modules
local Loader = require(rep.Modules.GlobalModules.Loader)
-- Packages
local Zap = require(Services.Parent.zap)
-- Contants
local MENU_PLACE_ID = 87694110914637
local DEFAULT_SPAWN_CHARACTERS = { "Rin", "Hayumi", "Setsuna" }
local DEFAULT_STAGE_ID = "2-1"
local DEFAULT_WORLD_ID = "World2"

-- Disable character autoload
game.Players.CharacterAutoLoads = false

-- GlobalDataStoreService.Init()

-- Load all services
Loader.SpawnAll(
	Loader.LoadDescendants(Server, function(module)
		return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
	end),
	"OnStart"
)

-- Initiation complete
print("Lifecycle: Server initiated")

-- Prepare collision group for the client to set
local PhysicsService = game:GetService("PhysicsService")

-- Register two collision groups
PhysicsService:RegisterCollisionGroup("Chars")

-- Set cubes to be non-collidable with doors
PhysicsService:CollisionGroupSetCollidable("Chars", "Chars", false)

-- Listens to player adding event
game.Players.PlayerAdded:Connect(function(player)
	local tpData = player:GetJoinData().TeleportData :: {
		chars: { string },
		stageId: string,
		worldId: string,
	}?

	-- local tpData = {
	-- 	chars = DEFAULT_SPAWN_CHARACTERS,
	-- 	stageId = DEFAULT_STAGE_ID,
	-- 	worldId = DEFAULT_WORLD_ID,
	-- }

	task.defer(function()
		task.delay(2, function()
			local charsToSpawn = if tpData and tpData.chars then tpData.chars else DEFAULT_SPAWN_CHARACTERS
			local stageId = if tpData and tpData.stageId then tpData.stageId else DEFAULT_STAGE_ID
			local worldId = if tpData and tpData.worldId then tpData.worldId else DEFAULT_WORLD_ID
			SpawnService.Spawn(player :: _TYPES.RobloxPlayerType, charsToSpawn, stageId, worldId)
		end)
	end)
end)

-- Listens to request to return to menu
Zap.RequestReturnToMenu.On(function(player)
	local code = TeleportService:ReserveServer(MENU_PLACE_ID)
	local tpOptions = Instance.new("TeleportOptions")
	tpOptions.ReservedServerAccessCode = code
	tpOptions:SetTeleportData({})

	TeleportService:TeleportAsync(MENU_PLACE_ID, { player }, tpOptions)
end)
