local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local UserInputService = game:GetService("UserInputService")
-- Utility
local player = game:GetService("Players").LocalPlayer
local Utility = require(game:GetService("ReplicatedStorage").Shared.Modules.Utility)
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
	-- Spawn
	[Enum.KeyCode.U] = "Spawn",
} :: { [Enum.KeyCode | Enum.UserInputType]: string }

local spawned = false
--- Called when the controller starts
function InputController.OnStart()
	-- Listen to input began event
	UserInputService.InputBegan:Connect(function(input, _)
		local actionName = InputToActions[input.KeyCode] or InputToActions[input.UserInputType]

		-- Stop processing if the action is not mapped
		if not actionName then
			return
		end

		if actionName == "Spawn" and not spawned then
			Zap.RequestSpawn.Fire()
			spawned = true
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
