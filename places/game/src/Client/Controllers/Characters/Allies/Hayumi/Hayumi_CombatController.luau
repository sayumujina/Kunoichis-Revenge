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
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Hayumi.data_Hayumi_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Hayumi.data_Hayumi_Moves),
}
-- Attack handlers
local AttackHandlers = {
	LightningArrow = require(script.Parent.Handlers.Hayumi_LightningArrow_Handler),
	LightningRain = require(script.Parent.Handlers.Hayumi_LightningRain_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> number }

-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "LightningArrow", -- Player needs to confirm the move twice before executing
}

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "LightningArrow",
	Skill = "LightningRain",
}

local Hayumi_CombatController = {}

--- Gets the attack handlers for Hayumi
function Hayumi_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Updates the camera
--- @param char -- The character whose camera is being updated
--- @param side -- The side the camera should look at ("Allies" or "Enemies")
--- @param primaryTargetIndex -- The index of the primary target to focus on
function Hayumi_CombatController.UpdateCamera(
	char: _TYPES.Character,
	side: "Allies" | "Enemies",
	primaryTargetIndex: number
)
	-- Update the side the camera is supposed to look at
	CameraController.SetSideToLookAt(side)
	CameraController.LookAtSide(char, primaryTargetIndex)
end

return Hayumi_CombatController
