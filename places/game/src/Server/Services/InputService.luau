local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local TurnService = require(Services.TurnService)
local EventService = require(Services.EventService)
-- Packages
local Zap = require(Services.Parent.zap)

local InputService = {}
local Players = {} :: {
	allowActions: boolean,
	skipTurnSelected: boolean,
}

-- A list of disallowed actions during an attack animation
local DisallowedActionsDuringAttack = {
	-- Attacks (except casting an ultimate)
	"BasicAttack",
	"Skill",
	-- Target selection
	"PreviousTarget",
	"NextTarget",
	-- Turn skip
	"SkipTurn",
}

-- A list of allowed inputs outside of the character's turn
local AllowedInputsOutsideOfTurn = {
	"Ultimate1",
	"Ultimate2",
	"Ultimate3",
}

-- Helper function to check if an action is allowed based on the current state
local function isActionAllowed(player: _TYPES.RobloxPlayerType, actionName: string): boolean
	-- If the player is in the middle of an attack, only allow certain actions
	if Players[player].allowActions then
		return true
	end

	return not table.find(DisallowedActionsDuringAttack, actionName)
end

-- Helper function to get a character's combat service module
local function getCharacterCombatService(char: _TYPES.Character): any
	local combatServiceModuleName = char.Name .. "_CombatService"
	local combatServiceModule =
		Services.Characters[char:GetAttribute("Side")][char.Name]:FindFirstChild(combatServiceModuleName)
	if not combatServiceModule then
		warn("CombatService module", combatServiceModuleName, "not found for character", char.Name)
		return nil
	end

	return combatServiceModule
end

--- Called when the service starts
function InputService.OnStart()
	-- Reset isActionAllowed on spawn
	EventService.Events.SpawnFinished:Connect(function(spawnData)
		local player = spawnData.player
		if not Players[player] then
			Players[player] = {
				allowActions = true,
				skipTurnSelected = false,
			}
		end

		InputService.ToggleActionsAvailability(player, true)
	end)

	-- Listen to input sent event from the client
	Zap.InputSent.On(function(player, inputData)
		-- Check if the action is allowed
		local action = inputData.action
		if not isActionAllowed(player :: _TYPES.RobloxPlayerType, action) then
			warn("Action", action, "is not allowed at this time.")
			return
		end

		-- Handle the SkipTurn action separately
		-- Only confirm the skip action if it has already been selected once
		if action == "SkipTurn" then
			if not Players[player].skipTurnSelected then
				Players[player].skipTurnSelected = true
				return
			end

			-- Call the TurnService to skip the turn
			TurnService.SkipTurn(player :: _TYPES.RobloxPlayerType)

			Players[player].skipTurnSelected = false
			return
		end
		-- Get the character from the input data
		local char = inputData.origin
		local activeChar = player.ActiveCharacter.Value

		if not char then
			warn("No character found for player", player.Name, "when processing input action", action)
			return
		end

		-- Get the combat service module
		local charCombatService = getCharacterCombatService(char :: any)
		if not charCombatService then
			warn("CombatService not found for character", char.Name)
			return
		end

		-- Call the module's handle input function
		if charCombatService then
			require(charCombatService).HandleInput(char :: any, inputData)
		else
			warn("HandleInput function not found in CombatService for character", char.Name)
		end

		-- If one other action has succeeded, reset the skipTurnSelected flag to false
		Players[player].skipTurnSelected = false
	end)
end

--- Disables actions for the player
--- @param shouldEnable -- Whether to enable or disable actions
function InputService.ToggleActionsAvailability(player: _TYPES.RobloxPlayerType, shouldEnable: boolean)
	Players[player].allowActions = shouldEnable
end

return InputService
