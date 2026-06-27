local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local CameraController = require(Controllers.CameraController)
local CombatController = require(Controllers.CombatController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
local Trove = require(rep.Packages.Trove)
-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Rin.data_Rin_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Rin.data_Rin_Moves),
}
-- Attack handlers
local AttackHandlers = {
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance_Handler),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> number }

-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "HiddenAssistance", -- Player needs to confirm the move twice before executing
}

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "HiddenAssistance",
	Skill = "CleansingAura",
}

local Rin_CombatController = {}

--- Gets the attack handlers for Rin
function Rin_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Updates the camera
--- @param char -- The character whose camera is being updated
--- @param side -- The side the camera should look at ("Allies" or "Enemies")
--- @param primaryTargetIndex -- The index of the primary target to focus on
function Rin_CombatController.UpdateCamera(
	char: _TYPES.Character,
	side: "Allies" | "Enemies",
	primaryTargetIndex: number
)
	-- Update the side the camera is supposed to look at
	CameraController.SetSideToLookAt(side)
	CameraController.LookAtSide(char, primaryTargetIndex)
end

return Rin_CombatController
