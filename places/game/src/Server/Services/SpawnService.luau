-- Services
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local Server = game:GetService("ServerScriptService").Server
local Services = Server.Services
local EventService = require(Services.EventService)
local TurnService = require(Services.TurnService)
local CharService = require(Services.CharService)
local AnimationService = require(Services.AnimationService)
local LyraService = require(Server.GlobalServices.LyraService)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
-- Packages
local Zap = require(Services.Parent.zap)
-- Data
local StagesData = require(rep.Data.data_Stages)
-- Constants
local DEFAULT_SPAWN_CHARACTERS = { "Tsuyoka", "Hayumi", "Setsuna" }
local DEFAULT_STAGE_ID = "1-3"
local DEFAULT_WORLD_ID = "World1"

--- @class SpawnService
--- @server
--- @tag Service
local SpawnService = {}

-- Helper function to get a character's combat service module
local function getCharacterCombatService(char: _TYPES.Character): any
	local combatServiceModuleName = char.Name .. "_CombatService"
	local combatServiceModule =
		Services.Characters[char:GetAttribute("Side") :: _TYPES.Sides][char.Name]:FindFirstChild(
			combatServiceModuleName
		)
	if not combatServiceModule then
		warn("CombatService module", combatServiceModuleName, "not found for character", char.Name)
		return nil
	end

	return combatServiceModule
end

--- Called when the service starts
function SpawnService.OnStart()
	-- Listens to restart event to despawn all characters and reset the game state
	Zap.RestartRequested.On(function(player)
		SpawnService.Despawn(player :: _TYPES.RobloxPlayerType, true)
	end)
end

function SpawnService.Spawn(player: _TYPES.RobloxPlayerType, chars: { string }, stageId: string, worldId: string)
	local playables = chars :: { string }
	warn(StagesData[worldId].stages)
	local npcs = StagesData[worldId].stages[stageId].enemies :: { string }
	warn(table.concat(npcs, ","))

	-- Initialise the player entry in the turn system
	if not TurnService.GetPlayerTurnData(player :: _TYPES.RobloxPlayerType) then
		TurnService.InitialisePlayerEntry(player :: _TYPES.RobloxPlayerType)
	end

	-- Spawn characters for both sides, for now
	SpawnService.SpawnAllCharactersOfSide(player :: _TYPES.RobloxPlayerType, "Playable", playables)
	SpawnService.SpawnAllCharactersOfSide(player :: _TYPES.RobloxPlayerType, "NPC", npcs)

	-- Create an active character object value for the player
	local activeCharValue = Instance.new("ObjectValue")
	activeCharValue.Name = "ActiveCharacter"
	activeCharValue.Parent = player

	-- After spawning is done, send a signal back to the client
	EventService.Events.SpawnFinished:Fire({
		player = player :: _TYPES.RobloxPlayerType,
		data = {
			stageData = {
				worldId = worldId,
				stageId = stageId,
			},
		},
	})
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
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.new(0.984314, 1, 0)
	highlight.OutlineTransparency = 0
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

	-- Get the character's level from the player's data
	local playerData = LyraService.GetData(player :: _TYPES.RobloxPlayerType)
	local characterLevel = playerData.OwnedCharacters[char.Name] and playerData.OwnedCharacters[char.Name].Level or 20
	char:SetAttribute("Level", characterLevel)

	-- Create a index attribute to mark the character's index
	-- Used to determine the selected character/enemy index
	char:SetAttribute("Index", index)

	-- Create a side attribute and insert the character's side
	char:SetAttribute("Side", side)

	-- Create a "Downed" attribute to track if the character is downed or not
	char:SetAttribute("Downed", false)

	-- Spawn from above the baseplate
	char:PivotTo(cframe)

	-- Load the character's base stats into the CharService
	CharService.LoadCharacterStats(char, side)

	-- Send a signal that spawn is successful
	EventService.Events.SpawnSuccessfulForChar:Fire({
		player = player,
		data = {
			char = char,
			data = {
				side = side,
				realStats = CharService.GetCharacterCombatData(char).realStats :: { [string]: number },
				currentStats = CharService.GetCharacterCombatData(char).currentStats :: { [string]: number },
			},
		},
	})

	-- Add the character to the turn system
	TurnService.AddActiveCharacter(char, player)

	-- Initialize the character's combat service
	local combatService = getCharacterCombatService(char)
	if combatService then
		require(combatService).Init(char)
	end

	local defaultMove = Utility.GetCharacterDefaultMove(char :: _TYPES.Character)
	if not defaultMove then
		return
	end

	-- Play the idle animation of the default move
	AnimationService.Play(char :: _TYPES.Character, defaultMove .. "_Idle")
end

--- Spawn all characters of a side
--- @within SpawnService
--- @param player -- The player associated with the characters being spawned
--- @param side -- The side the characters belong to (Playable or NPC)
--- @param charactersToSpawn -- A list of character names to spawn
function SpawnService.SpawnAllCharactersOfSide(
	player: _TYPES.RobloxPlayerType,
	--
	side: _TYPES.Sides,
	charactersToSpawn: { string }
)
	local characterCount = #charactersToSpawn
	local charModelPath = rep.Shared.Assets.Models[side]

	for count, charName in pairs(charactersToSpawn) do
		local char = charModelPath:FindFirstChild(charName):Clone() :: _TYPES.Character

		-- Calculate spawn position using helper function
		local spawnPosition =
			Utility.CalculateCharacterSpawnPosition(side, characterCount, count, char:GetExtentsSize().Y)

		-- Determine index based on side
		local index
		if side == "Playable" then
			index = characterCount - count + 1
			char.Parent = workspace.Characters.Playable
		else
			index = count
			char.Parent = workspace.Characters.NPC
			if not char:GetAttribute("Index") then
				char:SetAttribute("Index", index)
			end
		end

		SpawnService.SpawnCharacter(player, side, char, spawnPosition, index)
	end
end

--- Despawns a player's characters and cleans up their data
--- @within SpawnService
--- @param player -- The player whose characters are to be despawned
--- @param isRestart -- Optional boolean indicating if this despawn is due to a restart
function SpawnService.Despawn(player: _TYPES.RobloxPlayerType, isRestart: boolean?)
	-- Destroy all players' characters in the workspace
	for _, char in pairs(workspace.Characters:GetDescendants()) do
		if char:IsA("Model") and char:FindFirstChild("Humanoid") then
			char:Destroy()
		end
	end

	-- Remove all players' attributes related to the game state
	player.ActiveCharacter:Destroy()

	-- Fire the Despawn event to notify that the player has despawned
	EventService.Events.DespawnSuccessful:Fire({
		player = player,
	})

	-- If this despawn is due to a restart, respawn the player after a short delay
	if isRestart then
		EventService.Events.RestartSuccessful:Fire({
			player = player,
		})

		local RESPAWN_DELAY = 3 -- seconds
		task.delay(RESPAWN_DELAY, function()
			local tpData = player:GetJoinData().TeleportData :: {
				chars: { string },
				stageId: string,
				worldId: string,
				previouslyCleared: boolean,
				previouslyClearedExtraObjectives: { string }?,
			}?

			local charsToSpawn = if tpData and tpData.chars then tpData.chars else DEFAULT_SPAWN_CHARACTERS
			local stageId = if tpData and tpData.stageId then tpData.stageId else DEFAULT_STAGE_ID
			local worldId = if tpData and tpData.worldId then tpData.worldId else DEFAULT_WORLD_ID
			SpawnService.Spawn(player :: _TYPES.RobloxPlayerType, charsToSpawn, stageId, worldId)
		end)
	end
end

return SpawnService
