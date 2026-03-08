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

local PlayersData = {} :: { [_TYPES.RobloxPlayerType]: { Characters: { _TYPES.Character } } }

--- Called when the service starts
function PlayerService.OnStart()
	-- TO DO: IMPLEMENT PLAYER SPAWNING LOGIC
	-- Players.PlayerAdded:Connect(function(player: _TYPES.RobloxPlayerType)
	-- 	local char = player.Character or player.CharacterAdded:Wait() :: _TYPES.Character
	-- 	if not char then
	-- 		warn("Character not found for player: " .. player.Name)
	-- 		return
	-- 	end

	-- 	if not PlayersData[player] then
	-- 		PlayersData[player] = {
	-- 			Characters = {},
	-- 		}
	-- 	end

	-- 	-- Spawn player's characters
	-- 	SpawnService.SpawnCharacter(true, char, CFrame.new(0, 30, CHARACTER_SPAWN_OFFSET))
	-- 	table.insert(PlayersData[player].Characters, char)

	-- 	-- Set active character index
	-- 	if not player:GetAttribute("ActiveCharacter") then
	-- 		-- For now, use my own character
	-- 		player:SetAttribute("ActiveCharacter", 1)
	-- 	end

	-- 	-- Notify client that spawn was successful
	-- 	char.Humanoid.WalkSpeed = 0
	-- 	-- Zap.SpawnSuccessful.Fire(player, PlayersData[player].Characters)
	-- end)
end

function PlayerService.SpawnCharactersForPlayer(player: _TYPES.RobloxPlayerType)
	-- TO DO: IMPLEMENT PLAYER CHARACTERS SPAWNING LOGIC
	-- For now, just spawn the current player
end

function PlayerService.GetHumanoidDescription(player: _TYPES.RobloxPlayerType)
	-- Get player's humanoid description
	local humanoidDescription
	repeat
		humanoidDescription = Players:GetHumanoidDescriptionFromUserId(player.UserId)
		task.wait()
	until humanoidDescription
end

return PlayerService
