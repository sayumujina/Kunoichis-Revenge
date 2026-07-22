local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)

local HUDController = {}

local function buildUnlockedWorldData(unlockedStages)
	local unlockedWorldData = {}

	for worldId, worldInfo in pairs(unlockedStages.Worlds) do
		local unlockedStageIds = {}

		for stageId in pairs(worldInfo.Stages) do
			table.insert(unlockedStageIds, stageId)
		end

		unlockedWorldData[worldId] = {
			stages = unlockedStageIds,
		}
	end

	return unlockedWorldData
end

--- Called when the controller starts
function HUDController.OnStart() end

--- Initializes the HUDController
function HUDController.Init()
	-- Create a screen GUI for the player if it doesn't exist
	if not playerGui:FindFirstChild("Global_ScreenGui", true) then
		local globalScreenGui = Instance.new("ScreenGui")
		globalScreenGui.Name = "Global_ScreenGui"
		globalScreenGui.Parent = playerGui
		globalScreenGui.ScreenInsets = Enum.ScreenInsets.None
		globalScreenGui.DisplayOrder = 2
	end

	local globalScreenGui = playerGui:FindFirstChild("Global_ScreenGui", true)

	task.delay(2, function()
		Zap.RequestDatastoreData.Fire()

		local receiveDataConnection
		receiveDataConnection = Zap.DatastoreDataResponse.On(function(data)
			local unlockedWorldData = buildUnlockedWorldData(data.UnlockedStages)

			warn("Received unlocked world data: ", unlockedWorldData)
			local OpenStageSelectionMenu = require(script.Components.Stages.OpenStageSelectionMenu)
			OpenStageSelectionMenu(unlockedWorldData, data.OwnedCharacters)

			-- Disconnect the connections after receiving the data
			receiveDataConnection()
		end)
	end)
end

return HUDController
