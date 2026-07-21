local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)

export type NPCServerCharData = _TYPES.NPCServerCharData<{
	selectedMove: string,
}>

return nil
