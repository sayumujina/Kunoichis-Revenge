local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Characters = require(ReplicatedStorage.Data.data_Characters)
-- Controllers
local HUDController = StarterPlayerScripts.Client.Controllers.HUDController
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Components
local CreateTopInfoBar = require(HUDController.Components.Global.TopInfoBar_Frame)
local CreateWorldList = require(HUDController.Components.Stages.StageSelection.StageSelection_Frame)
local CharacterSelectionFrame = require(HUDController.Components.Stages.CharacterSelection.CharacterSelection_Frame)

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

--- Creates the stage selection menu UI with the given unlocked world data and owned characters.
--- @param unlockedWorldData -- A table containing the unlocked world data.
--- @param ownedCharacters -- A table containing the owned characters data.
local function createStageSelectionMenu(unlockedWorldData: { [string]: { stages: { string } } }, ownedCharacters)
	local playerGui = game.Players.LocalPlayer.PlayerGui

	if not playerGui:FindFirstChild("StageSelection_ScreenGui", true) then
		local stageSelectionGui = Instance.new("ScreenGui")
		stageSelectionGui.Name = "StageSelection_ScreenGui"
		stageSelectionGui.Parent = playerGui
		stageSelectionGui.ScreenInsets = Enum.ScreenInsets.None
		stageSelectionGui.DisplayOrder = 1
		stageSelectionGui.Enabled = false
	end

	local stageSelectionGui = playerGui:FindFirstChild("StageSelection_ScreenGui", true)
	-- Create the top bar frame and add it to the stage selection GUI
	CreateTopInfoBar.CreateTopInfoBar("CAMPAIGN").Parent = stageSelectionGui

	local function createBackground()
		local background = Instance.new("Frame")
		background.Name = "BG"
		background.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		background.BackgroundTransparency = 0.1
		background.Size = UDim2.fromScale(1, 1)
		background.Parent = stageSelectionGui
		background.ZIndex = 0

		return background
	end
	createBackground()

	-- Create the stage selection frame and add it to the player's GUI
	local stageSelectionFrame = CreateWorldList.CreateWorldList(unlockedWorldData)
	stageSelectionFrame.Parent = stageSelectionGui

	-- Create the character selection frame and add it to the player's GUI
	local charactersInfo = {}

	for _, charName in Characters do
		local ownedCharacter = ownedCharacters[charName]

		table.insert(charactersInfo, {
			Name = charName,
			Level = if ownedCharacter then ownedCharacter.Level else nil,
			Owned = ownedCharacter ~= nil,
		})
	end

	local charIndexLookup = {}
	for i, charName in Characters do
		charIndexLookup[charName] = i
	end

	-- Sort using the lookup - O(n log n)
	table.sort(charactersInfo, function(a, b)
		if a.Owned == b.Owned then
			return charIndexLookup[a.Name] < charIndexLookup[b.Name]
		end
		return a.Owned
	end)

	warn(debug.traceback())
	local characterSelectionFrame = CharacterSelectionFrame.CreateCharacterSelectionFrame(charactersInfo)
	characterSelectionFrame.Parent = stageSelectionGui
end

local function toggleStageSelectionMenu(visible: boolean)
	local playerGui = game.Players.LocalPlayer.PlayerGui
	local stageSelectionGui = playerGui:FindFirstChild("StageSelection_ScreenGui", true)
	if stageSelectionGui then
		stageSelectionGui.Enabled = visible
	end
end

local function init()
	Zap.RequestPlayerstoreData.Fire()

	local receiveDataConnection
	receiveDataConnection = Zap.PlayerstoreDataResponse.On(function(data)
		local unlockedWorldData = buildUnlockedWorldData(data.UnlockedStages)

		local playerGui = game.Players.LocalPlayer.PlayerGui
		local stageSelectionGui = playerGui:FindFirstChild("StageSelection_ScreenGui", true)
		if stageSelectionGui then
			warn("Destroying stage selection menu due to datastore change")
			stageSelectionGui:Destroy()
		end

		createStageSelectionMenu(unlockedWorldData, data.OwnedCharacters)

		-- Disconnect the connections after receiving the data
		receiveDataConnection()
	end)

	-- If datastore changed, destroy the stage selection menu and re-create it with the updated data
	Zap.PlayerDatastoreChanged.On(function(data)
		local unlockedWorldData = buildUnlockedWorldData(data.UnlockedStages)
		toggleStageSelectionMenu(false)
		local playerGui = game.Players.LocalPlayer.PlayerGui
		local stageSelectionGui = playerGui:FindFirstChild("StageSelection_ScreenGui", true)
		if stageSelectionGui then
			warn("Destroying stage selection menu due to datastore change")
			stageSelectionGui:Destroy()
		end
		createStageSelectionMenu(unlockedWorldData, data.OwnedCharacters)
	end)
end

return {
	CreateStageSelectionMenu = createStageSelectionMenu,
	ToggleStageSelectionMenu = toggleStageSelectionMenu,
	InitStageSelectionMenu = init,
}
