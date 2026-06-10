local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local EventService = require(Services.EventService)
local TurnService = require(Services.TurnService)
-- Data
local AttackPattern = require(rep.Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_AttackPattern)
-- Attack handlers
local Handlers = {
	BasicAttack = require(script.Parent.Handlers.MockEnemy_BasicAttack),
	Skill = require(script.Parent.Handlers.MockEnemy_Skill),
}

local charName = "MockEnemy"
local Chars = {} :: { [_TYPES.Character]: { _TYPES.NPCCombatData } }

local MockEnemy_CombatService = {}

function MockEnemy_CombatService.OnStart()
	-- Listens to spawn successful events to initialize combat data for the spawned characters
	EventService.Events.SpawnSuccessfulForChar:Connect(function(spawnSuccessfulForCharEvent)
		local char = spawnSuccessfulForCharEvent.data.char

		-- Initialize combat data for the character if it doesn't exist already
		if not Chars[char] then
			Chars[char] = {
				currentPatternIndex = 1,
			}
		end
	end)

	-- Listens to execution of NPC attacks
	EventService.Events.ExecuteNPCAttack:Connect(function(data)
		local currentTurn = TurnService.GetCurrentTurn()

		-- Check if the origin of the event data is the current character whose turn it is
		if not currentTurn or data.char ~= currentTurn.char :: any then
			return
		end

		-- Use the attack pattern module to determine which attack to execute based on the current action
		local currentPatternIndex = Chars[data.char].currentPatternIndex
		if not currentPatternIndex then
			return
		end
		local attackToExecute = AttackPattern[currentPatternIndex]
		if attackToExecute == "BasicAttack" then
			Handlers.BasicAttack(data.char)
		elseif attackToExecute == "Skill" then
			-- No skill for the mock enemy yet, so we'll just do a basic attack for now
			Handlers.Skill(data.char)
		end

		-- Loop back to the start of the attack pattern if we've reached the end
		if currentPatternIndex + 1 >= #AttackPattern then
			Chars[data.char].currentPatternIndex = 1
		else
			Chars[data.char].currentPatternIndex += 1
		end
	end)
end

return MockEnemy_CombatService
