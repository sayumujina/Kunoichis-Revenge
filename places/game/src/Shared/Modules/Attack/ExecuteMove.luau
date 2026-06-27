local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
--  Services
local Services = game:GetService("ServerScriptService").Server.Services
local AnimationService = require(Services.AnimationService)
local TurnService = require(Services.TurnService)
local EventService = require(Services.EventService)
local PlayerService = require(Services.PlayerService)
local DamageService = require(Services.DamageService)
local CharService = require(Services.CharService)
local InputService = require(Services.InputService)
-- Combat utility
local CombatUtility = game.ReplicatedStorage.Shared.Modules.Attack.Utility
local ProvideEnergy = require(CombatUtility.ProvideEnergy)
local CalculateDamage = require(CombatUtility.CalculateDamage)
local CalculateHealing = require(CombatUtility.CalculateHealing)
local DetermineTargets = require(CombatUtility.DetermineTargets)
local HandleMana = require(CombatUtility.HandleMana)
-- Utility
local Utility = require(game.ReplicatedStorage.Shared.Modules.Utility)
-- Signal
local Signal = require(game.ReplicatedStorage.Packages.Signal)

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param attackData -- The data for the attack to create
--- @param moveToNextTurn -- Whether to move to the next turn after executing the attack
--- @return boolean -- Returns true if the attack was executed successfully, false otherwise
local function ExecuteMove(moveName: string, attackData: _TYPES.AttackData, moveToNextTurn: boolean?)
	-- Turn off input availability for actions during the attack animation
	InputService.ToggleActionsAvailability(false)

	local player = PlayerService.GetPlayerFromCharacter(attackData.origin)
	if not player then
		warn("Player not found for the origin character.")
		InputService.ToggleActionsAvailability(true)
		return false
	end

	-- Check if the  ALLY has enough mana to perform the move
	-- If after the move, the ally's mana would be less than 0, then the move cannot be performed
	-- Only allies have mana change in the move data,  hence the "if attackData.manaChange" condition
	if attackData.manaChange and not HandleMana.HasEnoughMana(player, attackData.manaChange) then
		warn("Not enough mana to perform the move: " .. moveName)
		InputService.ToggleActionsAvailability(true)
		return false
	end

	-- Determine targets on the server
	-- The client has its own version of this for visual purposes, but the server will verify it to be safe
	local targets = DetermineTargets(attackData, moveName)
	-- Return false if no valid targets were found
	if not targets or #targets == 0 then
		warn("No valid targets found for attack: " .. moveName)
		InputService.ToggleActionsAvailability(true)
		return false
	end

	-- Play the attack animation
	local anim = AnimationService.Play(attackData.origin, moveName .. "_Execute")
	if not anim then
		warn("Failed to play animation for attack: " .. moveName)
		InputService.ToggleActionsAvailability(true)
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

	-- Update the player's mana after performing the move
	if attackData.manaChange then
		HandleMana.UpdatePlayerMana(player, attackData.manaChange)
	end

	local trove = CharService.GetCharacterCombatData(attackData.origin).trove
	local currentAttack = 1

	-- Apply damage on the hit marker
	trove:Add(anim:GetMarkerReachedSignal("hit"):Connect(function()
		-- Retrieve the attack data for the current attack
		local data = attackData.attacks[currentAttack]
		-- Loop through each target and apply the appropriate effect based on the move category
		for _, target in pairs(targets) do
			if attackData.moveCategory == "Damage" then
				local damage = CalculateDamage(data.scalings, attackData.origin, target, moveName)
				DamageService.Damage(attackData.origin, target, damage)

				-- Also deal exposure damage if specified
				if data.exposureDealt and data.exposureDealt > 0 then
					DamageService.DealExposure(attackData.origin, target, data.exposureDealt)
				end

				-- Play the hurt animation for each target
				AnimationService.Play(target, "Hurt_Normal")
			elseif attackData.moveCategory == "Heal" then
				local healingAmount = CalculateHealing(data.scalings, attackData.origin, target, moveName)
				DamageService.Heal(attackData.origin, target, healingAmount)
			end
		end

		-- Provide energy gain for allies
		if data.energyGain then
			ProvideEnergy(attackData.origin, data.energyGain, false)
		end

		-- Increment the current attack index for the next hit marker
		currentAttack += 1
	end))

	-- Move to the next turn after the attack animation is complete
	trove:Add(anim.Stopped:Connect(function()
		-- Move to the next turn if specified
		if moveToNextTurn then
			InputService.ToggleActionsAvailability(true)
			TurnService.MoveToNextTurn()
		end

		-- Clean up the trove after the animation is complete
		trove:Clean()
	end))

	return true
end

return ExecuteMove
