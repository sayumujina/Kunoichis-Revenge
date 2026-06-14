local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
-- Controllers
local CombatController = require(StarterPlayerScripts.Client.Controllers.CombatController)
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
local Handlers = {
	Info = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Info),
	Moves = require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Allies.Setsuna.data_Setsuna_Moves),
}
-- Player
local player = game.Players.LocalPlayer

-- Character data
local CharData = {
	selectedMove = "WeavingBlade", -- Player needs to confirm the move twice before executing
}

local Setsuna_CombatController = {}

--- Handles attack input from the player and sends it to the server
function Setsuna_CombatController.HandleInput(inputData)
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
		if CharData.selectedMove ~= "WeavingBlade" then
			CharData.selectedMove = "WeavingBlade"
			CombatController.SwitchPrimarySelectedEnemy(
				Handlers.Moves[CharData.selectedMove].enemySelectionType,
				"increment",
				0
			)
			return
		end
		Zap.RequestAttack.Fire({
			char = player.ActiveCharacter.Value,
			data = {
				move = "WeavingBlade",
			},
		})
	end
end

return Setsuna_CombatController
