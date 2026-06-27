local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local UserInputService = game:GetService("UserInputService")
-- Utility
--
local player = game.Players.LocalPlayer
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
	[Enum.UserInputType.MouseButton1] = "SelectTarget",
	-- Combat actions
	[Enum.KeyCode.Q] = "BasicAttack",
	[Enum.KeyCode.E] = "Skill",
	-- Spawn
	[Enum.KeyCode.U] = "Spawn",
} :: { [Enum.KeyCode | Enum.UserInputType]: string }

--- Called when the controller starts
function InputController.OnStart()
	-- Listen to user's input
	UserInputService.InputEnded:Connect(function(input, _)
		-- Listening to input end event allow players to change their mind before confirming an action
		if input.UserInputState == Enum.UserInputState.End then
			local actionName = InputToActions[input.KeyCode] or InputToActions[input.UserInputType]
			if actionName == "Spawn" then
				Zap.RequestSpawn.Fire()
				return
			end

			if actionName then
				Zap.InputSent.Fire({ origin = player.ActiveCharacter.Value, action = actionName })
			end
		end
	end)
end

return InputController
