local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)
local Utility = require(game.ReplicatedStorage.Shared.Modules.Utility)

local QueueUIUtility = {}

--
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

--- Updates the turn queue UI based on the current state of the turn queue
function QueueUIUtility.UpdateTurnQueueUI(queue: { _TYPES.TurnEntry })
	-- Loop through the turn queue to update the layout order of all turn cards based on their current index in the queue
	warn("Updating Turn Queue UI with queue length:", #queue)
	for index, turnInLoop in pairs(queue) do
		local containerPath = playerGui.ScreenGui.PlayerUI.UI_TurnsFrame.UI_TurnCard_Container
		local loopedTurnCardList = containerPath:FindFirstChild("Turn_Cards_List_" .. turnInLoop.turnId, true)
		if not loopedTurnCardList then
			warn("Turn card list not found for turnId:", "Turn_Cards_List_" .. turnInLoop.turnId)
			continue
		end

		local mainTurnCard = loopedTurnCardList:FindFirstChild("MainTurn_Card", true)

		-- Get the action value of the turn from the turn card's and update the turn card UI
		local actionValueValue = mainTurnCard:FindFirstChild("ActionValue")
		if actionValueValue then
			actionValueValue.Value = turnInLoop.actionValue
		end

		-- Get the order value and modify it to update the layout order
		local orderValue = loopedTurnCardList:FindFirstChild("OrderValue")
		if orderValue then
			orderValue.Value = index
		end
	end
end

return QueueUIUtility
