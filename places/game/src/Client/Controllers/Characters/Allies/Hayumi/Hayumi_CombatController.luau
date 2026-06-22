local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
-- Controllers
local CombatController = require(StarterPlayerScripts.Client.Controllers.CombatController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Hayumi.data_Hayumi_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Hayumi.data_Hayumi_Moves),
}
-- Attack handlers
local AttackHandlers = {
	LightningArrow = require(script.Parent.Handlers.Hayumi_LightningArrow_Handler),
	LightningRain = require(script.Parent.Handlers.Hayumi_LightningRain_Handler),
} :: { [string]: (AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> () }

-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "LightningArrow", -- Player needs to confirm the move twice before executing
}

local Hayumi_CombatController = {}

--- Gets the attack handlers for Hayumi
function Hayumi_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Handles attack input from the player and sends it to the server
function Hayumi_CombatController.HandleInput(inputData)
	if inputData.action == "PreviousTarget" then
		CombatController.SwitchPrimarySelectedTarget(
			Handlers.Moves[CharData.selectedMove].targetSelectionType,
			"increment",
			-1
		)
	elseif inputData.action == "NextTarget" then
		CombatController.SwitchPrimarySelectedTarget(
			Handlers.Moves[CharData.selectedMove].targetSelectionType,
			"increment",
			1
		)
	else
		if inputData.action == "BasicAttack" then
			if CharData.selectedMove ~= "LightningArrow" then
				CharData.selectedMove = "LightningArrow"

				-- Set the selected side based on the move's selected side
				CombatController.SetSelectedSide(Handlers.Moves[CharData.selectedMove].selectedSide)
				CombatController.SwitchPrimarySelectedTarget(
					Handlers.Moves[CharData.selectedMove].targetSelectionType,
					"increment",
					0
				)
				return
			end
		elseif inputData.action == "Skill" then
			if CharData.selectedMove ~= "LightningRain" then
				CharData.selectedMove = "LightningRain"

				-- Set the selected side based on the move's selected side
				CombatController.SetSelectedSide(Handlers.Moves[CharData.selectedMove].selectedSide)
				CombatController.SwitchPrimarySelectedTarget(
					Handlers.Moves[CharData.selectedMove].targetSelectionType,
					"increment",
					0
				)
				return
			end
		end
		Zap.RequestAttack.Fire({
			char = game.Players.LocalPlayer.ActiveCharacter.Value,
			data = {
				move = CharData.selectedMove,
				primaryTargetIndex = CombatController.GetPrimarySelectedTargetIndex(),
			},
		})
	end
end

return Hayumi_CombatController
