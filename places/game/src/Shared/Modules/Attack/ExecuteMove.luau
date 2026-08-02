local _TYPES = require(game.ReplicatedStorage.Data.data_Types)
--  Services
local Services = game:GetService("ServerScriptService").Server.Services
local AnimationService = require(Services.AnimationService)
local TurnService = require(Services.TurnService)
local CombatService = require(Services.CombatService)
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
local ProvideShield = require(CombatUtility.ProvideShield)
-- Utility
local Utility = require(game.ReplicatedStorage.Shared.Modules.Utility)
-- Packages
local Zap = require(Services.Parent.zap)

-- Helper function to reset the attacking state for a player after an attack animation is complete
local function resetAttackingState(player: _TYPES.RobloxPlayerType, enableInput: boolean?)
	-- Re-enable input availability for actions after the attack animation is complete
	if enableInput then
		InputService.ToggleActionsAvailability(player, true)
		-- Send the allow detailed combat info toggle event to the client to enable the detailed combat info menu toggle during the attack animation
		Zap.AllowCombatInfoMenuToggle.Fire(player :: _TYPES.RobloxPlayerType, {
			allowed = true,
		})
	end

	-- Set the attacking state to false
	CombatService.SetAttackingState(player :: _TYPES.RobloxPlayerType, false)
end

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param char -- The character performing the attack
--- @param fromSide -- The side from which the attack is performed
--- @param moveName -- The name of the move being executed
--- @param attackData -- The data associated with the attack, including targets, attacks, and other relevant information
--- @param isExtraAction -- Optional boolean indicating if this attack is part of an extra action
--- @return boolean -- Returns true if the attack was executed successfully, false otherwise
local function ExecuteMove(
	char: _TYPES.Character,
	fromSide: _TYPES.Sides,
	moveName: string,
	attackData: _TYPES.AttackData,
	isExtraAction: boolean?
)
	local player = PlayerService.GetPlayerFromCharacter(char)

	-- Turn off input availability for actions during the attack animation
	InputService.ToggleActionsAvailability(player :: _TYPES.RobloxPlayerType, false)
	-- Mark the attack as being processed
	CombatService.SetAttackingState(player :: _TYPES.RobloxPlayerType, true)
	-- Send the allow detailed combat info toggle event to the client to disable the detailed combat info menu toggle during the attack animation
	Zap.AllowCombatInfoMenuToggle.Fire(player :: _TYPES.RobloxPlayerType, {
		allowed = false,
	})

	if not player then
		resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
		return false
	end

	-- Return if no primary target index or targets are provided for the attack
	if not attackData.primaryTargetIndex and not attackData.targets then
		resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
		return false
	end

	-- Check if the playable character has enough mana to perform the move
	-- If after the move, the playable character's mana would be less than 0, then the move cannot be performed
	-- Only playable characters have mana change in the move data,  hence the "if attackData.manaChange" condition
	if attackData.manaChange and not HandleMana.HasEnoughMana(player, attackData.manaChange) then
		Zap.Warning.Fire(player, {
			success = false,
			message = "Insufficient mana",
		})
		resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
		return false
	end

	-- Determine targets on the server
	-- The client has its own version of this for visual purposes, but the server will verify it to be safe
	local targets = #attackData.targets > 0 and attackData.targets -- Use the provided targets if they exist
		or DetermineTargets(char, attackData.primaryTargetIndex, moveName) -- Determine targets if not provided
	-- Return false if no valid targets were found
	if not targets or #targets == 0 then
		warn("No valid targets found for attack: " .. moveName)
		resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
		return false
	-- Else, append the targets to the attackData
	else
		attackData.targets = targets
	end

	-- Play the attack animation
	local anim = AnimationService.Play(char, moveName .. "_Execute")
	if not anim then
		resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
		return false
	end

	-- Fire the successful move event
	EventService.Events.SuccessfulMove:Fire({
		origin = char,
		data = {
			moveName = moveName,
			attackData = attackData,
		},
	})

	-- Update the player's mana after performing the move
	if attackData.manaChange then
		HandleMana.UpdatePlayerMana(player, attackData.manaChange)
	end

	local trove = CharService.GetCharacterCombatData(char).trove
	local currentAttack = 1
	local data

	local deadTargets = {}
	-- Apply damage on the hit marker
	trove:Add(anim:GetMarkerReachedSignal("hit"):Connect(function()
		-- Retrieve the attack data for the current attack
		data = attackData.attacks[currentAttack]
		-- Loop through each target and apply the appropriate effect based on the move category
		for _, target in pairs(targets) do
			if data.attackCategory == "Damage" then
				local damage, isCrit = CalculateDamage(data.scalings, char, target, moveName)
				local shouldKill = DamageService.Damage(char, target, damage, isCrit).shouldKill
				if shouldKill and not table.find(deadTargets, target) then
					table.insert(deadTargets, target)
				end

				-- Also deal exposure damage if specified
				if data.exposureDealt and data.exposureDealt > 0 then
					DamageService.DealExposure(char, target, data.exposureDealt)
				end

				-- Play the hurt animation for each target
				AnimationService.Play(target, "Hurt_Normal")
			end
		end

		-- Provide energy gain for allies
		if data.energyGain then
			ProvideEnergy(char, data.energyGain, false)
		end

		-- Increment the current attack index for the next hit marker
		currentAttack += 1
	end))

	trove:Add(anim:GetMarkerReachedSignal("heal"):Connect(function()
		-- Retrieve the attack data for the current attack
		data = attackData.attacks[currentAttack]
		-- Loop through each target and apply the appropriate effect based on the move category
		for _, target in pairs(targets) do
			if data.attackCategory == "Heal" then
				local healingAmount = CalculateHealing(data.scalings, char, target, moveName)
				DamageService.Heal(char, target, healingAmount)
			end
		end

		-- Provide energy gain for allies
		if data.energyGain then
			ProvideEnergy(char, data.energyGain, false)
		end

		-- Increment the current attack index for the next hit marker
		currentAttack += 1
	end))

	-- Apply shield on the shield marker
	trove:Add(anim:GetMarkerReachedSignal("shield"):Connect(function()
		-- Retrieve the attack data for the current attack
		data = attackData.attacks[currentAttack]
		-- Loop through each target and apply the appropriate effect based on the move category
		for _, target in pairs(targets) do
			if data.attackCategory == "Shield" then
				ProvideShield(data, char, target, moveName)
			end
		end

		-- Provide energy gain for allies
		if data.energyGain then
			ProvideEnergy(char, data.energyGain, false)
		end

		-- Increment the current attack index for the next hit marker
		currentAttack += 1
	end))

	-- Move to the next turn after the attack animation is complete
	trove:Add(anim.Stopped:Connect(function()
		local cleanupDelay = 0.5
		if deadTargets and #deadTargets > 0 then
			for _, target in pairs(deadTargets) do
				-- Fire the death event for each dead target
				EventService.Events.Death:Fire({
					char = target,
					origin = char,
				})
			end
			cleanupDelay = 1.5 -- Delay to allow death animations to play before moving to the next turn
		end

		local function cleanup()
			local turnData = TurnService.GetTurnData(player :: _TYPES.RobloxPlayerType)

			-- Move to the next turn if specified
			if not isExtraAction then
				TurnService.CompleteTurn(player :: _TYPES.RobloxPlayerType)
			-- End the current extra action for the player if this was an extra action
			else
				TurnService.EndCurrentExtraAction(player :: _TYPES.RobloxPlayerType)
			end

			-- If there's no more extra action left in the queue and no current turn exists
			if turnData and not next(turnData.extraActionQueue) then
				-- If there's a current turn, only reset the attacking state
				local currentTurnExists = turnData and turnData.currentTurn
				if currentTurnExists then
					resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
				-- If there's no current turn, reset the attacking state and move to the next turn
				else
					resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
					TurnService.MoveToNextTurn(player :: _TYPES.RobloxPlayerType)
				end
			else
				-- If the next action is a followup, do not enable input yet
				if
					turnData
					and turnData.extraActionQueue
					and turnData.extraActionQueue[1]
					and turnData.extraActionQueue[1].isFollowupAttack
				then
					resetAttackingState(player :: _TYPES.RobloxPlayerType)
				else
					resetAttackingState(player :: _TYPES.RobloxPlayerType, true)
				end

				-- Execute the next extra action
				TurnService.ExecuteNextExtraAction(player :: _TYPES.RobloxPlayerType)
			end

			-- Fire the MoveEnd event to notify that the move has ended
			EventService.Events.MoveEnd:Fire({
				origin = char,
				data = {
					moveName = moveName,
					recordedTargets = targets,
				},
			})

			-- Clean up the trove after the animation is complete
			trove:Clean()
		end

		if cleanupDelay > 0 then
			task.delay(cleanupDelay, cleanup)
		else
			cleanup()
		end
	end))

	return true
end

return ExecuteMove
