local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

export type ServerCharData = _TYPES.CombatCharData<
	{
        selectedMove: string, 
    }
>

return nil
