local rep = game:GetService("ReplicatedStorage")
--
local Server = game:GetService("ServerScriptService").Server
-- Services
local Loader = require(rep.Shared.Modules.Loader)

-- Disable character autoload
game.Players.CharacterAutoLoads = false

-- Load all services
Loader.SpawnAll(
	Loader.LoadDescendants(Server, function(module)
		-- return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
		return (module.Name:match("Service$") ~= nil)
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
