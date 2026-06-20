--!strict
-- Core services
local Services = game:GetService("ServerScriptService").Server.Services
local Players = game:GetService("Players")
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Packages
local Signal = require(rep.Packages.Signal)
-- Events
local Zap = require(Services.Parent.zap)

--- @class EventService
--- @server
--- @tag Service
--- Tracks all events within the game, replicating it and sending it to the Client as well.
local EventService = {}

--- @type StatsUpdatedEvent { origin: _TYPES.Character | "Server", data: { [string]: number } }
--- @within EventService
--- Describes the event when a character's stats are updated.
--- Contains the origin of the update and the updated stats data.
export type SpawnSuccessfulForCharEvent = {
	player: _TYPES.RobloxPlayerType,
	data: {
		char: _TYPES.Character,
		data: _TYPES.CharacterCombatData,
	},
}

--- @type SpawnFinishedEvent { player: _TYPES.RobloxPlayerType }
--- @within EventService
--- Describes the event when spawning has finished for a battle
--- Contains the player associated with the spawn
export type SpawnFinishedEvent = {
	player: _TYPES.RobloxPlayerType,
}

--- @type TurnCompletedEvent { player: _TYPES.RobloxPlayerType, data: { turnId: number } }
--- @within EventService
--- Describes the event when a turn is advanced in the turn order.
--- Contains the player associated with the turn advancement and the data of the turn that was advanced to.
export type TurnCompletedEvent = {
	player: _TYPES.RobloxPlayerType,
	data: {
		turnId: number, -- It's always gonna be the top of the turn queue, UNLESS stated otherwise
	},
}

--- @type TurnStartedEvent { player: _TYPES.RobloxPlayerType, data: { char: _TYPES.Character, turnId: number } }
--- @within EventService
--- Describes the event when a turn is started in the turn order.
--- Contains the player associated with the turn start and the data of the turn that was started.
export type TurnStartedEvent = {
	player: _TYPES.RobloxPlayerType,
	data: {
		char: _TYPES.Character,
		turnId: number, -- It's always gonna be the top of the turn queue, UNLESS stated otherwise
	},
}

--- @type TurnAddedEvent { turnId: number, side: _TYPES.Sides, char: _TYPES.Character, actionValue: number }
--- @within EventService
--- Describes the event when a turn is added to the turn order.
--- Contains the data of the turn that was added, such as the character and action value.
export type TurnAddedEvent = {
	turnId: number,
	side: _TYPES.Sides,
	char: _TYPES.Character,
	actionValue: number,
}

export type SuccessfulAttackEvent = {
	player: _TYPES.RobloxPlayerType,
	data: {
		char: _TYPES.Character,
		data: {
			moveName: string,
			targets: { _TYPES.Character },
		},
	},
}

--- @type ExecuteNPCAttackEvent { char: _TYPES.Character }
--- @within EventService
--- Describes the event when an NPC character executes an attack.
--- Contains the character that executed the attack.
export type ExecuteNPCAttackEvent = {
	char: _TYPES.Character,
}

--- @type Events { [string]: Signal.Signal<any> }
--- @within EventService
--- A collection of events that can be fired and listened to. Refer to the specific event types for more information.
EventService.Events = {
	SpawnSuccessfulForChar = Signal.new() :: Signal.Signal<SpawnSuccessfulForCharEvent>,
	SpawnFinished = Signal.new() :: Signal.Signal<SpawnFinishedEvent>,
	TurnCompleted = Signal.new() :: Signal.Signal<TurnCompletedEvent>,
	TurnStarted = Signal.new() :: Signal.Signal<TurnStartedEvent>,
	TurnAdded = Signal.new() :: Signal.Signal<TurnAddedEvent>,
	SuccessfulAttack = Signal.new() :: Signal.Signal<SuccessfulAttackEvent>,
	ExecuteNPCAttack = Signal.new() :: Signal.Signal<ExecuteNPCAttackEvent>,
}
--- @type ClientBlacklist { string }
--- @within EventService
--- A list of events that do not need to be replicated to clients.
EventService.ClientBlacklist = {
	"RequestSpawn",
	"TurnCompleted",
	"ExecuteNPCAttack",
}

--- @type PlayerScoped { string }
--- @within EventService
--- A list of events that should only be sent to specific players instead of all clients.
EventService.PlayerScoped = {
	"SpawnSuccessfulForChar",
	"SpawnFinished",
	"SuccessfulAttack",
	"TurnStarted",
}

--- Initializes the EventService by connecting all events to the Zap event for local players.
--- Replicates to all clients by default.
--- @within EventService
function EventService.OnStart()
	-- Create a client version for all events and fire the client version if the event is fired
	for name, event in pairs(EventService.Events) do
		if not table.find(EventService.ClientBlacklist, name) then
			if Zap[name] == nil then
				warn("EventService.OnStart() - Zap event not found for " .. name)
			end
			--
			if table.find(EventService.PlayerScoped, name) then
				event:Connect(function(eventData)
					-- Get the player from the event
					local player = eventData.player
					if not player and eventData.origin then
						local origin = eventData.origin
						player = (origin:IsA("Player") and origin)
							or (
								origin:GetAttribute("PlayerId")
								and Players:GetPlayerByUserId(origin:GetAttribute("PlayerId"))
							)
					end

					-- Fire to the player only
					if player then
						Zap[name].Fire(player, eventData.data)
					end
				end)
			else
				event:Connect(function(eventData)
					Zap[name].FireAll(eventData)
				end)
			end
		end
	end
end

return EventService
