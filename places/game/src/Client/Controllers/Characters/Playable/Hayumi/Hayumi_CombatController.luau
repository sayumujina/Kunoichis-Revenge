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
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Playable.Hayumi.data_Hayumi_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Playable.Hayumi.data_Hayumi_Moves),
}
-- Attack handlers
local AttackHandlers = {
	LightningArrow = require(script.Parent.Handlers.Hayumi_LightningArrow_Handler),
	LightningRain = require(script.Parent.Handlers.Hayumi_LightningRain_Handler),
	ArcherysVision = require(script.Parent.Handlers.Hayumi_ArcherysVision_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, _TYPES.AttackData) -> number }

-- Player
local player = game.Players.LocalPlayer

local Hayumi_CombatController = {}

function Hayumi_CombatController.Init(char: _TYPES.Character)
	-- -- Initialize the character's combat data
	-- Zap.SuccessfulMove.On(function(successfulMoveData)
	-- 	local moveName = successfulMoveData.data.moveName
	-- 	local origin = successfulMoveData.origin

	-- 	-- Check if the origin is valid and matches the character
	-- 	if not origin or origin :: any ~= char then
	-- 		return
	-- 	end

	-- 	-- Check if the move is "ArcherysVision" and update the camera accordingly
	-- 	if moveName == "ArcherysVision" then
	-- 		AttackHandlers.ArcherysVision(successfulMoveData.origin, successfulMoveData.data.attackData)
	-- 	end
	-- end)
end

--- Gets the attack handlers for Hayumi
function Hayumi_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Updates the camera
--- @param char -- The character whose camera is being updated
--- @param side -- The side the camera should look at ("Playable" or "NPC")
--- @param primaryTargetIndex -- The index of the primary target to focus on
function Hayumi_CombatController.UpdateCamera(
	char: _TYPES.Character,
	side: "Playable" | "NPC",
	primaryTargetIndex: number
)
	-- Update the side the camera is supposed to look at
	CameraController.SetSideToLookAt(side)
	CameraController.LookAtSide(char, primaryTargetIndex)
end

return Hayumi_CombatController
