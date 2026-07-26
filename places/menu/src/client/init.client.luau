local rep = game:GetService("ReplicatedStorage")
local Loader = require(rep.Modules.GlobalModules.Loader)
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local GlobalControllers = StarterPlayerScripts.Client.GlobalControllers
local HUDController = require(Controllers.HUDController)
local SoundController = require(GlobalControllers.SoundController)
--

HUDController.Init()
SoundController.Init()

-- Custom reset character behavior
local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:Connect(function()
	return
end)

-- Override the default reset button behavior
local getStarterGui = game:GetService("StarterGui")
local success
task.spawn(function()
	while not success do
		-- Disable the default reset button behavior by setting a no-op function as the callback
		success = pcall(getStarterGui.SetCore, getStarterGui, "ResetButtonCallback", resetBindable)
		task.wait(1)
	end
end)

-- Load all controllers
Loader.SpawnAll(
	Loader.LoadDescendants(Controllers, function(module)
		-- return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
		return (module.Name:match("Controller$") ~= nil)
	end),
	"OnStart"
)
Loader.SpawnAll(
	Loader.LoadDescendants(GlobalControllers, function(module)
		-- return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
		return (module.Name:match("Controller$") ~= nil)
	end),
	"OnStart"
)

-- Request the first stage to load
-- Zap.LoadStage.Fire({ stageId = "1-1" })
