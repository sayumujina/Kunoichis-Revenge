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
-- Utility
local Utility = require(game.ReplicatedStorage.Shared.Modules.Utility)

-- Flag to prevent multiple attacks from being processed simultaneously
local processingAttack = false

-- Helper function to find a character in the workspace based on the provided index
local function findCharacterWithIndex(indexToFind: number): _TYPES.Character?
	local enemiesFolder = game.Workspace.Characters.Enemies
	if not enemiesFolder then
		warn("Enemies folder not found in Workspace.")
		return nil
	end

	-- Loop through the children of the Enemies folder to find the character with the matching index
	for _, child in pairs(enemiesFolder:GetChildren()) do
		local charIndex = child:GetAttribute("Index")
		warn(charIndex, indexToFind)
		if charIndex and charIndex == indexToFind then
			return child :: _TYPES.Character
		end
	end

	return nil
end

--- Creates an attack function based on the provided attack data
--- @within Modules
--- @param attackData -- The data for the attack to create
--- @param moveToNextTurn -- Whether to move to the next turn after executing the attack
--- @return boolean -- Returns true if the attack was executed successfully, false otherwise
local function ExecuteAttack(moveName: string, attackData: _TYPES.AttackData, moveToNextTurn: boolean?)
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
	local targets = {} :: { _TYPES.Character }
	local targetsInWorkspace = game.Workspace.Characters.Enemies:GetChildren()
	local moveData = Utility.GetCharacterMoveList(attackData.origin :: _TYPES.Character)[moveName]
	local enemySelectionType = moveData.enemySelectionType

	-- Determine the indexes first
	if enemySelectionType == "Single" then -- Select a single enemy.
		table.insert(targets, findCharacterWithIndex(attackData.primaryTargetIndex) :: _TYPES.Character)
	elseif enemySelectionType == "Blast" then -- Select a main enemy and 2 enemies around them (if they exist).
		-- Insert the primary target first
		table.insert(targets, findCharacterWithIndex(attackData.primaryTargetIndex) :: _TYPES.Character)

		-- Check if the primary target has adjacent enemies and add them to the targets list
		if attackData.primaryTargetIndex - 1 > 0 then
			table.insert(targets, findCharacterWithIndex(attackData.primaryTargetIndex - 1) :: _TYPES.Character)
		end
		if attackData.primaryTargetIndex + 1 <= #targetsInWorkspace then
			table.insert(targets, findCharacterWithIndex(attackData.primaryTargetIndex + 1) :: _TYPES.Character)
		end
	elseif enemySelectionType == "AoE" then -- Select all enemies on the field.
		targets = targetsInWorkspace
	end

	warn(attackData.primaryTargetIndex, targets)

	-- Return false if no valid targets were found
	if not targets or #targets == 0 then
		warn("No valid targets found for attack: " .. moveName)
		processingAttack = false
		return false
	end

	-- Fire the successful attack event
	EventService.Events.SuccessfulAttack:Fire({
		player = PlayerService.GetPlayerFromCharacter(attackData.origin) :: _TYPES.RobloxPlayerType,
		data = {
			char = attackData.origin :: _TYPES.Character,
			data = {
				moveName = moveName,
				targets = targets,
			},
		},
	})

	anim.Stopped:Connect(function()
		-- Provide energy gain
		ProvideEnergy(attackData.origin, attackData.data.energyGain, false)

		-- Calculate damage
		for _, target in pairs(targets) do
			DamageService.Damage(attackData.origin, target, CalculateDamage(attackData, moveName))
		end

		-- Play the hurt animation for each target
		for _, target in pairs(targets) do
			AnimationService.Play(target, "Hurt_Normal")
		end

		-- Move to the next turn if specified
		if moveToNextTurn then
			print("Moving to next turn after attack animation")
			processingAttack = false
			TurnService.MoveToNextTurn()
		end
	end)

	return true
end

return ExecuteAttack
