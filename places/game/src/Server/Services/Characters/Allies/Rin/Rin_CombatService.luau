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
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura),
} :: { [string]: (_TYPES.Character, number) -> () }

local charName = "Rin"
local Chars = {} :: {}

local Rin_CombatService = {}

function Rin_CombatService.OnStart()
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
		if inputData.data.move == "HiddenAssistance" then
			print(charName .. " performs a basic attack!")
			Handlers.HiddenAssistance(inputData.char :: _TYPES.Character, inputData.data.primaryTargetIndex)
		elseif inputData.data.move == "CleansingAura" then
			print(charName .. " uses their skill!")
			Handlers.CleansingAura(inputData.char :: _TYPES.Character, inputData.data.primaryTargetIndex)
		end
	end)
end

return Rin_CombatService
