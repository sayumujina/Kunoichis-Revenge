local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local TurnService = require(Services.TurnService)
local EventService = require(Services.EventService)
local AnimationService = require(Services.AnimationService)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

local CombatService = {}

--- Called when the service starts
function CombatService.OnStart()
	-- Listens to turn started event
	EventService.Events.TurnStarted:Connect(function(turnData)
		local char = turnData.data.char
		local currentTurn = TurnService.GetCurrentTurn()
		if not currentTurn or char :: any ~= currentTurn.char then
			return
		end

		-- Play the idle animation of the default move
		local moveList = Utility.GetCharacterMoveList(char :: _TYPES.Character)
		for moveName, moveData in pairs(moveList) do
			-- If the move is not default, skip it
			if not moveData.isDefault then
				continue
			end

			AnimationService.Play(char :: _TYPES.Character, moveName .. "_Idle")
			break
		end
	end)
end
return CombatService
