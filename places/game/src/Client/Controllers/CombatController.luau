local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local EffectsController = require(StarterPlayerScripts.Client.Controllers.EffectsController)
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
-- Player
local localPlayer = game:GetService("Players").LocalPlayer
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)

--- @type PlayerData {[_TYPES.RobloxPlayerType]: { selectionMark: Instance }}
--- @within PlayerController
--- A collection of character data.
local CombatData: {
	[_TYPES.RobloxPlayerType]: {
		currentCharacter: _TYPES.Character?,
		--
		enemies: { _TYPES.Character },
		primarySelectedEnemyIndex: number, -- The main enemy index (for blast attacks)
	},
} =
	{}

local CombatController = {}

--- Called when the controller starts
function CombatController.OnStart()
	local combatData = CombatData[localPlayer]

	-- Listen to spawn finished event
	Zap.SpawnFinished.On(function()
		warn("Spawn finished, combat controller received the signal!")
		-- Initialise player data
		if not CombatData[localPlayer] then
			CombatData[localPlayer] = {
				currentCharacter = nil,
				--
				enemies = workspace.Characters.Enemies:GetChildren(),
				primarySelectedEnemyIndex = 0,
			}
		end

		combatData = CombatData[localPlayer]

		-- Count the number of enemies and set the primary selected enemy index to the middle one
		-- In case of the index not being an integer, it will round down to the lower index
		local enemyCount = #combatData.enemies
		combatData.primarySelectedEnemyIndex = math.ceil(enemyCount / 2)
	end)

	-- Listen to turn started event
	Zap.TurnStarted.On(function(data)
		-- Set the current character
		combatData.currentCharacter = data.char :: _TYPES.Character
		local char = combatData.currentCharacter

		-- Use the previously selected primary enemy index, or reset to the middle enemy if the previous index is out of range
		-- (e.g., due to an enemy being defeated)
		if combatData.primarySelectedEnemyIndex > #combatData.enemies then
			combatData.primarySelectedEnemyIndex = math.ceil(#combatData.enemies / 2)
		end

		-- Use the first move of the character's combat controller as the default selected move for the turn
		local moveList = Utility.GetCharacterMoveList(char :: _TYPES.Character)
		for _, moveData in pairs(moveList) do
			-- If the move is not default, skip it
			if not moveData.isDefault then
				continue
			end

			-- Set the primary selected enemy index based on the default move's enemy selection type
			CombatController.SwitchPrimarySelectedEnemy(
				moveData.enemySelectionType,
				"set",
				combatData.primarySelectedEnemyIndex
			)
			break
		end
	end)
end

--- Handle switching primary selected enemy.
--- If mode is "set", it will set the primary selected enemy index to the specified index.
--- If mode is "increment", it will increment the primary selected enemy index by the specified index.
--- @param enemySelectionType -- The type of enemy selection (e.g., "Single", "Blast", "AoE")
--- @param mode -- Whether to set the primary selected enemy
--- @param index -- The index to set or increment by (e.g., -1 for previous, 1 for next)
function CombatController.SwitchPrimarySelectedEnemy(
	enemySelectionType: string,
	mode: "set" | "increment",
	index: number
)
	local combatData = CombatData[localPlayer]
	if not combatData.primarySelectedEnemyIndex then
		warn("No primary selected enemy index found!")
		return
	end

	local primaryIndex = combatData.primarySelectedEnemyIndex

	-- Find the index of the specified enemy in the selected enemies list
	if mode == "set" then
		primaryIndex = index
	elseif mode == "increment" then
		-- Clamp the new index within valid range
		primaryIndex = math.clamp(primaryIndex + index, 1, #combatData.enemies)
	end

	-- Get the list of selected enemies based on the selection type
	local selectedEnemies

	if enemySelectionType == "Single" then -- Select a single enemy.
		selectedEnemies = { combatData.enemies[primaryIndex] }
	elseif enemySelectionType == "Blast" then -- Select a main enemy and 2 enemies around them (if they exist).
		selectedEnemies = { combatData.enemies[primaryIndex] }
		if combatData.enemies[primaryIndex - 1] then
			table.insert(selectedEnemies, combatData.enemies[primaryIndex - 1])
		end
		if combatData.enemies[primaryIndex + 1] then
			table.insert(selectedEnemies, combatData.enemies[primaryIndex + 1])
		end
	elseif enemySelectionType == "AoE" then -- Select all enemies on the field.
		selectedEnemies = combatData.enemies
	end

	-- Notify EffectsController to update selection marks
	EffectsController.HandleTargetsSelectionMark(selectedEnemies, combatData.primarySelectedEnemyIndex)

	-- Update primary selected enemy index
	combatData.primarySelectedEnemyIndex = primaryIndex
end

--- Retrieve the current primary selected enemy index
function CombatController.GetPrimarySelectedEnemyIndex(): number
	return CombatData[localPlayer].primarySelectedEnemyIndex
end

return CombatController
