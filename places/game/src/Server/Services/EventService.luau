--!strict
-- Core services
local Players = game:GetService("Players")
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Packages
local Signal = require(rep.Packages.Signal)

--- @class EventService
--- @server
--- @tag Service
--- Tracks all events within the game, replicating it and sending it to the Client as well.
local EventService = {}

--- @type StatsUpdatedEvent { origin: _TYPES.Character | "Server", data: { [string]: number } }
--- @within EventService
--- Describes the event when a character's stats are updated.
--- Contains the origin of the update and the updated stats data.
export type SpawnSuccessfulEvent = {
	origin: _TYPES.Character,
	side: _TYPES.Sides,
}

--- @type Events { [string]: Signal.Signal<any> }
--- @within EventService
--- A collection of events that can be fired and listened to. Refer to the specific event types for more information.
EventService.Events = {
	SpawnSuccessful = Signal.new() :: Signal.Signal<SpawnSuccessfulEvent>,
}

--- Called when the service starts
--- @within EventService
function EventService.OnStart()
	print("EventService started")
end

return EventService
