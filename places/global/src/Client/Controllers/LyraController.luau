-- Core services
-- Remotes
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)

--- @class LyraController
--- @tag Controller
--- @client
--- Manages core Lyra framework functionalities on the client side.

local LyraController = {}
-- This should only be used for not-so-dangerous data, like unlocked stages, unlocked characters, etc. For sensitive data, use the server-side LyraService.
local LocalData = {
	stagesData = {},
} :: {
	stagesData: {
		[string]: {
			[string]: {
				stageCleared: boolean,
				clearedExtraObjectives: { string },
			},
		},
	},
}

LyraController.Loaded = false

local function storeStagesData(playerData)
	if not playerData or not playerData.UnlockedStages or not playerData.UnlockedStages.Worlds then
		return
	end

	LocalData.stagesData = {}

	for worldId, worldData in pairs(playerData.UnlockedStages.Worlds) do
		local worldStagesData = {}
		for stageId, stageData in pairs(worldData.Stages) do
			worldStagesData[stageId] = {
				stageCleared = stageData.Cleared,
				clearedExtraObjectives = stageData.ClearedExtraObjectives,
			}
		end
		LocalData.stagesData[worldId] = worldStagesData
	end
end

--- @function LyraController.OnStart
--- @within LyraController
--- Initializes the Lyra controller and connects event listeners.
function LyraController.OnStart()
	Zap.PlayerDatastoreLoaded.On(function(event)
		print("LyraController: Loaded player datastore", event)
		LyraController.Loaded = true
		storeStagesData(event)
	end)

	Zap.RequestPlayerstoreData.Fire()
	Zap.PlayerstoreDataResponse.On(function(data)
		storeStagesData(data)
	end)

	Zap.PlayerDatastoreChanged.On(function(data)
		storeStagesData(data)
	end)
end

--- Get the locally stored data
function LyraController.GetLocalData()
	return LocalData
end

return LyraController
