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
	WeavingBlade = require(script.Parent.Handlers.Setsuna_WeavingBlade),
	TwinBlades = require(script.Parent.Handlers.Setsuna_TwinBlades),
} :: { [string]: (_TYPES.Character, number) -> () }

local charName = "Setsuna"
local Chars = {} :: {}

local Setsuna_CombatService = {}

function Setsuna_CombatService.OnStart()
	-- Listens to input from clients
	Zap.RequestAttack.On(function(_, inputData)
		local currentTurn = TurnService.GetCurrentTurn()
		-- Check if the origin of the input is the current character whose turn it is
		if not currentTurn or inputData.char ~= currentTurn.char :: any then
			return
		end

		-- Handle the input based on the action
		if inputData.data.move == "WeavingBlade" then
			print(charName .. " performs a basic attack!")
			Handlers.WeavingBlade(inputData.char :: _TYPES.Character, inputData.data.primaryTargetIndex)
		elseif inputData.data.move == "TwinBlades" then
			print(charName .. " uses their skill!")
			Handlers.TwinBlades(inputData.char :: _TYPES.Character, inputData.data.primaryTargetIndex)
		end
	end)
end

return Setsuna_CombatService
