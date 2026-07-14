-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local SpawnService = require(Services.SpawnService)
--
local ServerScriptService = game:GetService("ServerScriptService")
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)

-- TO DO: REPLACE THIS NUMBER WITH A FILE THAT CONTAINS ENEMY INFO
local ENEMY_SPAWN_COUNT = 3
local ENEMY_SPAWN_DISTANCE_IN_BETWEEN = 10
local ENEMY_SPAWN_Z_OFFSET = 20

--- @class EnemyService
--- @server
--- @tag Service
local EnemyService = {}

--- Called when the service starts
function EnemyService.OnStart()
	-- TO DO: SETUP ENEMY SPAWNING LOGIC
	print("EnemyService started")
	EnemyService.SpawnAll()
end

-- Spawns all enemies into the game'
-- TO DO: RETRIEVE ENEMY DATA FROM A SPECIFIC FILE IN THE FUTURE
function EnemyService.SpawnAll()
	-- SpawnService.SpawnAllCharactersOfSide(false, ENEMY_SPAWN_COUNT, ENEMY_SPAWN_Z_OFFSET)
end
return EnemyService
