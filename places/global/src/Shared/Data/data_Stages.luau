local rep = game.ReplicatedStorage
local _TYPES = require(rep.Data.data_Types)

local stages = {
	["1-1"] = {
		name = "1-1",
		description = "The first stage of the game.",
		enemies = { "MockEnemy", "MockEnemy" },
	},
	["1-2"] = {
		name = "1-2",
		description = "The second stage of the game.",
		enemies = { "MockEnemy", "MockEnemy", "MockEnemy" },
	},
	["1-3"] = {
		name = "1-3",
		description = "The third stage of the game.",
		enemies = { "Red_MockEnemy", "MockEnemy", "Red_MockEnemy", "MockEnemy" },
	},
} :: { [string]: _TYPES.Stage }

return stages
