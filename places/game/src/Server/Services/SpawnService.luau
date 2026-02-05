-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local rep = game:GetService("ReplicatedStorage")
local Utility = require(ServerScriptService.Server.Helpers.Utility)
-- Packages
local Zap = require(game.ServerScriptService.Server.zap)

local _TYPES = require(rep.Shared.data_Types)

--- @class SpawnService
--- @server
--- @tag Service
local SpawnService = {}

--- Called when the service starts
function SpawnService.OnStart()
	print("SpawnService started")
end

--- Spawns a player into the game=
function SpawnService.SpawnCharacter(char: _TYPES.Character, cframe: CFrame, ally: boolean?)
	-- Spawn from above the baseplate
	-- Rotate character to face away from spawn point if ally
	if ally then
		warn("Spawning ally character")
		char:PivotTo(cframe * CFrame.Angles(0, math.rad(180), 0))
	else
		char:PivotTo(cframe)
	end
end

return SpawnService
