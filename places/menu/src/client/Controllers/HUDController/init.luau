local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- Components
local c = script.Components
local Components =  {
    Global = {
        TopBarFrame = require(c.Global.TopBar_Frame),
    },
    Stages = {
        CharacterSelection = {
            CharacterSelection_Frame = require(c.Stages.CharacterSelection.CharacterSelection_Frame),
            Character_Card = require(c.Stages.CharacterSelection.Character_Card),
        },
    },
}

local HUDController = {}

--- Called when the controller starts
function HUDController.OnStart()
end

--- Initializes the HUDController
function HUDController.Init()
   	-- Create a screen GUI for the player if it doesn't exist
	if not playerGui:FindFirstChild("Global_ScreenGui", true) then
		local globalScreenGui = Instance.new("ScreenGui")
		globalScreenGui.Name = "Global_ScreenGui"
		globalScreenGui.Parent = playerGui
        globalScreenGui.ScreenInsets = Enum.ScreenInsets.None
	end

    local globalScreenGui = playerGui:FindFirstChild("Global_ScreenGui", true)
    -- Create the top bar frame and add it to the player's GUI
    local topBarFrame = Components.Global.TopBarFrame.CreateTopBar("CAMPAIGN")
    topBarFrame.Parent = globalScreenGui

    -- Create the character selection frame and add it to the player's GUI
    local characterSelectionFrame = {
        {Name = "Setsuna", Level = 20, Owned = true},
        {Name = "Hayumi", Level = 20, Owned = true},
        {Name = "Rin", Level = 20, Owned = true},
        {Name = "Tsuyoka", Level = nil, Owned = false},
    } -- TO DO: Retrieve this from the user data
    local characterSelectionFrameInstance = Components.Stages.CharacterSelection.CharacterSelection_Frame(characterSelectionFrame)
    characterSelectionFrameInstance.Parent = globalScreenGui
end

return HUDController