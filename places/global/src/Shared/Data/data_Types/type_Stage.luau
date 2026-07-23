--- @within data_TYPES
--- @type ExtraObjective = { objectiveOrder: number, conditionType: "DownedCharacters" | "UsedActionValue", description: string, value: string }
export type ExtraObjective = {
	objectiveOrder: number,
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
