local Players = game:GetService("Players")
local SpawnService = require(script.Parent.SpawnService)
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Packages
local Zap = require(game.ServerScriptService.Server.zap)

-- Number of characters per player
local CHARACTERS_PER_PLAYER = 3
local CHARACTER_SPAWN_OFFSET = -20

--- @class PlayerService
local PlayerService = {}

--- Called when the service starts
function PlayerService.OnStart()
	-- TO DO: IMPLEMENT PLAYER SPAWNING LOGIC
	Players.PlayerAdded:Connect(function(player)
		local char = player.Character or player.CharacterAdded:Wait() :: _TYPES.Character
		if not char then
			warn("Character not found for player: " .. player.Name)
			return
		end
		SpawnService.SpawnCharacter(char, CFrame.new(0, 30, CHARACTER_SPAWN_OFFSET), true)

		-- Notify client that spawn was successful
		Zap.SpawnSuccessful.Fire(player)
		char.Humanoid.WalkSpeed = 0
	end)
end

function PlayerService.SpawnCharactersForPlayer(player)
	-- TO DO: IMPLEMENT PLAYER CHARACTERS SPAWNING LOGIC
	-- For now, just spawn the current player
end

return PlayerService
