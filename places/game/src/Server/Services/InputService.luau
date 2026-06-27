local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local TurnService = require(Services.TurnService)
-- Packages
local Zap = require(Services.Parent.zap)

local InputService = {}

local allowActions = true
-- A list of disallowed actions during an attack animation
local DisallowedActionsDuringAttack = {
	-- Attacks (except ultimate)
	"BasicAttack",
	"Skill",
	-- Target selection
	"PreviousTarget",
	"NextTarget",
}

-- Helper function to check if an action is allowed based on the current state
local function isActionAllowed(actionName: string): boolean
	if allowActions then
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
	-- Listen to input sent event from the client
	Zap.InputSent.On(function(_, inputData)
		-- Check if the action is allowed
		local action = inputData.action
		if not isActionAllowed(action) then
			warn("Action", action, "is not allowed at this time.")
			return
		end

		-- Get the character from the input data
		local char = inputData.origin
		local currentTurnChar = TurnService.GetCurrentTurn()
		if not char or not currentTurnChar or char :: any ~= currentTurnChar.char then
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
	end)
end

--- Disables actions for the player
--- @param shouldEnable -- Whether to enable or disable actions
function InputService.ToggleActionsAvailability(shouldEnable: boolean)
	allowActions = shouldEnable
	warn("Actions availability set to", shouldEnable)
end

return InputService
