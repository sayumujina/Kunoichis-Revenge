local rep = game:GetService("ReplicatedStorage")
local Loader = require(rep.Shared.Modules.Loader)
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local Zap = require(StarterPlayerScripts.Client.zap)

-- Load all controllers
Loader.SpawnAll(
	Loader.LoadDescendants(Controllers, function(module)
		-- return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
		return (module.Name:match("Controller$") ~= nil)
	end),
	"OnStart"
)

-- Request the first stage to load
Zap.LoadStage.Fire({ stageId = "1-1" })
