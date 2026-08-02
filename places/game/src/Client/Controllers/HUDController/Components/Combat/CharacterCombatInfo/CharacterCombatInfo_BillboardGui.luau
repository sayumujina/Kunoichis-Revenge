local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local CharacterCombatInfoHealthbar = require(script.Parent.CharacterCombatInfo_Healthbar)
local CreateCharacterCombatInfoExposureBar = require(script.Parent.CharacterCombatInfo_ExposureBar)

return function(char: _TYPES.Character, playerGui: PlayerGui)
	if not char or not playerGui then
		return
	end

	-- Create a billboard gui
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = char.Name .. "_BillboardGui"
	billboardGui.Parent = playerGui:FindFirstChild("UI_BillboardGui_Folder", true)
	billboardGui.Adornee = char:WaitForChild("HumanoidRootPart")
	--
	char.Destroying:Connect(function()
		billboardGui:Destroy()
	end)

	-- Set the size and offset of the billboard gui to be above the character's head
	billboardGui.Size = UDim2.fromScale(6, 0.841)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)

	-- Create the healthbar frame and parent it to the billboard gui
	local characterInfoHealthbarFrame =
		CharacterCombatInfoHealthbar.CreateHealthbar(char, UDim2.fromScale(1, 0.747), UDim2.fromScale(0, 0))
	characterInfoHealthbarFrame.Parent = billboardGui

	-- Create the exposure bar frame and parent it to the billboard gui
	local characterInfoExposureBar = CreateCharacterCombatInfoExposureBar()
	characterInfoExposureBar.Parent = billboardGui

	--  Create an ObjectValue to associate the character with the billboard gui
	local associatedCharValue = Instance.new("ObjectValue")
	associatedCharValue.Name = "AssociatedCharValue"
	associatedCharValue.Value = char
	associatedCharValue.Parent = billboardGui
end
