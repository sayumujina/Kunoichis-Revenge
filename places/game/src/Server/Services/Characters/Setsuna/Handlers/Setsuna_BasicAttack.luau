local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
-- Modules
local ExecuteAttack = require(rep.Shared.Modules.Attack.ExecuteAttack)

return function(char: _TYPES.Character)
    local attackData = {
        origin = char,
        targets = {}, 
        data = {
            atk = 10, 
            energyGain = 5, 
            skillPointGain = 2, 
        },
        info = {
            name = "Basic Attack",
            description = "A simple attack that deals damage to a single target.",
        },
    } :: _TYPES.AttackData

    ExecuteAttack(attackData)

    -- Get the current energy of the character after the attack
    local currentEnergy = CharService.GetCharacterCombatData(char).realStats.currentEnergy
    warn(char.Name .. " now has " .. currentEnergy .. " energy after performing Basic Attack.")
end