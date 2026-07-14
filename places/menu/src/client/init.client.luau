local rep = game:GetService("ReplicatedStorage")
local Loader = require(rep.Modules.GlobalModules.Loader)
local MenuClient = script
local Controllers = MenuClient.Controllers
local HUDController = require(Controllers.HUDController)
--

HUDController.Init()

-- Load all controllers
Loader.SpawnAll(
	Loader.LoadDescendants(Controllers, function(module)
		-- return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
		return (module.Name:match("Controller$") ~= nil)
	end),
	"OnStart"
)

-- Request the first stage to load
-- Zap.LoadStage.Fire({ stageId = "1-1" })
