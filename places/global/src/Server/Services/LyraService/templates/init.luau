local _TYPES = require(game.ReplicatedStorage.Data.data_Types)
local GlobalControllers = game:GetService("StarterPlayer").StarterPlayerScripts.Client.GlobalControllers

local data: _TYPES.PlayerStoreData = {
	OwnedCharacters = { "Hayumi", "Setsuna" },
	--
	ClearedStages = {
		{
			worldId = "World1",
			stageId = "1-1",
			clearedExtraObjectives = {},
		},
	},
	UnlockedStages = {
		{
			worldId = "World1",
			stageId = "1-1",
		},
	},
	--
	Currencies = {
		Koban = 1000,
	},
}

return data
