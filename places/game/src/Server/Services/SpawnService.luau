-- Services
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)
local TurnService = require(Services.TurnService)
local CharService = require(Services.CharService)
local AnimationService = require(Services.AnimationService)
local StatusService = require(Services.StatusService)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
-- Packages
local Zap = require(Services.Parent.zap)

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
	-- Listens to spawn request from clients
	Zap.RequestSpawn.On(function(player)
		local playables = { "Tsuyoka", "Setsuna", "Hayumi" } -- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE
		local npcs = { "MockEnemy", "Red_MockEnemy", "MockEnemy" } -- TO DO: RETRIEVE THIS DATA FROM EACH STAGE IN THE FUTURE

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

return SpawnService
