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
	LightningArrow = require(script.Parent.Handlers.Hayumi_LightningArrow),
	LightningRain = require(script.Parent.Handlers.Hayumi_LightningRain),
} :: { [string]: (_TYPES.Character, number) -> () }

local charName = "Hayumi"
local Chars = {} :: {}

local Hayumi_CombatService = {}

function Hayumi_CombatService.OnStart()
	-- Listesn to input from clients
	Zap.RequestAttack.On(function(_, inputData)
		local currentTurn = TurnService.GetCurrentTurn()
		-- Check if the origin of the input is the current character whose turn it is
		if not currentTurn or inputData.char ~= currentTurn.char :: any then
			return
		end
		warn(
			"Received attack request from client:",
			inputData,
			"Current turn:",
			currentTurn and currentTurn.char.Name or "None"
		)

		-- Handle the input based on the action
		if inputData.data.move == "LightningArrow" then
			print(charName .. " performs a basic attack!")
			Handlers.LightningArrow(inputData.char :: _TYPES.Character, inputData.data.primaryTargetIndex)
		elseif inputData.data.move == "LightningRain" then
			print(charName .. " uses their skill!")
			Handlers.LightningRain(inputData.char :: _TYPES.Character, inputData.data.primaryTargetIndex)
		end
	end)
end

return Hayumi_CombatService
