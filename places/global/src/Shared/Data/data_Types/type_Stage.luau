--- @within data_TYPES
--- @type ExtraObjective = { condition: string, value: string }
export type ExtraObjective = {
	objectiveId: string,
	conditionType: "DownedCharacters" | "UsedActionValue",
	value: string,
}

export type FirstClearReward = {
	{
		rewardName: string,
		rewardValue: string,
	}
}

--- @within data_TYPES
--- @type Stage = { name: string, description: string, enemies: { string } }
export type Stage = {
	stageOrder: number,
	name: string,
	description: string,
	enemies: { string },
	-- Objectives to gain stars, outside of the main condition: clearing the stage with sursivors
	extraObjectives: { ExtraObjective },
	--
	firstClearReward: FirstClearReward?,
}

--- @within data_TYPES
--- @type World = { name: string, description: string, stages: { [string]: Stage } }
export type World = {
	worldOrder: number,
	name: string,
	description: string,
	stages: { [string]: Stage },
}

return nil
