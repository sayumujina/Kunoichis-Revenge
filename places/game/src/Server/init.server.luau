local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Server = game:GetService("ServerScriptService").Server
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local SpawnService = require(Server.Services.SpawnService)
--
local Loader = require(rep.Modules.GlobalModules.Loader)

-- Disable character autoload
game.Players.CharacterAutoLoads = false

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
	-- Spawn the player
	local tpData = player:GetJoinData().TeleportData

	task.defer(function()
		-- SpawnService.Spawn(player :: _TYPES.RobloxPlayerType, tpData.chars, tpData.stageId, tpData.worldId)
		SpawnService.Spawn(player :: _TYPES.RobloxPlayerType, { "Hayumi", "Tsuyoka", "Setsuna" }, "1-3", "World1")
	end)
end)
