local Services = game:GetService("ServerScriptService").Server.Services
local Players = game:GetService("Players")
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local EventService = require(Services.EventService)
-- Packages
local Zap = require(game.ServerScriptService.Server.zap)

-- Number of characters per player

--- @class PlayerService
local PlayerService = {}

local PlayersData = {} :: { [_TYPES.RobloxPlayerType]: { Characters: { _TYPES.Character } } }

--- Called when the service starts
function PlayerService.OnStart()
	-- TO DO: IMPLEMENT PLAYER SPAWNING LOGIC
	Players.PlayerAdded:Connect(function(player: _TYPES.RobloxPlayerType)
		if not PlayersData[player] then
			PlayersData[player] = {
				Characters = {},
			}
		end
	end)

	-- Listens to character spawning and adds them to the player's data
	EventService.Events.SpawnSuccessful:Connect(function(spawnSuccessfulEvent)
		local player = spawnSuccessfulEvent.player
		local char = spawnSuccessfulEvent.data.char
		--
		table.insert(PlayersData[player].Characters, char)
	end)
end

function PlayerService.SpawnCharactersForPlayer(player: _TYPES.RobloxPlayerType)
	-- Spawn player's characters
	-- SpawnService.SpawnAllCharactersOfSide("Allies", { "Setsuna", "Setsuna" }, CHARACTER_SPAWN_OFFSET)
end

function PlayerService.GetHumanoidDescription(player: _TYPES.RobloxPlayerType)
	-- Get player's humanoid description
	local humanoidDescription
	repeat
		humanoidDescription = Players:GetHumanoidDescriptionFromUserId(player.UserId)
		task.wait()
	until humanoidDescription
end

--- Get the associated player for a character
--- @within PlayerService
--- @param char -- The character to find the player for
--- @return The player associated with the character, or nil if not found
function PlayerService.GetPlayerFromCharacter(char: _TYPES.Character): _TYPES.RobloxPlayerType?
	warn(PlayersData)
	-- Loop through the players data to find the player associated with the character
	for player, data in pairs(PlayersData) do
		if table.find(data.Characters, char) then
			return player
		end
	end
	return nil
end

return PlayerService
