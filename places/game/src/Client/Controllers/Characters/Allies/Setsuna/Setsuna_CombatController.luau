local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local CameraController = require(Controllers.CameraController)
-- Packages
local Trove = require(rep.Packages.Trove)

-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Moves),
}

-- Attack handlers
local AttackHandlers = {
	WeavingBlade = require(script.Parent.Handlers.Setsuna_WeavingBlade_Handler),
	TwinBlades = require(script.Parent.Handlers.Setsuna_TwinBlades_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> number }

-- Player
local player = game.Players.LocalPlayer

local Setsuna_CombatController = {}

--- Gets the attack handlers for Setsuna
function Setsuna_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Updates the camera
--- @param char -- The character whose camera is being updated
--- @param side -- The side the camera should look at ("Allies" or "Enemies")
--- @param primaryTargetIndex -- The index of the primary target to focus on
function Setsuna_CombatController.UpdateCamera(
	char: _TYPES.Character,
	side: "Allies" | "Enemies",
	primaryTargetIndex: number
)
	-- Update the side the camera is supposed to look at
	CameraController.SetSideToLookAt(side)
	CameraController.LookAtSide(char, primaryTargetIndex)
end

return Setsuna_CombatController
