local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
-- Utilities
local DeterminePrimaryTargetIndex = require(rep.Shared.Modules.Attack.Utility.DeterminePrimaryTargetIndex)

-- Data
local AttackPattern = require(rep.Data.Characters.NPC.MockEnemy.data_MockEnemy_AttackPattern)
local MoveInfo = require(rep.Data.Characters.NPC.MockEnemy.data_MockEnemy_Moves)

-- Attack handlers
local Handlers = {
	BasicAttack = require(script.Parent.Handlers.MockEnemy_BasicAttack),
	Skill = require(script.Parent.Handlers.MockEnemy_Skill),
} :: { [string]: (_TYPES.Character) -> boolean }

local charName = "MockEnemy"
local Chars = {} :: { [_TYPES.Character]: { _TYPES.NPCCombatData } }

local MockEnemy_CombatService = {}

function MockEnemy_CombatService.OnStart() end

function MockEnemy_CombatService.Init(char: _TYPES.Character)
	-- Initialize the character's combat data if it doesn't exist
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

--- Handles the attack behaviour for the MockEnemy character
--- @param char - The character to handle the attack behaviour for
function MockEnemy_CombatService.HandleAttackBehaviour(char: _TYPES.Character)
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
	task.delay(1, function()
		Handlers[attackToExecute](char)
	end)

	-- Loop back to the start of the attack pattern if we've reached the end
	if currentPatternIndex + 1 >= #AttackPattern then
		Chars[char].currentPatternIndex = 1
	else
		Chars[char].currentPatternIndex += 1
	end

	return false
end

--- Get the attack handlers for MockEnemy's combat service
function MockEnemy_CombatService.GetAttackHandlers()
	return Handlers
end

return MockEnemy_CombatService
