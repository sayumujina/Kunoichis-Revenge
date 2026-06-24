local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local EffectsController = require(StarterPlayerScripts.Client.Controllers.EffectsController)
local HUDController = require(StarterPlayerScripts.Client.Controllers.HUDController)
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
		allies: { _TYPES.Character },
		primarySelectedTargetIndex: number, -- The main enemy index (for blast attacks)
		selectedSide: "Allies" | "Enemies", -- The side that the player is currently selecting targets from
	},
} =
	{}

local CombatController = {}

--- Called when the controller starts
function CombatController.OnStart()
	local combatData = CombatData[localPlayer]

	-- Listens to sucessful move events
	Zap.SuccessfulMove.On(function(successfulMoveData)
		local char = successfulMoveData.char :: _TYPES.Character
		-- if char ~= CombatController.GetCurrentCharacter() :: any then
		-- 	return
		-- end

		-- Disable selection marks after the attack is executed
		EffectsController.DisableAllSelectionMark()

		-- Call the specific attack handler for the move that was executed
		local moveName = successfulMoveData.data.moveName
		local animationIdToCompare = Utility.GetPlayingAttackAnimationId(char, moveName .. "_Execute")
		for _, animationTrack in pairs(char.Humanoid.Animator:GetPlayingAnimationTracks()) do
			-- Check if the animation track's AnimationId matches the expected animation ID for the move
			if animationTrack.Animation.AnimationId ~= animationIdToCompare then
				continue
			end

			-- If it matches, call the corresponding attack handler
			local controller = Utility.GetCharacterCombatController(char)
			local attackHandlers = controller and require(controller).GetAttackHandlers()
			attackHandlers[moveName](
				animationTrack,
				successfulMoveData.char :: _TYPES.Character,
				successfulMoveData.data.targets :: { _TYPES.Character }
			)
			break
		end
	end)

	-- Listen to spawn finished event
	Zap.SpawnFinished.On(function()
		warn("Spawn finished, combat controller received the signal!")
		-- Initialise player data
		if not CombatData[localPlayer] then
			CombatData[localPlayer] = {
				currentCharacter = nil,
				--
				enemies = workspace.Characters.Enemies:GetChildren(),
				allies = workspace.Characters.Allies:GetChildren(),
				primarySelectedTargetIndex = 0,
				selectedSide = "Enemies",
			}
		end

		combatData = CombatData[localPlayer]

		-- Count the number of enemies and set the primary selected enemy index to the middle one
		-- In case of the index not being an integer, it will round down to the lower index
		local enemyCount = #combatData.enemies
		combatData.primarySelectedTargetIndex = math.ceil(enemyCount / 2)
	end)

	-- Listen to turn started event
	Zap.TurnStarted.On(function(data)
		-- Set the current character
		combatData.currentCharacter = data.char :: _TYPES.Character
		local char = combatData.currentCharacter

		if not char then
			warn("No current character found!")
			return
		end

		-- Use the previously selected primary enemy index, or reset to the middle enemy if the previous index is out of range
		-- (e.g., due to an enemy being defeated)
		if combatData.primarySelectedTargetIndex > #combatData.enemies then
			combatData.primarySelectedTargetIndex = math.ceil(#combatData.enemies / 2)
		end

		-- Use the first move of the character's combat controller as the default selected move for the turn
		local moveList = Utility.GetCharacterMoveList(char :: _TYPES.Character)
		for _, moveData in pairs(moveList) do
			-- If the move is not default, skip it
			if not moveData.isDefault then
				continue
			end

			-- Set the selected side based on the default move's selected side
			CombatController.SetSelectedSide(moveData.selectedSide)

			-- Set the primary selected enemy index based on the default move's enemy selection type
			CombatController.SwitchPrimarySelectedTarget(
				moveData.targetSelectionType,
				"set",
				combatData.primarySelectedTargetIndex
			)

			-- Update the mana preview
			CombatController.UpdateMovePreview(moveData.targetSelectionType, moveData.data.manaChange :: number)
			break
		end

		-- Look at the current character from the perspective of the origin character
		if char:GetAttribute("Side") == "Allies" then
			CameraController.LookAtEnemies(combatData.currentCharacter :: any, combatData.primarySelectedTargetIndex)
		end
	end)
end

--- Handle switching primary selected targets.
--- If mode is "set", it will set the primary selected target index to the specified index.
--- If mode is "increment", it will increment the primary selected target index by the specified index.
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
--- @param mode -- Whether to set the primary selected target
--- @param index -- The index to set or increment by (e.g., -1 for previous, 1 for next)
--- @param allies -- Whether to switch the primary selected target among allies instead of enemies (default is false)
function CombatController.SwitchPrimarySelectedTarget(
	targetSelectionType: string,
	mode: "set" | "increment",
	index: number
)
	local combatData = CombatData[localPlayer]
	if not combatData.primarySelectedTargetIndex then
		warn("No primary selected target index found!")
		return
	end

	local primaryIndex = combatData.primarySelectedTargetIndex
	local targetsList = combatData.selectedSide == "Allies" and combatData.allies or combatData.enemies

	-- Find the index of the specified enemy in the selected enemies list
	if mode == "set" then
		primaryIndex = index
	elseif mode == "increment" then
		-- Clamp the new index within valid range
		primaryIndex = math.clamp(primaryIndex + index, 1, #targetsList)
	end

	-- Get the list of selected enemies based on the selection type
	local selectedTargets

	if targetSelectionType == "Single" then -- Select a single enemy.
		selectedTargets = { targetsList[primaryIndex] }
	elseif targetSelectionType == "Blast" then -- Select a main enemy and 2 enemies around them (if they exist).
		selectedTargets = { targetsList[primaryIndex] }
		if targetsList[primaryIndex - 1] then
			table.insert(selectedTargets, targetsList[primaryIndex - 1])
		end
		if targetsList[primaryIndex + 1] then
			table.insert(selectedTargets, targetsList[primaryIndex + 1])
		end
	elseif targetSelectionType == "AoE" then -- Select all enemies on the field.
		selectedTargets = targetsList
	end

	-- Notify EffectsController to update selection marks
	EffectsController.EnableTargetsSelectionMark(
		combatData.selectedSide,
		selectedTargets,
		combatData.primarySelectedTargetIndex
	)

	-- Update primary selected enemy index
	combatData.primarySelectedTargetIndex = primaryIndex
end

--- Switch to the next primary selected target
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
function CombatController.SwitchToPreviousTarget(targetSelectionType: string)
	CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", -1)
end

--- Switch to the next primary selected target
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
function CombatController.SwitchToNextTarget(targetSelectionType: string)
	CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", 1)
end

--- Update the move preview
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
--- @param manaChangePreviewValue -- The value to preview the mana change (e.g., +15, -10)
function CombatController.UpdateMovePreview(targetSelectionType: string, manaChangePreviewValue: number)
	-- Do not switch primary selected target, therefore index is 0
	CombatController.SwitchPrimarySelectedTarget(targetSelectionType, "increment", 0)

	-- Update the move preview in the HUD
	HUDController.UpdateManaPreview(manaChangePreviewValue)
end

--- Toggle visibility of a list of characters
function CombatController.DecideVisibleCharacters()
	local combatData = CombatData[localPlayer]
	local side = combatData.selectedSide
	warn(
		"Deciding visible characters for side:",
		side,
		"Current character:",
		combatData.currentCharacter and combatData.currentCharacter.Name
	)
	-- Depend on the side
	-- If the selection is on the enemies, hide all other allies
	if side == "Enemies" then
		-- Hide all allies except the current character
		for _, ally in pairs(combatData.allies) do
			if ally :: any == combatData.currentCharacter then
				Utility.ToggleCharacterVisibility(ally, true)
				continue
			end

			Utility.ToggleCharacterVisibility(ally, false)
		end

		-- Show all enemies
		for _, enemy in pairs(combatData.enemies) do
			Utility.ToggleCharacterVisibility(enemy, true)
		end
	-- If the selection is on the allies, hide all other enemies
	else
		-- Show all allies
		for _, ally in pairs(combatData.allies) do
			Utility.ToggleCharacterVisibility(ally, true)
		end

		-- Hide all enemies except the current character
		for _, enemy in pairs(combatData.enemies) do
			if enemy :: any == combatData.currentCharacter then
				Utility.ToggleCharacterVisibility(enemy, true)
				continue
			end

			Utility.ToggleCharacterVisibility(enemy, false)
		end
	end
end

--- Retrieve the current primary selected enemy index
function CombatController.GetPrimarySelectedTargetIndex(): number
	return CombatData[localPlayer].primarySelectedTargetIndex
end

-- Retrieve the current character for the local player
function CombatController.GetCurrentCharacter(): _TYPES.Character?
	return CombatData[localPlayer].currentCharacter
end

--- Retrieve the current selected side for the local player
function CombatController.GetSelectedSide(): "Allies" | "Enemies"
	return CombatData[localPlayer].selectedSide
end

--- Change the selected side for the local player
function CombatController.SetSelectedSide(side: "Allies" | "Enemies")
	CombatData[localPlayer].selectedSide = side
end

function CombatController.GetCombatData()
	return CombatData[localPlayer]
end

return CombatController
