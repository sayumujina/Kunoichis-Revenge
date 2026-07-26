local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local EffectsController = require(Controllers.EffectsController)
local HUDController = require(Controllers.HUDController)
local InputController = require(Controllers.InputController)
local SoundsController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
-- Components
local CurrentActionFrame =
	require(StarterPlayerScripts.Client.Controllers.HUDController.Components.Combat.CurrentAction.CurrentAction_Frame)
-- Player
local localPlayer = game:GetService("Players").LocalPlayer
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
local Trove = require(game.ReplicatedStorage.Packages.Trove)

--- @within CombatController
--- A collection of character data.
local CombatData: {
	[_TYPES.RobloxPlayerType]: {
		trove: Trove.Trove, -- A trove for cleaning up connections
		savedMovePreviewData: {
			char: _TYPES.Character,
			moveType: string,
			selectedSide: "Playable" | "NPC",
			primaryTargetIndex: number,
			targetSelectionType: string,
			manaChangePreviewValue: number,
		}?,
	},
} =
	{}

local CombatController = {}

--- Called when the controller starts
function CombatController.OnStart()
	-- Listen to spawn successful event
	Zap.SpawnSuccessfulForChar.On(function(spawnSuccessfulData)
		local char = spawnSuccessfulData.char :: _TYPES.Character
		local combatController = Utility.GetCharacterCombatController(char)
		if not combatController then
			warn("No combat controller found for character: " .. char.Name)
			return
		end

		-- if combatController.Init then
		-- 	require(combatController).Init(char)
		-- end
	end)

	-- Listens to sucessful move events
	Zap.SuccessfulMove.On(function(successfulMoveData)
		local char = successfulMoveData.origin :: _TYPES.Character
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

			local trove = CombatData[localPlayer].trove

			-- If it matches, call the corresponding attack handler
			local controller = Utility.GetCharacterCombatController(char)
			local attackHandlers = controller and require(controller).GetAttackHandlers()
			attackHandlers[moveName](
				trove,
				animationTrack,
				successfulMoveData.origin :: _TYPES.Character,
				successfulMoveData.data.attackData
			)

			-- Clean up the trove for the current character after the animation is done
			trove:Add(animationTrack.Stopped:Connect(function()
				-- task.delay(cleanupDuration, function()
				trove:Clean()
				-- end)
			end))

			break
		end
	end)

	-- Listens to update move preview event
	Zap.UpdateMovePreview.On(function(data)
		-- Get the move list
		local moveList = Utility.GetCharacterMoveList(data.char :: _TYPES.Character)

		-- Get the selected side of the move
		local selectedSide = moveList[data.data.moveName].selectedSide

		-- Get the target selection type of the move
		local targetSelectionType = moveList[data.data.moveName].targetSelectionType

		-- Get the primary target index of the move
		local primaryTargetIndex = data.data.primaryTargetIndex

		-- Get the mana change value of the move
		local manaChange = moveList[data.data.moveName].manaChange :: number

		-- Save the move preview data for later use
		CombatController.SavePreviewData(
			data.char :: _TYPES.Character,
			moveList[data.data.moveName].moveType,
			selectedSide,
			primaryTargetIndex,
			targetSelectionType,
			manaChange
		)
		-- Update the move preview with the target selection type and mana change value
		CombatController.UpdateMovePreview(
			data.char :: _TYPES.Character,
			moveList[data.data.moveName].moveType,
			selectedSide,
			targetSelectionType,
			primaryTargetIndex,
			manaChange
		)
	end)

	-- Listens to spawn finish event
	Zap.SpawnFinished.On(function()
		if not CombatData[localPlayer] then
			CombatData[localPlayer] = {
				trove = Trove.new() :: any,
			}
		end
	end)

	-- Listens to player leaving the game to clean up the combat data for that player
	game.Players.PlayerRemoving:Connect(function(player)
		if player == localPlayer then
			-- Clean up the combat data for the local player
			if CombatData[localPlayer] and CombatData[localPlayer].trove then
				CombatData[localPlayer].trove:Destroy()
			end
			CombatData[localPlayer] = nil
		end
	end)

	-- Listens to despawn event to clean up the combat data for that player
	Zap.DespawnSuccessful.On(function(despawnEvent)
		if despawnEvent.player == localPlayer then
			-- Clean up the combat data for the local player
			if CombatData[localPlayer] and CombatData[localPlayer].trove then
				CombatData[localPlayer].trove:Destroy()
			end
			CombatData[localPlayer] = nil
		end
	end)

	InputController.ToggleHUDVisibility:Connect(function(event)
		if event.guiName == "DetailedCombatInfo_ScreenGui" and not event.show then
			CombatController.ReloadPreviewData()
		end
	end)
end

--- Handle switching primary selected targets.
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
--- @param index -- The index to set or increment by (e.g., -1 for previous, 1 for next)
--- @param side -- The side to switch targets on ("Playable" or "NPC")
function CombatController.DetermineSelectedTargets(
	targetSelectionType: string,
	primaryIndex: number,
	side: "Playable" | "NPC"
)
	local targetsFolder = side == "Playable" and game.Workspace.Characters.Playable or game.Workspace.Characters.NPC

	-- Get the list of selected enemies based on the selection type
	local selectedTargets
	local findChar = Utility.FindCharacterWithIndex

	if targetSelectionType == "Single" then -- Select a single enemy.
		selectedTargets = { findChar(primaryIndex, targetsFolder) :: _TYPES.Character }
	elseif targetSelectionType == "Blast" then -- Select a main enemy and 2 enemies around them (if they exist).
		selectedTargets = { findChar(primaryIndex, targetsFolder) :: _TYPES.Character }

		-- Find adjacent targets
		local charOnTheLeft = findChar(primaryIndex - 1, targetsFolder)
		if charOnTheLeft then
			table.insert(selectedTargets, charOnTheLeft)
		end

		local charOnTheRight = findChar(primaryIndex + 1, targetsFolder)
		if charOnTheRight then
			table.insert(selectedTargets, charOnTheRight)
		end
	elseif targetSelectionType == "AoE" then -- Select all enemies on the field.
		selectedTargets = targetsFolder:GetChildren()
	end

	-- Notify EffectsController to update selection marks
	EffectsController.EnableTargetsSelectionMark(side, selectedTargets, primaryIndex)
end

--- Update the move preview
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
--- @param manaChangePreviewValue -- The value to preview the mana change (e.g., +15, -10)
function CombatController.UpdateMovePreview(
	char: _TYPES.Character,
	moveType: string,
	side: "Playable" | "NPC",
	targetSelectionType: string,
	primaryTargetIndex: number,
	manaChangePreviewValue: number
)
	-- Determine the selected targets for the preview
	CombatController.DetermineSelectedTargets(targetSelectionType, primaryTargetIndex, side)

	-- Update the move preview in the HUD
	HUDController.UpdateManaPreview(manaChangePreviewValue or 0)

	-- Update the current action text in the HUD
	CurrentActionFrame.ChangeCurrentActionText(moveType)

	-- Call the character combat controller to update the camera
	local controller = Utility.GetCharacterCombatController(char)
	if controller then
		task.defer(function()
			require(controller).UpdateCamera(char, side, primaryTargetIndex)
		end)
	end

	-- Play the sound for selecting a target
	SoundsController.Play("Sound_SelectTarget")
end

--- Store the move preview data for later use
function CombatController.SavePreviewData(
	char: _TYPES.Character,
	moveType: string,
	selectedSide: "Playable" | "NPC",
	primaryTargetIndex: number,
	targetSelectionType: string,
	manaChangePreviewValue: number
)
	if not CombatData[localPlayer] then
		return
	end

	CombatData[localPlayer].savedMovePreviewData = {
		char = char,
		moveType = moveType,
		selectedSide = selectedSide,
		primaryTargetIndex = primaryTargetIndex,
		targetSelectionType = targetSelectionType,
		manaChangePreviewValue = manaChangePreviewValue,
	}
end

--- Reload the move preview data from the saved data
function CombatController.ReloadPreviewData()
	if not CombatData[localPlayer] then
		return
	end

	local savedData = CombatData[localPlayer].savedMovePreviewData
	if not savedData then
		return
	end

	CombatController.UpdateMovePreview(
		savedData.char,
		savedData.moveType,
		savedData.selectedSide,
		savedData.targetSelectionType,
		savedData.primaryTargetIndex,
		savedData.manaChangePreviewValue
	)
end

function CombatController.GetCombatData()
	return CombatData[localPlayer]
end

return CombatController
