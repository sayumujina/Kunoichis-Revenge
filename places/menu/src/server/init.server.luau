local rep = game:GetService("ReplicatedStorage")
local Server = game:GetService("ServerScriptService").Server
local Loader = require(rep.Shared.Modules.Loader)

-- Load all services
Loader.SpawnAll(
	Loader.LoadDescendants(Server, function(module)
		return (module.Name:match("Service$") ~= nil or module.Name:match("Status$") ~= nil)
	end),
	"OnStart"
)
