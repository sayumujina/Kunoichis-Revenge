local CombatController = require(script.Parent.CombatController)
local UserInputService = game:GetService("UserInputService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

--- @class InputController
--- @server
--- @tag Client
local InputController = {}

local InputToActions = {
	-- Enemy selection
	[Enum.KeyCode.A] = "PreviousTarget",
	[Enum.KeyCode.D] = "NextTarget",
	-- [Enum.KeyCode.S] = "MoveBackward",
	-- [Enum.KeyCode.D] = "MoveRight",
	-- [Enum.KeyCode.Space] = "Jump",
	[Enum.UserInputType.MouseButton1] = "SelectTarget",
}

--- Listening to user's input
game.UserInputService.InputBegan:Connect(function(input, _)
	if input.UserInputState == Enum.UserInputState.Begin then
		local actionName = InputToActions[input.KeyCode] or InputToActions[input.UserInputType]
		-- Handle enemy selection inputs
		if actionName == "PreviousTarget" then
			CombatController.SwitchPrimarySelectedEnemy("increment", -1)
		elseif actionName == "NextTarget" then
			CombatController.SwitchPrimarySelectedEnemy("increment", 1)
		elseif actionName == "SelectTarget" then
			-- Get current primary selected enemy index
			if not mouse.Target or not mouse.Target.Parent:FindFirstChild("Humanoid") then
				return
			end

			-- Retrieve the index attribute of the selected enemy
			local primaryIndex = mouse.Target.Parent:GetAttribute("Index")
			if primaryIndex then
				CombatController.SwitchPrimarySelectedEnemy("set", primaryIndex)
			end
		end
	end
end)

return InputController
