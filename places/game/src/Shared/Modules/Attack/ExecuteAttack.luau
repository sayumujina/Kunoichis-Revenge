local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local CombatUtility = game.ReplicatedStorage.Shared.Modules.Attack.Utility
local ProvideEnergy = require(CombatUtility.ProvideEnergy)

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param attackData -- The data for the attack to create

local function ExecuteAttack(attackData: _TYPES.AttackData) 
    -- Provide energy gain
    ProvideEnergy(attackData.origin, attackData.data.energyGain, false)
end

return ExecuteAttack
