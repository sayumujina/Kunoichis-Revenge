-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local SpawnService = require(Services.SpawnService)
--
local ServerScriptService = game:GetService("ServerScriptService")
local rep = game:GetService("ReplicatedStorage")
local Utility = require(ServerScriptService.Server.Helpers.Utility)
local _TYPES = require(rep.Shared.data_Types)

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
	local startX = ((ENEMY_SPAWN_COUNT - 1) * ENEMY_SPAWN_DISTANCE_IN_BETWEEN) / 2

	for count = 0, (ENEMY_SPAWN_COUNT - 1) do
		warn("Spawning enemy")
		local enemy = rep.Shared.Assets.Models.MockEnemy:Clone() :: _TYPES.Character
		enemy.Parent = workspace.Characters.Enemies
		enemy.Name = "MockEnemy" .. (count + 1)

		-- Set the index of the enemy
		-- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE
		if not enemy:GetAttribute("Index") then
			enemy:SetAttribute("Index", count + 1)
		end

		-- Calculate spawn position
		local spawnX = startX - (count * ENEMY_SPAWN_DISTANCE_IN_BETWEEN)
		local spawnPosition = CFrame.new(spawnX, 30, ENEMY_SPAWN_Z_OFFSET)
		SpawnService.SpawnCharacter(enemy, spawnPosition)
	end
end
return EnemyService
