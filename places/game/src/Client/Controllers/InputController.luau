local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)
local UserInputService = game:GetService("UserInputService")
-- Utility
local player = game:GetService("Players").LocalPlayer
local Utility = require(game:GetService("ReplicatedStorage").Shared.Modules.Utility)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
-- HUD Components
local Components = Controllers.HUDController.Components
local DetailedCombatInfoScrollingFrame = require(Components.Combat.DetailedCombatInfo.DetailedCombatInfo_ScrollingFrame)
local DetailedCombatInfoCharacterSelection =
	require(Components.Combat.DetailedCombatInfo.DetailedCombatInfo_CharacterSelection)
-- Packages
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)
local Signal = require(game:GetService("ReplicatedStorage").Packages.Signal)

--- @class InputController
--- @server
--- @tag Client
local InputController = {}

--- @interface InputController
--- @within InputController
--- @field ToggleHUDVisibility Signal -- Fires when requesting to toggle the HUD visibility, with the gui name and whether to show or hide it
InputController.ToggleHUDVisibility = Signal.new() :: Signal.Signal<{ guiName: string, show: boolean }>

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
} :: { [Enum.KeyCode | Enum.UserInputType]: string }

local detailedCombatInfoOpened = false
local allowDetailedCombatInfoToggle = true
local isInputAllowed = true

--- Called when the controller starts
function InputController.OnStart()
	-- Listens to input disallowed event to disable input processing
	Zap.ToggleInputAllowance.On(function(data)
		InputController.ToggleInputAllowance(data.allowed)
	end)

	-- Listens to casting ultimate event to disable input processing
	Zap.CastedUltimate.On(function(data)
		warn("Casting ultimate, disabling input for " .. data.data.flashDuration .. " seconds")
		InputController.ToggleInputAllowance(false)
		task.delay(data.data.flashDuration, function()
			InputController.ToggleInputAllowance(true)
		end)
	end)

	-- Listen to combat info menu toggle event to allow or disallow opening the detailed combat info menu
	Zap.AllowCombatInfoMenuToggle.On(function(data)
		InputController.ToggleDetailedCombatInfoAllowance(data.allowed)
	end)

	-- Listens to spawn finished event to start allowing input processing
	Zap.SpawnFinished.On(function()
		InputController.ToggleInputAllowance(true)
		InputController.ToggleDetailedCombatInfoAllowance(true)
	end)

	-- Disable all input upon battle completed/ failed
	Zap.BattleEnded.On(function()
		InputController.ToggleInputAllowance(false)
		InputController.ToggleDetailedCombatInfoAllowance(false)
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

		-- If the action is opening the detailed combat info menu, we don't need to send it to the server
		if actionName == "OpenDetailedCombatInfo" and allowDetailedCombatInfoToggle then
			-- Toggle the detailed combat info menu flag
			detailedCombatInfoOpened = not detailedCombatInfoOpened

			if detailedCombatInfoOpened then
				-- Toggle the detailed combat info menu visibility
				InputController.ToggleHUDVisibility:Fire({
					guiName = "Combat_ScreenGui",
					show = not detailedCombatInfoOpened,
				})
				InputController.ToggleHUDVisibility:Fire({
					guiName = "DetailedCombatInfo_ScreenGui",
					show = detailedCombatInfoOpened,
				})
				DetailedCombatInfoScrollingFrame.ShowCharDetailedCombat(player.ActiveCharacter.Value)
			else
				-- Toggle the detailed combat info menu visibility
				InputController.ToggleHUDVisibility:Fire({
					guiName = "Combat_ScreenGui",
					show = not detailedCombatInfoOpened,
				})
				InputController.ToggleHUDVisibility:Fire({
					guiName = "DetailedCombatInfo_ScreenGui",
					show = detailedCombatInfoOpened,
				})
				DetailedCombatInfoCharacterSelection.ResetSelectedLayoutOrder()
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

--- Toggles the input allowance for the player
--- @param allowed -- Whether input is allowed or not
function InputController.ToggleInputAllowance(allowed: boolean)
	isInputAllowed = allowed
end

--- Toggles the allowance for opening the detailed combat info menu
--- @param allowed -- Whether opening the detailed combat info menu is allowed or not
function InputController.ToggleDetailedCombatInfoAllowance(allowed: boolean)
	allowDetailedCombatInfoToggle = allowed
end

return InputController
