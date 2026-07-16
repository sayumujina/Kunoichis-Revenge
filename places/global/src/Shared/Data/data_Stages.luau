local rep = game.ReplicatedStorage
local _TYPES = require(rep.Data.data_Types)

local stages =
	{
		["World1"] = {
			worldOrder = 1,
			name = "World 1",
			description = "Seekful Revenge",
			stages = {
				["1-1"] = {
					stageOrder = 1,
					name = "1-1",
					description = "Missing Scent",
					enemies = { "MockEnemy", "MockEnemy" },
				},
				["1-2"] = {
					stageOrder = 2,
					name = "1-2",
					description = "Decadeful Reunion",
					enemies = { "MockEnemy", "MockEnemy", "MockEnemy" },
				},
				["1-3"] = {
					stageOrder = 3,
					name = "1-3",
					description = "Vengeance is Mine",
					enemies = { "Red_MockEnemy", "MockEnemy", "Red_MockEnemy", "MockEnemy" },
				},
			},
		},
		["World2"] = {
			worldOrder = 2,
			name = "World 2",
			description = "The Forgotten Dojo",
			stages = {
				["2-1"] = {
					stageOrder = 1,
					name = "2-1",
					description = "Unfamiliar Emptiness",
					enemies = { "MockEnemy", "MockEnemy" },
				},
				["2-2"] = {
					stageOrder = 2,
					name = "2-2",
					description = "Familiar Appearance",
					enemies = { "MockEnemy", "MockEnemy", "MockEnemy" },
				},
				["2-3"] = {
					stageOrder = 3,
					name = "2-3",
					description = "Unveil The Truth",
					enemies = { "Red_MockEnemy", "MockEnemy", "Red_MockEnemy", "MockEnemy" },
				},
			},
		},
	} :: { [string]: { worldOrder: number, name: string, description: string, stages: { [string]: _TYPES.Stage } } }

return stages
