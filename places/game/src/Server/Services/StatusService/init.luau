local rep = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local _TYPES = require(rep.Data.data_Types)
--
local Services = game:GetService("ServerScriptService").Server.Services
local CharService = require(Services.CharService)
local EventService = require(Services.EventService)
local PlayerService = require(Services.PlayerService)

local StatusService = {}
local STATUS_ATTRIBUTE = "DetailedStatuses"

local function syncStatusesAttribute(char: _TYPES.Character)
	if not char then
		return
	end

	local statuses = {}
	local charData = CharService.GetCharacterCombatData(char)
	if charData and charData.statuses then
		for id, status in pairs(charData.statuses) do
			table.insert(statuses, {
				id = id,
				name = status.info.name,
				description = status.info.description,
			})
		end
	end

	table.sort(statuses, function(left, right)
		return left.id < right.id
	end)

	char:SetAttribute(STATUS_ATTRIBUTE, HttpService:JSONEncode(statuses))
end

--- Called when the service starts
function StatusService.OnStart() end

function StatusService.SyncStatusesAttribute(char: _TYPES.Character)
	syncStatusesAttribute(char)
end

--- Adds a status to a character
--- @param char - The character to add the status to
--- @param status - The status to add
function StatusService.AddStatus(char: _TYPES.Character, id: string, status: _TYPES.Status)
	if not char or not status then
		return
	end

	local charData = CharService.GetCharacterCombatData(char)
	if not charData or not charData.statuses then
		return
	end

	-- Add the status to the character's combat data
	charData.statuses[id] = status
	syncStatusesAttribute(char)

	-- Fire an event to notify that a status has been added to the character
	EventService.Events.StatusAdded:Fire({
		player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType,
		data = {
			char = char,
			data = {
				id = id,
				status = status,
				new = true,
			},
		},
	})

	-- Handle the stat changes of the status for the character
	CharService.ApplyStatuses(char)
end

--- Removes a status from a character
--- @param char - The character to remove the status from
--- @param id - The ID of the status to remove
function StatusService.RemoveStatus(char: _TYPES.Character, id: string)
	if not char or not id then
		return
	end

	local charData = CharService.GetCharacterCombatData(char)
	if not charData or not charData.statuses then
		return
	end

	-- Find the index of the status to remove
	local status = charData.statuses[id]
	if not status then
		return
	end

	-- Remove the status from the character's combat data if found
	charData.statuses[id] = nil
	syncStatusesAttribute(char)

	-- Remove the stat changes of the status for the character
	CharService.ApplyStatuses(char)

	-- Fire an event to notify that a status has been removed from the character
	EventService.Events.StatusRemoved:Fire({
		player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType,
		data = {
			char = char,
			data = {
				id = id,
				status = status,
			},
		},
	})
end

--- Reduces the duration of a status on a character by 1
--- @param char - The character to reduce the status duration for
--- @param id - The ID of the status to reduce the duration of
function StatusService.ReduceStatusDuration(char: _TYPES.Character, id: string, status: _TYPES.Status)
	-- Check if the character and statusId are valid
	if not char or not id then
		return
	end

	-- Skip if the status does not have a duration (permanent statuses)
	if not status.data.duration then
		return
	end

	-- If the duration reaches 0 or below, remove the status from the character
	if status.data.duration - 1 <= 0 then
		StatusService.RemoveStatus(char, id)
	else
		-- Otherwise, reduce the duration by 1
		status.data.duration -= 1
	end
end

--- Reduces the duration of all statuses on a character by 1
--- @param char - The character to reduce the statuses duration for
function StatusService.ReduceStatusesDuration(char: _TYPES.Character)
	-- Get the character's combat data and check if it has statuses
	local charData = CharService.GetCharacterCombatData(char)
	if not charData or not charData.statuses then
		return
	end

	-- Loop through all the statuses of that character and decrement their duration
	for id, status in pairs(charData.statuses) do
		StatusService.ReduceStatusDuration(char, id, status)
	end
end

--- Returns the statuses of a character by id
--- @param char - The character to get the statuses of
--- @param statusId - The ID of the status to get
function StatusService.GetStatusById(char: _TYPES.Character, id: string): _TYPES.Status?
	if not char or not id then
		return nil
	end

	local charData = CharService.GetCharacterCombatData(char)
	if not charData or not charData.statuses then
		return nil
	end

	-- Find the status by id and return it
	local status = charData.statuses[id]
	if not status then
		return nil
	end

	return status
end

--- Returns the statuses of a character
--- @param char - The character to get the statuses of
function StatusService.GetStatusesOfChar(char: _TYPES.Character): { _TYPES.Status }
	if not char then
		return {}
	end

	local charData = CharService.GetCharacterCombatData(char)
	if not charData or not charData.statuses then
		return {}
	end

	-- Return the statuses as a list
	local statuses = {}
	for _, status in pairs(charData.statuses) do
		table.insert(statuses, status)
	end

	return statuses
end

return StatusService
