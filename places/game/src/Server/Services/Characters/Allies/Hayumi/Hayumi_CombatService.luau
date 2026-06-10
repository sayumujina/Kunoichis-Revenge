local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
-- Modules
local Zap = require(Services.Parent.zap)
-- Attack handlers
local Handlers = {
	BasicAttack = require(script.Parent.Handlers.Hayumi_BasicAttack),
	Skill = require(script.Parent.Handlers.Hayumi_Skill),
}

local charName = "Hayumi"
local Chars = {} :: {}

local Hayumi_CombatService = {}

function Hayumi_CombatService.OnStart()
	-- Listesn to input from clients
	Zap.InputSent.On(function(_, inputData)
		local currentTurn = TurnService.GetCurrentTurn()
		-- Check if the origin of the input is the current character whose turn it is
		if not currentTurn or inputData.origin ~= currentTurn.char :: any then
			return
		end

		-- Handle the input based on the action
		if inputData.action == "BasicAttack" then
			print(charName .. " performs a basic attack!")
			Handlers.BasicAttack(inputData.origin :: _TYPES.Character)
		elseif inputData.action == "Skill" then
			print(charName .. " uses their skill!")
			Handlers.Skill(inputData.origin :: _TYPES.Character)
		end
	end)
end

return Hayumi_CombatService
