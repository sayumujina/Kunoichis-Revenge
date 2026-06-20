local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
--  Services
local Services = game:GetService("ServerScriptService").Server.Services
local AnimationService = require(Services.AnimationService)
local TurnService = require(Services.TurnService)
local EventService = require(Services.EventService)
local PlayerService = require(Services.PlayerService)
local DamageService = require(Services.DamageService)
-- Combat utility
local CombatUtility = game.ReplicatedStorage.Shared.Modules.Attack.Utility
local ProvideEnergy = require(CombatUtility.ProvideEnergy)
local CalculateDamage = require(CombatUtility.CalculateDamage)
local CalculateHealing = require(CombatUtility.CalculateHealing)
local DetermineTargets = require(CombatUtility.DetermineTargets)
-- Utility
local Utility = require(game.ReplicatedStorage.Shared.Modules.Utility)
-- Signal
local Signal = require(game.ReplicatedStorage.Packages.Signal)

-- Flag to prevent multiple attacks from being processed simultaneously
local processingAttack = false

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param attackData -- The data for the attack to create
--- @param moveToNextTurn -- Whether to move to the next turn after executing the attack
--- @return boolean -- Returns true if the attack was executed successfully, false otherwise
local function ExecuteMove(moveName: string, attackData: _TYPES.AttackData, moveToNextTurn: boolean?)
	-- Prevent multiple attacks from being processed at the same time
	if processingAttack then
		warn("Already processing an attack, cannot execute another one simultaneously.")
		return false
	end

	-- Set processing flag to true
	processingAttack = true

	-- Play the attack animation
	local anim = AnimationService.Play(attackData.origin, moveName .. "_Execute")
	if not anim then
		warn("Failed to play animation for attack: " .. moveName)
		processingAttack = false
		return false
	end

	-- Determine targets on the server
	-- The client has its own version of this for visual purposes, but the server will verify it to be safe
	local targets = DetermineTargets(attackData, moveName)
	-- Return false if no valid targets were found
	if not targets or #targets == 0 then
		warn("No valid targets found for attack: " .. moveName)
		processingAttack = false
		return false
	end

	-- Fire the successful move event
	EventService.Events.SuccessfulMove:Fire({
		char = attackData.origin :: _TYPES.Character,
		data = {
			moveName = moveName,
			targets = targets,
		},
	})

	local connection
	connection = anim.Stopped:Connect(function()
		connection:Disconnect() -- Disconnect the listener

		-- Apply the damage/ healing/ shield effects to each target based on the attack data
		for _, target in pairs(targets) do
			if attackData.moveCategory == "Damage" then
				local damage = CalculateDamage(attackData, target, moveName)
				DamageService.Damage(attackData.origin, target, damage)

				-- Play the hurt animation for each target
				AnimationService.Play(target, "Hurt_Normal")
			elseif attackData.moveCategory == "Heal" then
				local healingAmount = CalculateHealing(attackData, target, moveName)
				DamageService.Heal(attackData.origin, target, healingAmount)
			end
		end

		-- Provide energy gain
		ProvideEnergy(attackData.origin, attackData.data.energyGain, false)

		-- Move to the next turn if specified
		if moveToNextTurn then
			print("Moving to next turn after attack animation")
			processingAttack = false
			TurnService.MoveToNextTurn()
		end
	end)

	return true
end

return ExecuteMove
