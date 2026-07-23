local rep = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Components
local CreateTopBar = require(script.Components.Global.TopBar)
local StageSelectionMenu = require(script.Components.Stages.StageSelectionMenu)

local HUDController = {}

--- Called when the controller starts
function HUDController.OnStart()
	CreateTopBar()
end

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

	-- Initialize the stage selection menu
	StageSelectionMenu.InitStageSelectionMenu()
end

return HUDController
