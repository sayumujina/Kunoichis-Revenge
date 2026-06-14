local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local CombatUtility = game.ReplicatedStorage.Shared.Modules.Attack.Utility
local ProvideEnergy = require(CombatUtility.ProvideEnergy)
--  Services
local Services = game:GetService("ServerScriptService").Server.Services
local AnimationService = require(Services.AnimationService)
local TurnService = require(Services.TurnService)

local processingAttack = false

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param attackData -- The data for the attack to create
--- @param moveToNextTurn -- Whether to move to the next turn after executing the attack

local function ExecuteAttack(moveName: string, attackData: _TYPES.AttackData, moveToNextTurn: boolean?)
	-- Prevent multiple attacks from being processed at the same time
	if processingAttack then
		warn("Already processing an attack, cannot execute another one simultaneously.")
		return
	end

	-- Set processing flag to true
	processingAttack = true

	-- Play the attack animation
	local anim = AnimationService.Play(attackData.origin, moveName .. "_Execute")
	if not anim then
		warn("Failed to play animation for attack: " .. moveName)
		return
	end

	-- Provide energy gain
	ProvideEnergy(attackData.origin, attackData.data.energyGain, false)

	-- Move to the next turn if specified
	if moveToNextTurn then
		anim.Stopped:Connect(function()
			print("Moving to next turn after attack animation")
			processingAttack = false
			TurnService.MoveToNextTurn()
		end)
	end
end

return ExecuteAttack
