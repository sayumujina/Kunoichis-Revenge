local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local PlayerService = require(Services.PlayerService)
--

local ConsumablesService = {}

--- Called when the server starts
function ConsumablesService.OnStart() end

--- Consumes a consumable for a player and applies its' effects to the target character
--- @within ConsumablesService
--- @param player -- The player consuming the consumable
--- @param targetChar -- The character the consumable is being used on
--- @param consumableId -- The ID of the consumable being used
--- @param amount -- The amount of the consumable being used
function ConsumablesService.Consume(
	player: _TYPES.RobloxPlayerType,
	targetChar: _TYPES.Character?,
	consumableId: string,
	amount: number
)
	-- Get the player's data
	local playerData = PlayerService.GetPlayerData(player)
	if not playerData then
		return
	end

	-- Check if the player has enough of the consumable
	local currentAmount = playerData.consumablesCount[consumableId] or 0
	if currentAmount < amount then
		return
	end

	-- Subtract the used amount from the player's data
	playerData.consumablesCount[consumableId] = currentAmount - amount
end

return ConsumablesService
