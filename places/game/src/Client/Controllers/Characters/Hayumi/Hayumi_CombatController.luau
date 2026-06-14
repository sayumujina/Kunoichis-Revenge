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
-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "LightningArrow", -- Player needs to confirm the move twice before executing
}

local Hayumi_CombatController = {}

--- Handles attack input from the player and sends it to the server
function Hayumi_CombatController.HandleInput(inputData)
	if inputData.action == "PreviousTarget" then
		CombatController.SwitchPrimarySelectedEnemy(
			Handlers.Moves[CharData.selectedMove].enemySelectionType,
			"increment",
			-1
		)
	elseif inputData.action == "NextTarget" then
		CombatController.SwitchPrimarySelectedEnemy(
			Handlers.Moves[CharData.selectedMove].enemySelectionType,
			"increment",
			1
		)
	elseif inputData.action == "BasicAttack" then
		if CharData.selectedMove ~= "LightningArrow" then
			CharData.selectedMove = "LightningArrow"
			CombatController.SwitchPrimarySelectedEnemy(
				Handlers.Moves[CharData.selectedMove].enemySelectionType,
				"increment",
				0
			)
			return
		end
		warn("Basic attack input received", CharData.selectedMove, game.Players.LocalPlayer.ActiveCharacter.Value)
		Zap.RequestAttack.Fire({
			char = game.Players.LocalPlayer.ActiveCharacter.Value,
			data = {
				move = "LightningArrow",
			},
		})
	end
end

return Hayumi_CombatController
