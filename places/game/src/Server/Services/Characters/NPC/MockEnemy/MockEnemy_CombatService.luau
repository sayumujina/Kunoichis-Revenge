local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local EventService = require(Services.EventService)
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
-- Utilities
local DeterminePrimaryTargetIndex = require(rep.Shared.Modules.Attack.Utility.DeterminePrimaryTargetIndex)
-- Data
local AttackPattern = require(rep.Shared.Data.Characters.NPC.MockEnemy.data_MockEnemy_AttackPattern)
-- Attack handlers
local Handlers = {
	BasicAttack = require(script.Parent.Handlers.MockEnemy_BasicAttack),
	Skill = require(script.Parent.Handlers.MockEnemy_Skill),
} :: { [string]: (_TYPES.Character, number) -> () }

local charName = "MockEnemy"
local Chars = {} :: { [_TYPES.Character]: { _TYPES.NPCCombatData } }

local MockEnemy_CombatService = {}

function MockEnemy_CombatService.OnStart()
	-- Listens to spawn successful events to initialize combat data for the spawned characters
	EventService.Events.SpawnSuccessfulForChar:Connect(function(spawnSuccessfulForCharEvent)
		local char = spawnSuccessfulForCharEvent.data.char

		-- Skip if the character is not MockEnemy
		if char.Name ~= charName then
			return
		end

		-- Initialize combat data for the character if it doesn't exist already
		if not Chars[char] then
			Chars[char] = {
				currentPatternIndex = 1,
			}
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
		return
	end

	-- Use the attack pattern module to determine which attack to execute based on the current action
	local currentPatternIndex = Chars[char].currentPatternIndex
	if not currentPatternIndex then
		return
	end

	local attackToExecute = AttackPattern[currentPatternIndex]
	local primaryTargetIndex = DeterminePrimaryTargetIndex()

	-- If there's no valid attack or primary target index, skip the turn
	if not attackToExecute or not primaryTargetIndex then
		return
	end

	-- Execute the attack using the appropriate handler
	if attackToExecute == "BasicAttack" then
		Handlers.BasicAttack(char, primaryTargetIndex)
	elseif attackToExecute == "Skill" then
		Handlers.Skill(char, primaryTargetIndex)
	end

	-- Loop back to the start of the attack pattern if we've reached the end
	if currentPatternIndex + 1 >= #AttackPattern then
		Chars[char].currentPatternIndex = 1
	else
		Chars[char].currentPatternIndex += 1
	end
end

--- Get the attack handlers for MockEnemy's combat service
function MockEnemy_CombatService.GetAttackHandlers()
	return Handlers
end

return MockEnemy_CombatService
