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
local SPAWN_X_OFFSET_BETWEEN_CHARACTERS = 8
local SPAWN_Z_ALTERNATE_OFFSET = 1
local ENEMY_SPAWN_Z_OFFSET = 50
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
		local playables = { "Setsuna", "Hayumi", "Rin" } -- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE
		local npcs = { "MockEnemy", "MockEnemy", "MockEnemy" } -- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE

		-- Spawn charactersfor both sides, for now
		SpawnService.SpawnAllCharactersOfSide(
			player :: _TYPES.RobloxPlayerType,
			"Playable",
			playables,
			ALLY_SPAWN_Z_OFFSET
		)
		SpawnService.SpawnAllCharactersOfSide(player :: _TYPES.RobloxPlayerType, "NPC", npcs, ENEMY_SPAWN_Z_OFFSET)

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
--- @param side -- The side the character belongs to (Playable or NPC)
--- @param char -- The character model to spawn
--- @param cframe -- The CFrame position to spawn the character at
--- @param index -- The index of the character in the side's lineup
function SpawnService.SpawnCharacter(
	player: _TYPES.RobloxPlayerType,
	--
	side: _TYPES.Sides,
	char: _TYPES.Character,
	cframe: CFrame,
	index: number
)
	-- Set the hrp as the primary part
	char.PrimaryPart = char.HumanoidRootPart

	-- Create a highlight instance for the character
	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.FillColor = Color3.new(0.984314, 1, 0)
	highlight.Parent = char
	highlight.Enabled = false

	-- Create an animator object
	if not char.Humanoid:FindFirstChild("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = char.Humanoid
	end

	-- Set an "originallyTransparent" attribute for parts that are transparent
	for _, part in pairs(char:GetDescendants()) do
		if (part:IsA("BasePart") or part:IsA("Decal")) and part.Transparency == 1 then
			part:SetAttribute("originallyTransparent", true)
		end
	end

	-- Create a index attribute to mark the character's index
	-- Used to determine the selected character/enemy index
	char:SetAttribute("Index", index)

	-- Create a side attribute and insert the character's side
	char:SetAttribute("Side", side)

	-- Spawn from above the baseplate
	char:PivotTo(cframe)

	-- Send a signal that spawn is successful
	EventService.Events.SpawnSuccessfulForChar:Fire({
		player = player,
		data = {
			char = char,
			data = {
				side = side,
			},
		},
	})

	-- Load the character's base stats into the CharService
	CharService.LoadCharacterStats(char, side)

	-- Add the character to the turn system
	TurnService.AddActiveCharacter(char)
end

--- Spawn all characters of a side
--- @within SpawnService
--- @param player -- The player associated with the characters being spawned
--- @param side -- The side the characters belong to (Playable or NPC)
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
	if side == "Playable" then
		startX = BASE_ALLY_SPAWN_POSITION.X + ((characterCount - 1) * SPAWN_X_OFFSET_BETWEEN_CHARACTERS) / 2
	else
		startX = BASE_ENEMY_SPAWN_POSITION.X + ((characterCount - 1) * SPAWN_X_OFFSET_BETWEEN_CHARACTERS) / 2
	end

	local charModelPath = rep.Shared.Assets.Models[side]

	for count, charName in charactersToSpawn do
		local index
		local char = charModelPath:FindFirstChild(charName):Clone() :: _TYPES.Character

		-- Calculate spawn position
		local spawnX = startX - (count * SPAWN_X_OFFSET_BETWEEN_CHARACTERS)

		-- Alternate the Z offset for each character to avoid overlap
		-- If allies, reverse the Z offset
		local spawnZ
		if side == "Playable" then
			spawnZ = startingZOffset - ((count % 2 == 0) and SPAWN_Z_ALTERNATE_OFFSET or -SPAWN_Z_ALTERNATE_OFFSET)
		else
			spawnZ = startingZOffset + ((count % 2 == 0) and SPAWN_Z_ALTERNATE_OFFSET or -SPAWN_Z_ALTERNATE_OFFSET)
		end

		local spawnPosition

		-- Spawn the character
		if side == "Playable" then
			-- If allies, the index will be ordered inversely
			-- This is done so that selecting previous/ next ally will be more intuitive when the camera faces the alies
			index = characterCount - count + 1

			-- Determine the spawn position
			spawnPosition = CFrame.new(spawnX, char:GetExtentsSize().Y / 2, spawnZ) * CFrame.Angles(0, math.rad(180), 0) -- Rotate allies to face enemies

			-- Parent the character to the Playable folder
			char.Parent = workspace.Characters.Playable
		else
			-- If enemies, the index will be ordered normally
			index = count

			-- Determine the spawn position
			spawnPosition = CFrame.new(spawnX, char:GetExtentsSize().Y / 2, spawnZ)

			-- Parent the character to the NPC folder
			char.Parent = workspace.Characters.NPC

			-- Set the index of the enemy
			-- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE
			if not char:GetAttribute("Index") then
				char:SetAttribute("Index", index)
			end
		end

		SpawnService.SpawnCharacter(player, side, char, spawnPosition, index)
	end
end

return SpawnService
