-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local InputController = require(StarterPlayerScripts.Client.Controllers.InputController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)

local currentlySpawning = false

local SpawnController = {}

--- Called when the controller starts
function SpawnController.OnStart()
	-- Custom reset character behavior
	local resetBindable = Instance.new("BindableEvent")
	resetBindable.Event:Connect(function()
		SpawnController.Restart()
	end)

	-- Override the default reset button behavior
	local getStarterGui = game:GetService("StarterGui")
	local success
	task.spawn(function()
		while not success do
			success = pcall(getStarterGui.SetCore, getStarterGui, "ResetButtonCallback", resetBindable)
			task.wait(1)
		end
	end)
end

--- Called when the player requests a restart
function SpawnController.Restart()
	if currentlySpawning then
		return
	end

	-- Set the currentlySpawning flag to true to prevent input processing during respawn
	currentlySpawning = true

	-- Disable input processing
	InputController.ToggleInputAllowance(false)
	InputController.ToggleDetailedCombatInfoAllowance(false)

	-- Fire the restart requested event to notify other controllers that a restart has been requested
	Zap.RestartRequested.Fire()

	-- Reset the flag after spawn is finished
	Zap.SpawnFinished.On(function()
		currentlySpawning = false
	end)
end

return SpawnController
