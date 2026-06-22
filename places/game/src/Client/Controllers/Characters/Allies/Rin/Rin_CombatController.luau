local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
-- Controllers
local CombatController = require(StarterPlayerScripts.Client.Controllers.CombatController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Handlers
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Rin.data_Rin_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Rin.data_Rin_Moves),
}
-- Attack handlers
local AttackHandlers = {
	HiddenAssistance = require(script.Parent.Handlers.Rin_HiddenAssistance_Handler),
	CleansingAura = require(script.Parent.Handlers.Rin_CleansingAura_Handler),
} :: { [string]: (AnimationTrack, _TYPES.Character, { _TYPES.Character }) -> () }

-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "HiddenAssistance", -- Player needs to confirm the move twice before executing
}

local Rin_CombatController = {}

--- Gets the attack handlers for Rin
function Rin_CombatController.GetAttackHandlers()
	return AttackHandlers
end

--- Handles attack input from the player and sends it to the server
function Rin_CombatController.HandleInput(inputData)
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
	elseif inputData.action == "BasicAttack" then
		if CharData.selectedMove ~= "HiddenAssistance" then
			CharData.selectedMove = "HiddenAssistance"

			-- Set the selected side based on the move's selected side
			CombatController.SetSelectedSide(Handlers.Moves[CharData.selectedMove].selectedSide)
			CombatController.SwitchPrimarySelectedTarget(
				Handlers.Moves[CharData.selectedMove].targetSelectionType,
				"increment",
				0
			)
			return
		end
		Zap.RequestAttack.Fire({
			char = game.Players.LocalPlayer.ActiveCharacter.Value,
			data = {
				move = "HiddenAssistance",
				primaryTargetIndex = CombatController.GetPrimarySelectedTargetIndex(),
			},
		})
	else
		if inputData.action == "Skill" then
			if CharData.selectedMove ~= "CleansingAura" then
				CharData.selectedMove = "CleansingAura"

				-- Set the selected side based on the move's selected side
				CombatController.SetSelectedSide(Handlers.Moves[CharData.selectedMove].selectedSide)
				CombatController.SwitchPrimarySelectedTarget(
					Handlers.Moves[CharData.selectedMove].targetSelectionType,
					"increment",
					0
				)
				return
			end
		elseif inputData.action == "BasicAttack" then
			if CharData.selectedMove ~= "HiddenAssistance" then
				CharData.selectedMove = "HiddenAssistance"

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

return Rin_CombatController
