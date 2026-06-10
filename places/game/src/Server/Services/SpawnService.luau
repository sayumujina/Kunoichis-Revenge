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
local BASE_ENEMY_SPAWN_POSITION = Vector3.new(0, 0, 40)
local ALLY_SPAWN_Z_OFFSET = 0
local BASE_ALLY_SPAWN_POSITION = Vector3.new(0, 0, 0)

--- @class SpawnService
--- @server
--- @tag Service
local SpawnService = {}

--- Called when the service starts
function SpawnService.OnStart()
	-- Listens to spawn request from clients
	Zap.RequestSpawn.On(function(player)
		local allies = { "Setsuna", "Hayumi" } -- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE
		local enemies = { "MockEnemy", "MockEnemy", "MockEnemy" } -- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE

		-- Spawn charactersfor both sides, for now
		SpawnService.SpawnAllCharactersOfSide(player :: _TYPES.RobloxPlayerType, "Allies", allies, ALLY_SPAWN_Z_OFFSET)
		SpawnService.SpawnAllCharactersOfSide(
			player :: _TYPES.RobloxPlayerType,
			"Enemies",
			enemies,
			ENEMY_SPAWN_Z_OFFSET
		)

		-- Create an active character object value for the player
		local activeCharValue = Instance.new("ObjectValue")
		activeCharValue.Name = "ActiveCharacter"
		activeCharValue.Parent = player

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
	-- Set the hrp as the primary part
	char.PrimaryPart = char.HumanoidRootPart

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
			data = CharService.GetCharacterCombatData(char),
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
	local startX
	if side == "Allies" then
		startX = BASE_ALLY_SPAWN_POSITION.X + ((characterCount - 1) * SPAWN_DISTANCE_BETWEEN_CHARACTERS) / 2
	else
		startX = BASE_ENEMY_SPAWN_POSITION.X + ((characterCount - 1) * SPAWN_DISTANCE_BETWEEN_CHARACTERS) / 2
	end

	local charModelPath = rep.Shared.Assets.Models[side]

	for count, charName in charactersToSpawn do
		local char = charModelPath:FindFirstChild(charName):Clone() :: _TYPES.Character

		-- Calculate spawn position
		local spawnX = startX - (count * SPAWN_DISTANCE_BETWEEN_CHARACTERS)
		local spawnPosition

		-- Spawn the character
		if side == "Allies" then
			spawnPosition = CFrame.new(spawnX, char.HumanoidRootPart.Size.Y, startingZOffset)
				* CFrame.Angles(0, math.rad(180), 0) -- Rotate allies to face enemies
			char.Parent = workspace.Characters.Allies
		else
			spawnPosition = CFrame.new(spawnX, char.HumanoidRootPart.Size.Y, startingZOffset)
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
