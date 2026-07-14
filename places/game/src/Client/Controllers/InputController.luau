local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)
local UserInputService = game:GetService("UserInputService")
-- Utility
local player = game:GetService("Players").LocalPlayer
local Utility = require(game:GetService("ReplicatedStorage").Shared.Modules.Utility)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local HUDController = require(Controllers.HUDController)
local CombatController = require(Controllers.CombatController)
-- HUD Components
local Components = Controllers.HUDController.Components
local DetailedCombatInfoScrollingFrame = require(Components.Combat.DetailedCombatInfo.DetailedCombatInfo_ScrollingFrame)
local DetailedCombatInfoCharacterSelection =
	require(Components.Combat.DetailedCombatInfo.DetailedCombatInfo_CharacterSelection)
--
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)

--- @class InputController
--- @server
--- @tag Client
local InputController = {}

local InputToActions = {
	-- Enemy selection
	[Enum.KeyCode.A] = "PreviousTarget",
	[Enum.KeyCode.D] = "NextTarget",
	-- [Enum.UserInputType.MouseButton1] = "SelectTarget",
	-- Combat actions
	[Enum.KeyCode.Q] = "BasicAttack",
	[Enum.KeyCode.E] = "Skill",
	[Enum.KeyCode.One] = "Ultimate1",
	[Enum.KeyCode.Two] = "Ultimate2",
	[Enum.KeyCode.Three] = "Ultimate3",
	[Enum.KeyCode.Z] = "SkipTurn",
	-- Open detailed combat info menu
	[Enum.KeyCode.C] = "OpenDetailedCombatInfo",
	-- Spawn
	[Enum.KeyCode.U] = "Spawn",
} :: { [Enum.KeyCode | Enum.UserInputType]: string }

local spawned = false
local detailedCombatInfoOpened = false
local allowDetailedCombatInfoToggle = true
local isInputAllowed = true

--- Called when the controller starts
function InputController.OnStart()
	-- Listens to input disallowed event to disable input processing
	Zap.ToggleInputAllowance.On(function(data)
		isInputAllowed = data.allowed
	end)

	-- Listens to casting ultimate event to disable input processing
	Zap.CastedUltimate.On(function(data)
		warn("Casting ultimate, disabling input for " .. data.data.flashDuration .. " seconds")
		isInputAllowed = false
		task.delay(data.data.flashDuration, function()
			isInputAllowed = true
		end)
	end)

	-- Listen to the spawn successful event to set the spawned flag to true
	Zap.AllowCombatInfoMenuToggle.On(function(data)
		allowDetailedCombatInfoToggle = data.allowed
	end)

	-- Listen to input began event
	UserInputService.InputBegan:Connect(function(input, _)
		if not isInputAllowed then
			return
		end

		local actionName = InputToActions[input.KeyCode] or InputToActions[input.UserInputType]

		-- Stop processing if the action is not mapped
		if not actionName then
			return
		end

		if actionName == "Spawn" and not spawned then
			-- Zap.RequestSpawn.Fire()
			-- spawned = true
			return
		end

		-- If the action is opening the detailed combat info menu, we don't need to send it to the server
		if actionName == "OpenDetailedCombatInfo" and allowDetailedCombatInfoToggle then
			-- Toggle the detailed combat info menu flag
			detailedCombatInfoOpened = not detailedCombatInfoOpened

			if detailedCombatInfoOpened then
				-- Toggle the detailed combat info menu visibility
				HUDController.ToggleScreenGuiVisibility("Combat_ScreenGui", not detailedCombatInfoOpened)
				HUDController.ToggleScreenGuiVisibility("DetailedCombatInfo_ScreenGui", detailedCombatInfoOpened)
				DetailedCombatInfoScrollingFrame.ShowCharDetailedCombat(player.ActiveCharacter.Value)
			else
				-- Toggle the detailed combat info menu visibility
				HUDController.ToggleScreenGuiVisibility("Combat_ScreenGui", not detailedCombatInfoOpened)
				HUDController.ToggleScreenGuiVisibility("DetailedCombatInfo_ScreenGui", detailedCombatInfoOpened)
				DetailedCombatInfoCharacterSelection.ResetSelectedLayoutOrder()

				-- Reload the move preview data when closing the detailed combat info menu
				CombatController.ReloadPreviewData()
			end
			return
		elseif actionName == "PreviousTarget" or actionName == "NextTarget" then
			-- If the detailed combat info menu is open, this action will be used to switch the selected character in the detailed combat info menu
			if detailedCombatInfoOpened then
				DetailedCombatInfoCharacterSelection.SwitchCharButton(
					if actionName == "PreviousTarget" then "Previous" else "Next"
				)
				return
			end
		end

		-- Disable every other action if the menu is open
		if detailedCombatInfoOpened then
			return
		end

		-- If the action is an ultimate, the origin will be the associated character
		local origin
		if actionName:find("Ultimate") then
			-- Find the character associated with the ultimate action
			local ultimateIndex = tonumber(actionName:sub(-1)) :: number
			local char = Utility.FindCharacterWithIndex(ultimateIndex, game.Workspace.Characters.Playable)
			if char then
				origin = char
			end
		-- Otherwise, the origin will be the player's active character
		elseif actionName then
			origin = player.ActiveCharacter.Value
		end

		Zap.InputSent.Fire({ origin = origin, action = actionName })
	end)
end

return InputController
