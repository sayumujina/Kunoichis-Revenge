local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local TurnService = require(Services.TurnService)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
-- Packages
local Zap = require(Services.Parent.zap)

local InputService = {}

local allowActionsDuringAttack = true

-- A list of disallowed actions during an attack animation
local DisallowedActionsDuringAttack = {
	-- Attacks (except casting an ultimate)
	"BasicAttack",
	"Skill",
	-- Target selection
	"PreviousTarget",
	"NextTarget",
}

-- A list of allowed inputs outside of the character's turn
local AllowedInputsOutsideOfTurn = {
	"Ultimate1",
	"Ultimate2",
	"Ultimate3",
}

-- Helper function to check if an action is allowed based on the current state
local function isActionAllowed(actionName: string): boolean
	-- If the player is in the middle of an attack, only allow certain actions
	if allowActionsDuringAttack then
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
	Zap.InputSent.On(function(player, inputData)
		-- Check if the action is allowed
		local action = inputData.action
		if not isActionAllowed(action) then
			warn("Action", action, "is not allowed at this time.")
			return
		end

		-- Get the character from the input data
		local char = inputData.origin
		local activeChar = player.ActiveCharacter.Value

		-- Check if the character is valid and is the player's active character
		if not char or char ~= activeChar then
			-- Check if the action is allowed outside of the character's turn
			if not table.find(AllowedInputsOutsideOfTurn, inputData.action) then
				warn("action", action, "is not allowed outside of the character's turn.")
				return
			end
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
	allowActionsDuringAttack = shouldEnable
end

return InputService
