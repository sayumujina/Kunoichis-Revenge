local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

export type ServerCharData = _TYPES.CombatCharData<
	{
        selectedMove: string, 
		archerysVisionTarget: _TYPES.Character?, 
		archerysVisionUseCount: number 
    }
>

return nil
