-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local rep = game:GetService("ReplicatedStorage")
local Utility = require(ServerScriptService.Server.Helpers.Utility)
-- Packages
local Zap = require(game.ServerScriptService.Server.zap)

local _TYPES = require(rep.Shared.data_Types)

--  Constants
local SPAWN_DISTANCE_BETWEEN_CHARACTERS = 10

--- @class SpawnService
--- @server
--- @tag Service
local SpawnService = {}

--- Called when the service starts
function SpawnService.OnStart()
	print("SpawnService started")
end

--- Spawns a player into the game=
function SpawnService.SpawnCharacter(char: _TYPES.Character, cframe: CFrame, ally: boolean?)
	-- Spawn from above the baseplate
	char:PivotTo(cframe)
end

--- Spawn all characters of a side
function SpawnService.SpawnAllCharactersOfSide(characterCount: number, startingZOffset: number)
	-- Calculate starting X position based on number of characters
	local startX = ((characterCount - 1) * SPAWN_DISTANCE_BETWEEN_CHARACTERS) / 2

	for count = 0, (characterCount - 1) do
		warn("Spawning enemy")
		local char = rep.Shared.Assets.Models.MockEnemy:Clone() :: _TYPES.Character
		char.Parent = workspace.Characters.Enemies
		char.Name = "MockEnemy" .. (count + 1)

		-- Set the index of the enemy
		-- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE
		if not char:GetAttribute("Index") then
			char:SetAttribute("Index", count + 1)
		end

		-- Calculate spawn position
		local spawnX = startX - (count * SPAWN_DISTANCE_BETWEEN_CHARACTERS)
		local spawnPosition = CFrame.new(spawnX, 30, startingZOffset)
		SpawnService.SpawnCharacter(char, spawnPosition)
	end
end

return SpawnService
