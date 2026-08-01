local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local CameraController = require(Controllers.CameraController)
-- Packages
local Trove = require(rep.Packages.Trove)

-- Attack handlers
local AttackHandlers = {
	WeavingBlade = require(script.Parent.Handlers.Setsuna_WeavingBlade_Handler),
	TwinBlades = require(script.Parent.Handlers.Setsuna_TwinBlades_Handler),
	BladeDance = require(script.Parent.Handlers.Setsuna_BladeDance_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, _TYPES.AttackData) -> number }

local Setsuna_CombatController = {}

--- Gets the attack handlers for Setsuna
function Setsuna_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Updates the camera
--- @param char -- The character whose camera is being updated
--- @param side -- The side the camera should look at ("Playable" or "NPC")
--- @param primaryTargetIndex -- The index of the primary target to focus on
function Setsuna_CombatController.UpdateCamera(
	char: _TYPES.Character,
	side: "Playable" | "NPC",
	primaryTargetIndex: number
)
	-- Update the side the camera is supposed to look at
	CameraController.SetSideToLookAt(side)
	CameraController.LookAtSide(char, primaryTargetIndex)
end

return Setsuna_CombatController
