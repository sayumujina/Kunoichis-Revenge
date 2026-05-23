-- Services
local rep = game:GetService("ReplicatedStorage")
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)
local TurnService = require(Services.TurnService)
local CharService = require(Services.CharService)

-- Packages
local Zap = require(Services.Parent.zap)

local _TYPES = require(rep.Shared.data_Types)

-- Constants
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
	-- Listens to spawn request from clients
	Zap.RequestSpawn.On(function(player)
		-- Spawn charactersfor both sides, for now
		warn("Received spawn request from client, spawning characters...")
		SpawnService.SpawnAllCharactersOfSide(
			player :: _TYPES.RobloxPlayerType,
			"Allies",
			{ "Setsuna", "Setsuna" },
			ALLY_SPAWN_Z_OFFSET
		)
		SpawnService.SpawnAllCharactersOfSide(
			player :: _TYPES.RobloxPlayerType,
			"Enemies",
			{ "MockEnemy", "MockEnemy", "MockEnemy" },
			ENEMY_SPAWN_Z_OFFSET
		)
		-- After spawning is done, send a signal back to the client
		EventService.Events.SpawnFinished:Fire({
			player = player :: _TYPES.RobloxPlayerType,
		})
	end)
end

--- Spawns a character into the game
--- @within SpawnService
--- @param player -- The player associated with the character being spawned
--- @param side -- The side the character belongs to (Allies or Enemies)
--- @param char -- The character model to spawn
--- @param cframe -- The CFrame position to spawn the character at
function SpawnService.SpawnCharacter(
	player: _TYPES.RobloxPlayerType,
	--
	side: _TYPES.Sides,
	char: _TYPES.Character,
	cframe: CFrame
)
	-- Spawn from above the baseplate
	char:PivotTo(cframe)

	-- Load the character's base stats into the CharService
	CharService.LoadCharacterBaseStats(char, side)

	-- Add the character to the turn system
	TurnService.AddActiveCharacter(char)

	-- Send a signal that spawn is successful
	EventService.Events.SpawnSuccessful:Fire({
		player = player,
		data = {
			char = char,
			side = side,
		},
	})
end

--- Spawn all characters of a side
--- @within SpawnService
--- @param player -- The player associated with the characters being spawned
--- @param side -- The side the characters belong to (Allies or Enemies)
--- @param charactersToSpawn -- A list of character names to spawn
--- @param startingZOffset -- The starting Z offset to spawn the characters at
function SpawnService.SpawnAllCharactersOfSide(
	player: _TYPES.RobloxPlayerType,
	--
	side: _TYPES.Sides,
	charactersToSpawn: { string },
	startingZOffset: number
)
	-- Calculate starting X position based on number of characters
	local characterCount = #charactersToSpawn
	local startX = ((characterCount - 1) * SPAWN_DISTANCE_BETWEEN_CHARACTERS) / 2
	local charModelPath = rep.Shared.Assets.Models[side]

	for count, charName in charactersToSpawn do
		local char = charModelPath:FindFirstChild(charName):Clone() :: _TYPES.Character

		-- Calculate spawn position
		local spawnX = startX - (count * SPAWN_DISTANCE_BETWEEN_CHARACTERS)
		local spawnPosition = CFrame.new(spawnX, char.HumanoidRootPart.Size.Y, startingZOffset)

		-- Spawn the character
		if side == "Allies" then
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

		SpawnService.SpawnCharacter(player, side, char, spawnPosition)
	end
end

return SpawnService
