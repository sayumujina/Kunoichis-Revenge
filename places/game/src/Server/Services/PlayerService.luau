local Services = game:GetService("ServerScriptService").Server.Services
local Players = game:GetService("Players")
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local EventService = require(Services.EventService)
-- Packages
local Zap = require(game.ServerScriptService.Server.zap)

--- @class PlayerService
local PlayerService = {}

local PlayersData = {} :: {
	[_TYPES.RobloxPlayerType]: _TYPES.PlayerCombatData,
}

--- Called when the service starts
function PlayerService.OnStart()
	-- Listens to players joining the game and adds them to the PlayersData table
	Players.PlayerAdded:Connect(function(player: _TYPES.RobloxPlayerType)
		if PlayersData[player] then
			return
		end

		-- Initialize the player's data
		PlayersData[player] = {
			characters = {},
			data = {
				baseStats = {
					mana = 100,
				},
				currentStats = {
					mana = 60,
				},
				consumablesCount = { ["HealingOnigiri"] = 2 },
			},
		}

		-- Fire the event to notify stats changes for the player
		EventService.Events.PlayerCurrentStatsChanged:Fire({
			player = player,
			data = {
				char = player.Character :: _TYPES.Character,
				data = PlayersData[player].data.currentStats,
			},
		})
	end)

	-- Listens to character spawning and adds them to the player's data
	EventService.Events.SpawnSuccessfulForChar:Connect(function(spawnSuccessfulForCharEvent)
		local player = spawnSuccessfulForCharEvent.player
		local char = spawnSuccessfulForCharEvent.data.char
		--
		table.insert(PlayersData[player].characters, char)

		-- Fire the event to notify stats changes for the player
		EventService.Events.PlayerCurrentStatsChanged:Fire({
			player = player,
			data = {
				char = player.Character :: _TYPES.Character,
				data = PlayersData[player].data.currentStats,
			},
		})
	end)
end

function PlayerService.SpawnCharactersForPlayer(player: _TYPES.RobloxPlayerType)
	-- Spawn player's characters
	-- SpawnService.SpawnAllCharactersOfSide("Playable", { "Setsuna", "Setsuna" }, CHARACTER_SPAWN_OFFSET)
end

--- Get the associated player for a character
--- @within PlayerService
--- @param char -- The character to find the player for
--- @return The player associated with the character, or nil if not found
function PlayerService.GetPlayerFromCharacter(char: _TYPES.Character): _TYPES.RobloxPlayerType?
	-- Loop through the players data to find the player associated with the character
	for player, data in pairs(PlayersData) do
		if table.find(data.characters, char) then
			return player
		end
	end
	return nil
end

--- Get the player's combat data
--- @within PlayerService
--- @param player -- The player to get the data for
function PlayerService.GetPlayerData(player: _TYPES.RobloxPlayerType): _TYPES.PlayerCombatData?
	return PlayersData[player] or nil
end

--- Get the player's combat data from a character
--- @within PlayerService
--- @param char -- The character to get the data for
function PlayerService.GetPlayerDataFromChar(char: _TYPES.Character): _TYPES.PlayerCombatData?
	local player = PlayerService.GetPlayerFromCharacter(char)
	if not player then
		return nil
	end
	return PlayersData[player] or nil
end

--- Update the player's combat data
--- @within PlayerService
--- @param player -- The player to update the data for
--- @param statName -- The name of the stat to update
--- @param newValue -- The new value of the stat
function PlayerService.UpdatePlayerCurrentStats(player: _TYPES.RobloxPlayerType, statName: string, newValue: number)
	if not PlayersData[player] then
		return
	end

	PlayersData[player].data.currentStats[statName] = newValue

	-- Fire the event to notify that the player's current stats have changed
	EventService.Events.PlayerCurrentStatsChanged:Fire({
		player = player,
		data = {
			char = player.Character :: _TYPES.Character,
			data = PlayersData[player].data.currentStats,
		},
	})
end

return PlayerService
