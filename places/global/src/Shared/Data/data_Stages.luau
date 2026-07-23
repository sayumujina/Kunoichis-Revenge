local rep = game.ReplicatedStorage
local _TYPES = require(rep.Data.data_Types)

local stages = {
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
				--
				extraObjectives = {
					["Objective1"] = {
						objectiveOrder = 1,
						conditionType = "UsedActionValue",
						description = "Consume less than 900 action value",
						value = 900,
					},
					["Objective2"] = {
						objectiveOrder = 2,
						conditionType = "UsedActionValue",
						description = "Consume less than 1500 action value",
						value = 1500,
					},
					["Objective3"] = {
						objectiveOrder = 3,
						conditionType = "DownedCharacters",
						description = "Have less than 1 character(s) downed",
						value = 1,
					},
				},
				--
				firstClearReward = {
					clear = {
						rewardName = "Koban",
						rewardValue = "100",
					},
					extraObjectives = {
						["Objective1"] = {
							rewardName = "Koban",
							rewardValue = "100",
						},
						["Objective2"] = {
							rewardName = "Koban",
							rewardValue = "50",
						},
						["Objective3"] = {
							rewardName = "Koban",
							rewardValue = "20",
						},
					},
				},
			},
			["1-2"] = {
				stageOrder = 2,
				name = "1-2",
				description = "Decadeful Reunion",
				enemies = { "MockEnemy", "MockEnemy", "MockEnemy" },
				--
				extraObjectives = {
					["Objective1"] = {
						objectiveOrder = 1,
						conditionType = "UsedActionValue",
						description = "Consume less than 900 action value",
						value = 900,
					},
					["Objective2"] = {
						objectiveOrder = 2,
						conditionType = "UsedActionValue",
						description = "Consume less than 1500 action value",
						value = 1500,
					},
					["Objective3"] = {
						objectiveOrder = 3,
						conditionType = "DownedCharacters",
						description = "Have less than 1 character(s) downed",
						value = 1,
					},
				},
				--
				firstClearReward = {
					clear = {
						rewardName = "Koban",
						rewardValue = "100",
					},
					extraObjectives = {
						["Objective1"] = {
							rewardName = "Koban",
							rewardValue = "100",
						},
						["Objective2"] = {
							rewardName = "Koban",
							rewardValue = "50",
						},
						["Objective3"] = {
							rewardName = "Koban",
							rewardValue = "20",
						},
					},
				},
			},
			["1-3"] = {
				stageOrder = 3,
				name = "1-3",
				description = "Vengeance is Mine",
				enemies = { "Red_MockEnemy", "MockEnemy", "Red_MockEnemy", "MockEnemy" },
				--
				extraObjectives = {
					["Objective1"] = {
						objectiveOrder = 1,
						conditionType = "UsedActionValue",
						description = "Consume less than 750 action value",
						value = 750,
					},
					["Objective2"] = {
						objectiveOrder = 2,
						conditionType = "UsedActionValue",
						description = "Consume less than 1200 action value",
						value = 1200,
					},
					["Objective3"] = {
						objectiveOrder = 3,
						conditionType = "DownedCharacters",
						description = "Have no characters downed",
						value = 0,
					},
				},
				--
				firstClearReward = {
					clear = {
						rewardName = "Koban",
						rewardValue = "200",
					},
					extraObjectives = {
						["Objective1"] = {
							rewardName = "Koban",
							rewardValue = "160",
						},
						["Objective2"] = {
							rewardName = "Koban",
							rewardValue = "80",
						},
						["Objective3"] = {
							rewardName = "Koban",
							rewardValue = "60",
						},
					},
				},
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
				--
				extraObjectives = {
					["Objective1"] = {
						objectiveOrder = 1,
						conditionType = "UsedActionValue",
						description = "Consume less than 900 action value",
						value = 900,
					},
					["Objective2"] = {
						objectiveOrder = 2,
						conditionType = "UsedActionValue",
						description = "Consume less than 1500 action value",
						value = 1500,
					},
					["Objective3"] = {
						objectiveOrder = 3,
						conditionType = "DownedCharacters",
						description = "Have less than 1 character(s) downed",
						value = 1,
					},
				},
				--
				firstClearReward = {
					clear = {
						rewardName = "Koban",
						rewardValue = "100",
					},
					extraObjectives = {
						["Objective1"] = {
							rewardName = "Koban",
							rewardValue = "100",
						},
						["Objective2"] = {
							rewardName = "Koban",
							rewardValue = "50",
						},
						["Objective3"] = {
							rewardName = "Koban",
							rewardValue = "20",
						},
					},
				},
			},
			["2-2"] = {
				stageOrder = 2,
				name = "2-2",
				description = "Familiar Appearance",
				enemies = { "MockEnemy", "MockEnemy", "MockEnemy" },
				--
				extraObjectives = {
					["Objective1"] = {
						objectiveOrder = 1,
						conditionType = "UsedActionValue",
						description = "Consume less than 900 action value",
						value = 900,
					},
					["Objective2"] = {
						objectiveOrder = 2,
						conditionType = "UsedActionValue",
						description = "Consume less than 1500 action value",
						value = 1500,
					},
					["Objective3"] = {
						objectiveOrder = 3,
						conditionType = "DownedCharacters",
						description = "Have less than 1 character(s) downed",
						value = 1,
					},
				},
				--
				firstClearReward = {
					clear = {
						rewardName = "Koban",
						rewardValue = "100",
					},
					extraObjectives = {
						["Objective1"] = {
							rewardName = "Koban",
							rewardValue = "100",
						},
						["Objective2"] = {
							rewardName = "Koban",
							rewardValue = "50",
						},
						["Objective3"] = {
							rewardName = "Koban",
							rewardValue = "20",
						},
					},
				},
			},
			["2-3"] = {
				stageOrder = 3,
				name = "2-3",
				description = "Unveil The Truth",
				enemies = { "Red_MockEnemy", "MockEnemy", "Red_MockEnemy", "MockEnemy" },
				--
				extraObjectives = {
					["Objective1"] = {
						objectiveOrder = 1,
						conditionType = "UsedActionValue",
						description = "Consume less than 750 action value",
						value = 750,
					},
					["Objective2"] = {
						objectiveOrder = 2,
						conditionType = "UsedActionValue",
						description = "Consume less than 1200 action value",
						value = 1200,
					},
					["Objective3"] = {
						objectiveOrder = 3,
						conditionType = "DownedCharacters",
						description = "Have no characters downed",
						value = 0,
					},
				},
				--
				firstClearReward = {
					clear = {
						rewardName = "Koban",
						rewardValue = "200",
					},
					extraObjectives = {
						["Objective1"] = {
							rewardName = "Koban",
							rewardValue = "160",
						},
						["Objective2"] = {
							rewardName = "Koban",
							rewardValue = "80",
						},
						["Objective3"] = {
							rewardName = "Koban",
							rewardValue = "60",
						},
					},
				},
			},
		},
	},
}

return stages
