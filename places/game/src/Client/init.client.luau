local rep = game:GetService("ReplicatedStorage")
local Loader = require(rep.Modules.GlobalModules.Loader)
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local HUDController = require(Controllers.HUDController)

HUDController.Init()

-- Load all controllers
Loader.SpawnAll(
	Loader.LoadDescendants(Controllers, function(module)
		-- return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
		return (module.Name:match("Controller$") ~= nil)
	end),
	"OnStart"
)
