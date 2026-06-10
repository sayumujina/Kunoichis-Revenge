local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local CombatController = require(script.Parent.CombatController)
local UserInputService = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
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

local Data = {
	selectedMoveType = "BasicAttack" :: _TYPES.MoveType,
}

local CombatActions = { "BasicAttack", "Skill", "Ultimate" }

--- Listen to user's input
UserInputService.InputBegan:Connect(function(input, _)
	if input.UserInputState == Enum.UserInputState.Begin then
		local actionName = InputToActions[input.KeyCode] or InputToActions[input.UserInputType]

		-- Handle enemy selection inputs
		if actionName == "PreviousTarget" then
			CombatController.SwitchPrimarySelectedEnemy(Data.selectedMoveType, "increment", -1)
		elseif actionName == "NextTarget" then
			CombatController.SwitchPrimarySelectedEnemy(Data.selectedMoveType, "increment", 1)
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
			warn("Player selected action: " .. actionName)
			-- If the player is switching to a different move, update the selected move type and wait for confirmation
			-- A move will only be confirmed if the player selects it again
			if Data.selectedMoveType ~= actionName then
				Data.selectedMoveType = actionName :: _TYPES.MoveType

				warn("Waiting for player to confirm move: " .. Data.selectedMoveType)
				-- Switching moves will keep the primary selected enemy
				-- But we're delegating the effects handling to combat controller, so just increment by 0 to not change the index
				CombatController.SwitchPrimarySelectedEnemy(Data.selectedMoveType, "increment", 0)
				return
			end

			-- Send the input to the server
			Zap.InputSent.Fire({ origin = player.ActiveCharacter.Value, action = actionName })

			-- Reset the selected move type to default
			Data.selectedMoveType = "BasicAttack"
		elseif actionName == "Spawn" then
			Zap.RequestSpawn.Fire()
		end
	end
end)

return InputController
