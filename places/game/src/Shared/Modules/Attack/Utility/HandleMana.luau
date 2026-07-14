local _TYPES = require(game.ReplicatedStorage.Data.data_Types)
local PlayerService = require(game.ServerScriptService.Server.Services.PlayerService)

-- Verify if the player has enough mana to perform a move
local function hasEnoughMana(player: _TYPES.RobloxPlayerType, manaChange: number): boolean
	local playerData = PlayerService.GetPlayerData(player)
	if not playerData then
		warn("Player data not found for the player.")
		return false
	end
	return playerData.data.currentStats.mana + manaChange >= 0
end

-- Update the player's mana after performing a move
local function updatePlayerMana(player: _TYPES.RobloxPlayerType, manaChange: number)
	local playerData = PlayerService.GetPlayerData(player)
	if playerData then
		local maxMana = playerData.data.baseStats.mana
		local oldMana = playerData.data.currentStats.mana
		local newMana = math.clamp(oldMana + manaChange, 0, maxMana) -- manaChange can be negative for mana restoration
		PlayerService.UpdatePlayerCurrentStats(player, "mana", newMana)
	end
end

return {
	HasEnoughMana = hasEnoughMana,
	UpdatePlayerMana = updatePlayerMana,
}
