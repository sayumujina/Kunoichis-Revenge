local rep = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local Zap = require(Services.Parent.zap)

local Chars = {} :: {}

local Handlers = {
    BasicAttack = require(script.Parent.Handlers.Setsuna_BasicAttack),
}

local Setsuna_CombatService = {}

function Setsuna_CombatService.OnStart()
    -- Listesn to input from clients
    Zap.InputSent.On(function(_, inputData)
        -- Check if the origin of the input is from Setsuna
        if inputData.origin.Name ~= "Setsuna" then
            warn("Input received for " .. inputData.origin.Name .. ", but Setsuna_CombatService only handles inputs for Setsuna.")
            return
        end

        -- Handle the input based on the action
        if inputData.action == "BasicAttack" then
            print("Setsuna performs a basic attack!")
            Handlers.BasicAttack(inputData.origin)
        end
    end)
end

return Setsuna_CombatService
