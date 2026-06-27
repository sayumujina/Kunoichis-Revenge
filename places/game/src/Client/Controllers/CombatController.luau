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
local Trove = require(game.ReplicatedStorage.Packages.Trove)

--- @within CombatController
--- A collection of character data.
local CombatData: {
	[_TYPES.RobloxPlayerType]: {
		trove: Trove.Trove, -- A trove for cleaning up connections
	},
} =
	{}

local CombatController = {}

--- Called when the controller starts
function CombatController.OnStart()
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

			local trove = CombatData[localPlayer].trove

			-- If it matches, call the corresponding attack handler
			local controller = Utility.GetCharacterCombatController(char)
			local attackHandlers = controller and require(controller).GetAttackHandlers()
			local cleanupDuration = attackHandlers[moveName](
				trove,
				animationTrack,
				successfulMoveData.char :: _TYPES.Character,
				successfulMoveData.data.targets :: { _TYPES.Character }
			)

			-- Clean up the trove for the current character after the animation is done
			trove:Add(animationTrack.Stopped:Connect(function()
				task.delay(cleanupDuration, function()
					trove:Clean()
				end)
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

		-- Update the move preview with the target selection type and mana change value
		CombatController.UpdateMovePreview(
			data.char :: _TYPES.Character,
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
end

--- Handle switching primary selected targets.
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
--- @param index -- The index to set or increment by (e.g., -1 for previous, 1 for next)
--- @param side -- The side to switch targets on ("Allies" or "Enemies")
function CombatController.DetermineSelectedTargets(
	targetSelectionType: string,
	primaryIndex: number,
	side: "Allies" | "Enemies"
)
	local targetsList = side == "Allies" and game.Workspace.Characters.Allies:GetChildren()
		or game.Workspace.Characters.Enemies:GetChildren()

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
	EffectsController.EnableTargetsSelectionMark(side, selectedTargets, primaryIndex)
end

--- Update the move preview
--- @param targetSelectionType -- The type of target selection (e.g., "Single", "Blast", "AoE")
--- @param manaChangePreviewValue -- The value to preview the mana change (e.g., +15, -10)
function CombatController.UpdateMovePreview(
	char: _TYPES.Character,
	side: "Allies" | "Enemies",
	targetSelectionType: string,
	primaryTargetIndex: number,
	manaChangePreviewValue: number
)
	-- Determine the selected targets for the preview
	CombatController.DetermineSelectedTargets(targetSelectionType, primaryTargetIndex, side)

	-- Update the move preview in the HUD
	HUDController.UpdateManaPreview(manaChangePreviewValue)

	-- Call the character combat controller to update the camera
	local controller = Utility.GetCharacterCombatController(char)
	if controller then
		require(controller).UpdateCamera(char, side, primaryTargetIndex)
	end
end

function CombatController.GetCombatData()
	return CombatData[localPlayer]
end

return CombatController
