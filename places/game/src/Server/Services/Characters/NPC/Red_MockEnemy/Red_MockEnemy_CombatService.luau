local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local EventService = require(Services.EventService)
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
local StatusService = require(Services.StatusService)
local CombatService = require(Services.CombatService)
-- Utilities
local DeterminePrimaryTargetIndex = require(rep.Shared.Modules.Attack.Utility.DeterminePrimaryTargetIndex)

-- Data
local AttackPattern = require(rep.Shared.Data.Characters.NPC.Red_MockEnemy.data_Red_MockEnemy_AttackPattern)
local CombatInfo = require(rep.Shared.Data.Characters.NPC.Red_MockEnemy.data_Red_MockEnemy_CombatInfo)
local MoveInfo = require(rep.Shared.Data.Characters.NPC.Red_MockEnemy.data_Red_MockEnemy_Moves)

-- Attack handlers
local Handlers = {
	BasicAttack = require(script.Parent.Handlers.Red_MockEnemy_BasicAttack),
	Skill = require(script.Parent.Handlers.Red_MockEnemy_Skill),
} :: { [string]: (_TYPES.Character) -> boolean }

local charName = "Red_MockEnemy"
local Chars = {} :: { [_TYPES.Character]: { _TYPES.NPCCombatData } }

-- Toughened status
local toughenedStatus = {
	statusType = { "DmgTakenReduced" } :: { _TYPES.StatusTypes },
	--
	info = {
		name = "Toughened",
		description = "The character has toughened and take 80% less damage. Removed upon collapsing",
	},
	--
	data = {
		expellable = false,
	},
	--
	statChanges = {
		{
			statChangeType = "Flat",
			statName = "dmgTakenMult",
			value = CombatInfo.toughenedStatus.dmgTakenMult, -- Take 80% less damage while toughened
		},
	} :: { _TYPES.StatChangeTypes },
} :: _TYPES.Status

-- Weakened status
local weakenedStatus = {
	statusType = { "DmgTakenIncreased" } :: { _TYPES.StatusTypes },
	--
	info = {
		name = "Weakened",
		description = "The character has weakened and take 50% more damage. Removed upon recovering from collapsing",
	},
	--
	data = {
		expellable = false,
	},
	--
	statChanges = {
		{
			statChangeType = "Flat",
			statName = "dmgTakenMult",
			value = CombatInfo.weakenedStatus.dmgTakenMult, -- Take 50% more damage while weakened
		},
	} :: { _TYPES.StatChangeTypes },
} :: _TYPES.Status

local Red_MockEnemy_CombatService = {}

function Red_MockEnemy_CombatService.OnStart()
	-- Listens to spawn successful events to initialize combat data for the spawned characters
	EventService.Events.SpawnSuccessfulForChar:Connect(function(spawnSuccessfulForCharEvent)
		local spawnChar = spawnSuccessfulForCharEvent.data.char

		-- Skip if the character is not Red_MockEnemy
		if spawnChar.Name ~= charName then
			return
		end

		-- Add the toughened status to the character
		StatusService.AddStatus(spawnChar, "Red_MockEnemy_Toughened", toughenedStatus)
	end)

	-- Listens to status added event
	EventService.Events.StatusAdded:Connect(function(statusAddedEvent)
		-- Skip if the character is not found in the Chars table (i.e., not Red_MockEnemy)
		local statusOrigin = statusAddedEvent.data.char
		if not Chars[statusOrigin] then
			return
		end

		local statusName = statusAddedEvent.data.data.id

		-- If the character collapsed, remove the toughened status and applied weakened status
		if statusName == "Collapsed" then
			StatusService.RemoveStatus(statusOrigin, "Red_MockEnemy_Toughened")
			StatusService.AddStatus(statusOrigin, "Red_MockEnemy_Weakened", weakenedStatus)
		end
	end)

	-- Listens to status removed event
	EventService.Events.StatusRemoved:Connect(function(statusRemovedEvent)
		-- Skip if the character is not found in the Chars table (i.e., not Red_MockEnemy)
		local statusOrigin = statusRemovedEvent.data.char
		if not Chars[statusOrigin] then
			return
		end

		local statusName = statusRemovedEvent.data.data.id

		-- If the character's collapsed status was removed, reapply the toughened status and remove weakened status
		if statusName == "Collapsed" then
			StatusService.AddStatus(statusOrigin, "Red_MockEnemy_Toughened", toughenedStatus)
			StatusService.RemoveStatus(statusOrigin, "Red_MockEnemy_Weakened")
		end
	end)
end

function Red_MockEnemy_CombatService.Init(char: _TYPES.Character)
	-- Initialize combat data for the character if it doesn't exist already
	if not Chars[char] then
		Chars[char] = {
			currentPatternIndex = 1,
		}
	end

	-- Clean up when the character is destroyed
	char.Destroying:Connect(function()
		if Chars[char] then
			Chars[char] = nil
		end
	end)
end

--- Handles the attack behaviour for the Red_MockEnemy character
--- @param char - The character to handle the attack behaviour for
function Red_MockEnemy_CombatService.HandleAttackBehaviour(char: _TYPES.Character)
	local currentTurn =
		TurnService.GetCurrentTurn(PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType)

	-- Check if the origin of the event data is the current character whose turn it is
	if not currentTurn or char ~= currentTurn.char :: any then
		return false
	end

	-- Use the attack pattern module to determine which attack to execute based on the current action
	local currentPatternIndex = Chars[char].currentPatternIndex
	if not currentPatternIndex then
		return false
	end

	-- Determine the primary target index for the attack
	local attackToExecute = AttackPattern[currentPatternIndex]
	local primaryTargetIndex = DeterminePrimaryTargetIndex()

	if not primaryTargetIndex then
		warn("No valid primary target index found for Red_MockEnemy's attack.")
		return false
	end

	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	CombatService.SetPrimarySelectedTargetIndex(player, primaryTargetIndex, MoveInfo[attackToExecute].selectedSide)

	-- If there's no valid attack or primary target index, skip the turn
	if not attackToExecute or not primaryTargetIndex then
		return false
	end

	-- Execute the attack using the appropriate handler
	if attackToExecute == "BasicAttack" then
		return Handlers.BasicAttack(char)
	elseif attackToExecute == "Skill" then
		return Handlers.Skill(char)
	end

	-- Loop back to the start of the attack pattern if we've reached the end
	if currentPatternIndex + 1 >= #AttackPattern then
		Chars[char].currentPatternIndex = 1
	else
		Chars[char].currentPatternIndex += 1
	end

	return false
end

--- Get the attack handlers for Red_MockEnemy's combat service
function Red_MockEnemy_CombatService.GetAttackHandlers()
	return Handlers
end

return Red_MockEnemy_CombatService
