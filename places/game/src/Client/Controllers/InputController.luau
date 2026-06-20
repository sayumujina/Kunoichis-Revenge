local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local UserInputService = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
-- Utility
local Utility = require(game:GetService("ReplicatedStorage").Shared.Modules.Utility)
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
	[Enum.KeyCode.Space] = "ConfirmAction",
	[Enum.KeyCode.Q] = "BasicAttack",
	[Enum.KeyCode.E] = "Skill",
	-- Spawn
	[Enum.KeyCode.U] = "Spawn",
} :: { [Enum.KeyCode | Enum.UserInputType]: string }

local CombatActions = { "BasicAttack", "Skill", "Ultimate" }

--- Listen to user's input
UserInputService.InputBegan:Connect(function(input, _)
	if input.UserInputState == Enum.UserInputState.Begin then
		local actionName = InputToActions[input.KeyCode] or InputToActions[input.UserInputType]

		-- Handle enemy selection inputs
		if actionName == "PreviousTarget" then
			-- Call the combat controller of the active character
			local combatController = Utility.GetCharacterCombatController(player.ActiveCharacter.Value)
			if combatController then
				require(combatController).HandleInput({
					action = "PreviousTarget",
				})
			end
		elseif actionName == "NextTarget" then
			local combatController = Utility.GetCharacterCombatController(player.ActiveCharacter.Value)
			if combatController then
				require(combatController).HandleInput({
					action = "NextTarget",
				})
			end
		elseif actionName == "SelectTarget" then
			-- -- Get current primary selected enemy index
			-- if not mouse.Target or not mouse.Target.Parent:FindFirstChild("Humanoid") then
			-- 	return
			-- end

			-- -- Retrieve the index attribute of the selected enemy
			-- local primaryIndex = mouse.Target.Parent:GetAttribute("Index")
			-- if primaryIndex then
			-- 	CombatController.SwitchPrimarySelectedEnemy("set", primaryIndex)
			-- end
		elseif table.find(CombatActions, actionName) then
			local combatController = Utility.GetCharacterCombatController(player.ActiveCharacter.Value)
			if not combatController then
				return
			end

			-- Switching moves will keep the primary selected enemy
			-- But we're delegating the effects handling to combat controller, so just increment by 0 to not change the index
			require(combatController).HandleInput({
				action = actionName,
			})
		elseif actionName == "Spawn" then
			Zap.RequestSpawn.Fire()
		end
	end
end)

return InputController
