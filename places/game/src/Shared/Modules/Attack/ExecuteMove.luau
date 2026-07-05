local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
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
local CalculateShield = require(CombatUtility.CalculateShield)
local DetermineTargets = require(CombatUtility.DetermineTargets)
local HandleMana = require(CombatUtility.HandleMana)
-- Utility
local Utility = require(game.ReplicatedStorage.Shared.Modules.Utility)

-- Helper function to reset the attacking state for a player after an attack animation is complete
local function resetAttackingState(player: _TYPES.RobloxPlayerType)
	-- Re-enable input availability for actions after the attack animation is complete
	InputService.ToggleActionsAvailability(true)
	-- Mark the attack as not being processed
	CombatService.SetAttackingState(player :: _TYPES.RobloxPlayerType, false)
end

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param attackData -- The data for the attack to create
--- @param moveToNextTurn -- Whether to move to the next turn after executing the attack
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
	InputService.ToggleActionsAvailability(false)
	-- Mark the attack as being processed
	CombatService.SetAttackingState(player :: _TYPES.RobloxPlayerType, true)

	if not player then
		warn("Player not found for the origin character.")
		resetAttackingState(player :: _TYPES.RobloxPlayerType)
		return false
	end

	-- Check if the playable character has enough mana to perform the move
	-- If after the move, the playable character's mana would be less than 0, then the move cannot be performed
	-- Only playable characters have mana change in the move data,  hence the "if attackData.manaChange" condition
	if attackData.manaChange and not HandleMana.HasEnoughMana(player, attackData.manaChange) then
		warn("Not enough mana to perform the move: " .. moveName)
		resetAttackingState(player :: _TYPES.RobloxPlayerType)
		return false
	end

	-- Determine targets on the server
	-- The client has its own version of this for visual purposes, but the server will verify it to be safe
	local targets = #attackData.targets > 0 and attackData.targets -- Use the provided targets if they exist
		or DetermineTargets(char, attackData.primaryTargetIndex, moveName) -- Determine targets if not provided
	-- Return false if no valid targets were found
	if not targets or #targets == 0 then
		warn("No valid targets found for attack: " .. moveName)
		resetAttackingState(player :: _TYPES.RobloxPlayerType)
		return false
	-- Else, append the targets to the attackData
	else
		attackData.targets = targets
	end

	-- Play the attack animation
	local anim = AnimationService.Play(char, moveName .. "_Execute")
	if not anim then
		warn("Failed to play animation for attack: " .. moveName)
		resetAttackingState(player :: _TYPES.RobloxPlayerType)
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

	-- Apply damage on the hit marker
	trove:Add(anim:GetMarkerReachedSignal("hit"):Connect(function()
		-- Retrieve the attack data for the current attack
		data = attackData.attacks[currentAttack]
		-- Loop through each target and apply the appropriate effect based on the move category
		for _, target in pairs(targets) do
			if data.attackCategory == "Damage" then
				local damage = CalculateDamage(data.scalings, char, target, moveName)
				DamageService.Damage(char, target, damage)

				-- Also deal exposure damage if specified
				if data.exposureDealt and data.exposureDealt > 0 then
					DamageService.DealExposure(char, target, data.exposureDealt)
				end

				-- Play the hurt animation for each target
				AnimationService.Play(target, "Hurt_Normal")
			elseif data.attackCategory == "Heal" then
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
				local shieldAmount = CalculateShield(data.scalings, char, target, moveName)

				-- Get the current shield value of the target
				local targetCombatData = CharService.GetCharacterCombatData(target)
				local currentShield = targetCombatData.currentStats.shield
				targetCombatData.currentStats.shield = currentShield + shieldAmount
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
		-- Reset the attacking state for the player after the attack animation is complete
		resetAttackingState(player :: _TYPES.RobloxPlayerType)

		local turnData = TurnService.GetTurnData(player :: _TYPES.RobloxPlayerType)

		-- Move to the next turn if specified
		if not isExtraAction then
			TurnService.CompleteTurn(player :: _TYPES.RobloxPlayerType)
		-- End the current extra action for the player if this was an extra action
		else
			TurnService.EndCurrentExtraAction(player :: _TYPES.RobloxPlayerType)
		end

		-- Get the timer for the player
		-- Skip this step there is already an extra action queued
		if turnData and not next(turnData.extraActionQueue) then
			local combatData = CombatService.GetCombatData(player :: _TYPES.RobloxPlayerType)
			combatData.startTurnTimeout.Tick:Once(function()
				warn("Start turn timeout reached for player:", player.Name)
				TurnService.MoveToNextTurn(player :: _TYPES.RobloxPlayerType)
			end)
			-- Start the timer for the player to move to the next turn
			combatData.startTurnTimeout:Start()
			warn("Starting start turn timeout for player:", player.Name)
		end

		-- Clean up the trove after the animation is complete
		trove:Clean()
	end))

	return true
end

return ExecuteMove
