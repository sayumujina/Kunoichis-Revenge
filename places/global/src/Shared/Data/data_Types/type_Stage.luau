--- @within data_TYPES
--- @type ExtraObjective = { condition: string, value: string }
export type ExtraObjective = {
	objectiveId: string,
	conditionType: "DownedCharacters" | "UsedActionValue",
	description: string,
	value: string,
}

export type FirstClearReward = {
	{
		rewardName: string,
		rewardValue: string,
	}
}

return nil
