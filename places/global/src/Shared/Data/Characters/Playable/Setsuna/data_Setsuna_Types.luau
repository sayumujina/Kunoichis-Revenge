local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)

export type ServerCharData = _TYPES.CombatCharData<{
	selectedMove: string,
	queuedUltimateId: number?,
}>

return nil
