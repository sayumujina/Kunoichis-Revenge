-- Services
local rep = game:GetService("ReplicatedStorage")
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)

-- Packages
local Zap = require(Services.Parent.zap)

local _TYPES = require(rep.Shared.data_Types)

--  Constants
local SPAWN_DISTANCE_BETWEEN_CHARACTERS = 10
local ENEMY_SPAWN_Z_OFFSET = 20
local ALLY_SPAWN_Z_OFFSET = 0

--- @class SpawnService
--- @server
--- @tag Service
local SpawnService = {}

--- Called when the service starts
function SpawnService.OnStart()
	print("SpawnService started")
	-- For now, automatically send a request to spawn after 5 secodns
	Zap.RequestSpawn.On(function()
		warn("Received spawn request from client, spawning characters...")
		SpawnService.SpawnAllCharactersOfSide("Ally", { "Setsuna" }, ALLY_SPAWN_Z_OFFSET)
		SpawnService.SpawnAllCharactersOfSide("Enemy", { "MockEnemy", "MockEnemy", "MockEnemy" }, ENEMY_SPAWN_Z_OFFSET)
	end)
end

--- Spawns a character into the game
function SpawnService.SpawnCharacter(side: _TYPES.Sides, char: _TYPES.Character, cframe: CFrame)
	-- Spawn from above the baseplate
	char:PivotTo(cframe)
	-- Send a signal that spawn is successful
	EventService.Events.SpawnSuccessful:Fire({
		origin = char,
		side = side,
	})
end

--- Spawn all characters of a side
function SpawnService.SpawnAllCharactersOfSide(
	side: _TYPES.Sides,
	charactersToSpawn: { string },
	startingZOffset: number
)
	-- Calculate starting X position based on number of characters
	local characterCount = #charactersToSpawn
	local startX = ((characterCount - 1) * SPAWN_DISTANCE_BETWEEN_CHARACTERS) / 2
	local charModelPath = rep.Shared.Assets.Models[if side == "Ally" then "Allies" else "Enemies"]

	for count, charName in charactersToSpawn do
		local char = charModelPath:FindFirstChild(charName):Clone() :: _TYPES.Character

		-- Calculate spawn position
		local spawnX = startX - (count * SPAWN_DISTANCE_BETWEEN_CHARACTERS)
		local spawnPosition = CFrame.new(spawnX, char.HumanoidRootPart.Size.Y, startingZOffset)

		-- Spawn the character
		if side == "Ally" then
			char.Parent = workspace.Characters.Allies
		else
			-- Clone the character model and set its name
			char.Parent = workspace.Characters.Enemies

			-- Set the index of the enemy
			-- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE
			if not char:GetAttribute("Index") then
				char:SetAttribute("Index", count + 1)
			end
		end

		SpawnService.SpawnCharacter(side, char, spawnPosition)
	end
end

return SpawnService
