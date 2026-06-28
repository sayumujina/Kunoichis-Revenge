-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)
local AnimationService = require(Services.AnimationService)

--- @class CollapsedStatus
--- @server
--- @tag Status
--- Handles collapsed-type status effects
local CollapsedStatus = {}

--- Handles collapsed status application
--- Applies collapsed effects to characters and manages their state based on collapsed status presence.
--- @within CollapsedStatus
--- @param event -- The `StatusAddedEvent` event.
--- @private
local function collapsedStatusAdded(event: EventService.StatusAddedEvent)
	--
	warn("Collapsed status added to character:", event.char, "Status ID:", event.data.id)
	if event.data.id ~= "Collapsed" then
		return
	end

	-- Play the collapse animation for the target character
	AnimationService.Play(event.char, "Collapsed")
end

--- Handles collapsed status removal
--- @within CollapsedStatus
--- @param event -- The `StatusRemovedEvent` event.
--- @private
local function collapsedStatusRemoved(event: EventService.StatusRemovedEvent)
	warn("Collapsed status removed from character:", event.char, "Status ID:", event.data.id)
	if event.data.id ~= "Collapsed" then
		return
	end

	-- Play the wakeup animation for the target character
	AnimationService.Stop(event.char, "Collapsed")
end

--- Initializes the Collapsed status functionality by listening to status events.
--- @within CollapsedStatus
function CollapsedStatus.OnStart()
	-- Listen for statuses being added
	EventService.Events.StatusAdded:Connect(collapsedStatusAdded)
	-- Listen for statuses being removed
	EventService.Events.StatusRemoved:Connect(collapsedStatusRemoved)
end

return CollapsedStatus
