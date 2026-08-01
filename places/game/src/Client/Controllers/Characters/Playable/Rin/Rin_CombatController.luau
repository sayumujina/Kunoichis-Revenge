local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local CameraController = require(Controllers.CameraController)
local CombatController = require(Controllers.CombatController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
local Trove = require(rep.Packages.Trove)

-- Attack handlers
local AttackHandlers = {
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance_Handler),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura_Handler),
	VanguardsCall = require(script.Parent.Handlers.Rin_VanguardsCall_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, _TYPES.AttackData) -> number }

local Rin_CombatController = {}

--- Gets the attack handlers for Rin
function Rin_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Updates the camera
--- @param char -- The character whose camera is being updated
--- @param side -- The side the camera should look at ("Playable" or "NPC")
--- @param primaryTargetIndex -- The index of the primary target to focus on
function Rin_CombatController.UpdateCamera(char: _TYPES.Character, side: "Playable" | "NPC", primaryTargetIndex: number)
	-- Update the side the camera is supposed to look at
	CameraController.SetSideToLookAt(side)
	CameraController.LookAtSide(char, primaryTargetIndex)
end

return Rin_CombatController
