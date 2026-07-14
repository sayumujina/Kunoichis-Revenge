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
-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Data.Characters.Playable.Tsuyoka.data_Tsuyoka_Info),
	Moves = require(game:GetService("ReplicatedStorage").Data.Characters.Playable.Tsuyoka.data_Tsuyoka_Moves),
}
-- Attack handlers
local AttackHandlers = {
	NoEscape = require(script.Parent.Handlers.Tsuyoka_NoEscape_Handler),
	Solidify = require(script.Parent.Handlers.Tsuyoka_Solidify_Handler),
	DestructiveCriticism = require(script.Parent.Handlers.Tsuyoka_DestructiveCriticism_Handler),
} :: { [string]: (Trove.Trove, AnimationTrack, _TYPES.Character, _TYPES.AttackData) -> number }

-- Player
local player = game.Players.LocalPlayer

local Tsuyoka_CombatController = {}

function Tsuyoka_CombatController.Init(char: _TYPES.Character) end

--- Gets the attack handlers for Tsuyoka
function Tsuyoka_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Updates the camera
--- @param char -- The character whose camera is being updated
--- @param side -- The side the camera should look at ("Playable" or "NPC")
--- @param primaryTargetIndex -- The index of the primary target to focus on
function Tsuyoka_CombatController.UpdateCamera(
	char: _TYPES.Character,
	side: "Playable" | "NPC",
	primaryTargetIndex: number
)
	-- Update the side the camera is supposed to look at
	CameraController.SetSideToLookAt(side)
	CameraController.LookAtSide(char, primaryTargetIndex)
end

return Tsuyoka_CombatController
