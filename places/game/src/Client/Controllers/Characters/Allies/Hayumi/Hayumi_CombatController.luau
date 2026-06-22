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

--- Handles attack input from the player and sends it to the server
function Hayumi_CombatController.HandleInput(inputData)
	local action = inputData.action
	local targetSelectionType = Handlers.Moves[CharData.selectedMove].targetSelectionType

	-- Handle target selection actions
	if action == "PreviousTarget" then
		CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", -1)
		return
	elseif action == "NextTarget" then
		CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", 1)
		return
	end

	-- Handle move selection actions
	local mappedMove = ActionToMoveMap[action]
	if mappedMove and CharData.selectedMove ~= mappedMove then
		CharData.selectedMove = mappedMove

		-- Set the selected side based on the move's selected side
		CombatController.SetSelectedSide(Handlers.Moves[CharData.selectedMove].selectedSide)
		CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", 0)
		return
	end

	-- Execute the attack
	Zap.RequestAttack.Fire({
		char = player.ActiveCharacter.Value,
		data = {
			move = CharData.selectedMove,
			primaryTargetIndex = CombatController.GetPrimarySelectedTargetIndex(),
		},
	})
end

return Hayumi_CombatController
