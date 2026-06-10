local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local CombatUtility = game.ReplicatedStorage.Shared.Modules.Attack.Utility
local ProvideEnergy = require(CombatUtility.ProvideEnergy)
--  Services
local Services = game:GetService("ServerScriptService").Server.Services
local TurnService = require(Services.TurnService)

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param attackData -- The data for the attack to create
--- @param moveToNextTurn -- Whether to move to the next turn after executing the attack

local function ExecuteAttack(attackData: _TYPES.AttackData, moveToNextTurn: boolean?)
	-- Provide energy gain
	ProvideEnergy(attackData.origin, attackData.data.energyGain, false)

	-- Move to the next turn if specified
	if moveToNextTurn then
		TurnService.MoveToNextTurn()
	end
end

return ExecuteAttack
