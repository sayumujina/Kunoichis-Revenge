local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Characters = require(ReplicatedStorage.Data.data_Characters)
-- Controllers
local HUDController = StarterPlayerScripts.Client.Controllers.HUDController
-- Components
local CreateTopBar = require(HUDController.Components.Global.TopBar_Frame)
local CreateWorldList = require(HUDController.Components.Stages.StageSelection.StageSelection_Frame)
local CreateCharacterSelectionFrame =
	require(HUDController.Components.Stages.CharacterSelection.CharacterSelection_Frame)

return function(unlockedWorldData: { [string]: { stages: { string } } }, ownedCharacters)
	local playerGui = game.Players.LocalPlayer.PlayerGui
	local globalScreenGui = playerGui:FindFirstChild("Global_ScreenGui", true)

	-- Create the top bar frame and add it to the player's GUI
	local topBarFrame = CreateTopBar.CreateTopBar("CAMPAIGN")
	topBarFrame.Parent = globalScreenGui

	if not playerGui:FindFirstChild("StageSelection_ScreenGui", true) then
		local stageSelectionGui = Instance.new("ScreenGui")
		stageSelectionGui.Name = "StageSelection_ScreenGui"
		stageSelectionGui.Parent = playerGui
		stageSelectionGui.ScreenInsets = Enum.ScreenInsets.None
		stageSelectionGui.DisplayOrder = 1
	end

	local stageSelectionGui = playerGui:FindFirstChild("StageSelection_ScreenGui", true)

	local function createBackground()
		local background = Instance.new("Frame")
		background.Name = "BG"
		background.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		background.Size = UDim2.fromScale(1, 1)
		background.Parent = globalScreenGui

		return background
	end
	createBackground().Parent = stageSelectionGui

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

	local characterSelectionFrame = CreateCharacterSelectionFrame(charactersInfo)
	characterSelectionFrame.Parent = stageSelectionGui
end
