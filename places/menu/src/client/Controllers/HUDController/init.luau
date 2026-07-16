local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- Components
local c = script.Components
local Components = {
	Global = {
		TopBarFrame = require(c.Global.TopBar_Frame),
	},
	Stages = {
		CharacterSelection = {
			CharacterSelectionFrame = require(c.Stages.CharacterSelection.CharacterSelection_Frame),
			CharacterCard = require(c.Stages.CharacterSelection.Character_Card),
		},
		StageSelection = {
			StageSelectionFrame = require(c.Stages.StageSelection.StageSelection_Frame),
			StageCard = require(c.Stages.StageSelection.Stage_Card),
		},
	},
}

local HUDController = {}

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

	-- Create the top bar frame and add it to the player's GUI
	local topBarFrame = Components.Global.TopBarFrame.CreateTopBar("CAMPAIGN")
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
	local stageSelectionFrame = Components.Stages.StageSelection.StageSelectionFrame.CreateWorldList()
	stageSelectionFrame.Parent = stageSelectionGui

	-- Create the character selection frame and add it to the player's GUI
	local characterSelectionFrame = {
		{ Name = "Setsuna", Level = 20, Owned = true },
		{ Name = "Hayumi", Level = 20, Owned = true },
		{ Name = "Rin", Level = 20, Owned = true },
		{ Name = "Tsuyoka", Level = nil, Owned = false },
	} -- TO DO: Retrieve this from the user data
	local characterSelectionFrameInstance =
		Components.Stages.CharacterSelection.CharacterSelectionFrame(characterSelectionFrame)
	characterSelectionFrameInstance.Parent = stageSelectionGui
end

return HUDController
