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
		data: {
			side: _TYPES.Sides,
		},
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
	turnId: number, -- It's always gonna be the top of the turn queue, UNLESS stated otherwise
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

--- @type ExtraActionAddedEvent { currentTurnId: number, extraActionId: number, char: _TYPES.Character, side: _TYPES.Sides, action: string, isProcessingAttack: boolean }
--- @within EventService
--- Describes the event when an extra action is added to the turn order.
--- Contains the data of the current turn and the character that was added for an extra action.
export type ExtraActionAddedEvent = {
	currentTurnId: number,
	--
	extraActionId: number,
	char: _TYPES.Character,
	side: _TYPES.Sides,
	action: string,
	isProcessingAttack: boolean,
}

--- @type ExtraActionRemovedEvent { extraActionId: number }
--- @within EventService
--- Describes the event when an extra action is removed from the turn order.
--- Contains the data of the current turn and the character that was removed from the extra action queue.
export type ExtraActionRemovedEvent = {
	extraActionId: number,
}

--- @type ExtraActionCompletedEvent { extraActionId: number }
--- @within EventService
--- Describes the event when an extra action is completed in the turn order.
--- Contains the data of the current turn and the character that completed their extra action.
export type ExtraActionCompletedEvent = {
	extraActionId: number,
}

--- @type RealStatsChangedEvent { char: _TYPES.Character, data: { [string]: number } }
--- @within EventService
--- Describes the event when a character's real stats have changed.
--- Contains the player associated with the stat change, the character whose real stats changed, and the updated real stats data.
export type RealStatsChangedEvent = {
	char: _TYPES.Character,
	data: { [string]: number },
}

--- @type CurrentStatsChangedEvent { char: _TYPES.Character, data: { [string]: number } }
--- @within EventService
--- Describes the event when a character's current stats have changed.
--- Contains the player associated with the stat change, the character whose current stats changed, and the updated current stats data.
export type CurrentStatsChangedEvent = {
	char: _TYPES.Character,
	data: { [string]: number },
}

--- @type PlayerBaseStatsChangedEvent { player: _TYPES.RobloxPlayerType, data: { data: { [string]: number } } }
--- @within EventService
--- Describes the event when a character's base stats have changed.
--- Contains the player associated with the stat change, the character whose base stats changed, and the updated base stats data.
export type PlayerBaseStatsChangedEvent = {
	player: _TYPES.RobloxPlayerType,
	data: {
		data: { [string]: number },
	},
}

--- @type PlayerCurrentStatsChangedEvent { player: _TYPES.RobloxPlayerType, data: { data: { [string]: number } } }
--- @within EventService
--- Describes the event when a character's current stats have changed.
--- Contains the player associated with the stat change, the character whose current stats changed, and the updated current stats data.
export type PlayerCurrentStatsChangedEvent = {
	player: _TYPES.RobloxPlayerType,
	data: {
		data: { [string]: number },
	},
}

--- @type SuccessfulMoveEvent { origin: _TYPES.Character, data: { moveName: string, attackData: _TYPES.AttackData } }
--- @within EventService
--- Describes the event when a move is successfully executed by a character.
--- Contains the origin of the move, the name of the move, and the associated attack data.
export type SuccessfulMoveEvent = {
	origin: _TYPES.Character,
	data: {
		moveName: string,
		attackData: _TYPES.AttackData,
	},
}

--- @type StatusAddedEvent<T> { char: _TYPES.Character, data: { id: string, status: _TYPES.Status, new: boolean } }
--- @within EventService
--- Describes the event for when a status effect is added or removed from a character.
--- Contains the origin of the event, the target character, the status ID, status data, and whether it is a new application.
export type StatusAddedEvent = {
	char: _TYPES.Character,
	data: {
		id: string,
		status: _TYPES.Status,
		new: boolean,
	},
}

--- @type StatusRemovedEvent<T> { char: _TYPES.Character, data: { id: string, status: _TYPES.Status } }
--- @within EventService
--- Describes the event for when a status effect is removed from a character.
--- Contains the origin of the event, the target character, the status ID, and status data.
export type StatusRemovedEvent = {
	char: _TYPES.Character,
	data: {
		id: string,
		status: _TYPES.Status,
	},
}

--- @type ActionAdvanceEvent { char: _TYPES.Character, advancedBy: number }
--- @within EventService
--- Describes the event for when a character's action value is advanced.
--- Contains the character whose action value is advanced and the amount by which it is advanced.
export type ActionAdvanceEvent = {
	char: _TYPES.Character,
	advancedBy: number,
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
	ExtraActionAdded = Signal.new() :: Signal.Signal<ExtraActionAddedEvent>,
	ExtraActionRemoved = Signal.new() :: Signal.Signal<ExtraActionRemovedEvent>,
	ExtraActionCompleted = Signal.new() :: Signal.Signal<ExtraActionCompletedEvent>,
	RealStatsChanged = Signal.new() :: Signal.Signal<RealStatsChangedEvent>,
	CurrentStatsChanged = Signal.new() :: Signal.Signal<CurrentStatsChangedEvent>,
	PlayerBaseStatsChanged = Signal.new() :: Signal.Signal<PlayerBaseStatsChangedEvent>,
	PlayerCurrentStatsChanged = Signal.new() :: Signal.Signal<PlayerCurrentStatsChangedEvent>,
	SuccessfulMove = Signal.new() :: Signal.Signal<SuccessfulMoveEvent>,
	StatusAdded = Signal.new() :: Signal.Signal<StatusAddedEvent>,
	StatusRemoved = Signal.new() :: Signal.Signal<StatusRemovedEvent>,
	ActionAdvance = Signal.new() :: Signal.Signal<ActionAdvanceEvent>,
}
--- @type ClientBlacklist { string }
--- @within EventService
--- A list of events that do not need to be replicated to clients.
EventService.ClientBlacklist = {
	"RequestSpawn",
	"StatusAdded",
	"StatusRemoved",
}

--- @type PlayerScoped { string }
--- @within EventService
--- A list of events that should only be sent to specific players instead of all clients.
EventService.PlayerScoped = {
	"SpawnSuccessfulForChar",
	"SpawnFinished",
	"TurnStarted",
	"PlayerBaseStatsChanged",
	"PlayerCurrentStatsChanged",
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
