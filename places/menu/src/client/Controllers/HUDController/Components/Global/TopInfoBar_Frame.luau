local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)

--- Change the text of the top bar label
--- @param text -- The new text to set for the top bar label
local function changeTopBarLabel(text: string)
	local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	local topBarFrame = playerGui:FindFirstChild("Global_ScreenGui", true):FindFirstChild("TopInfoBar_Frame", true)
	if topBarFrame then
		local topBarLabel = topBarFrame:FindFirstChild("TextLabel", true)
		if topBarLabel then
			topBarLabel.Text = text
		end
	end
end

--- Creates a new top bar frame with the specified text
--- @param text -- The text to display on the top bar
local function createTopInfoBar(text: string)
	local topBarFrame = Instance.new("Frame")
	topBarFrame.Name = "TopInfoBar_Frame"
	topBarFrame.BackgroundTransparency = 1
	topBarFrame.Size = UDim2.fromScale(1, 0.187)
	topBarFrame.ZIndex = 2

	local bg = Instance.new("ImageLabel")
	bg.Name = "BG"
	bg.BackgroundTransparency = 1
	bg.Image = ui.hud.Menu.UI_Menu_TopBar
	bg.Size = UDim2.fromScale(1, 1)
	bg.Parent = topBarFrame

	local topBarLabel = Instance.new("TextLabel")
	topBarLabel.Name = "TextLabel"
	topBarLabel.BackgroundTransparency = 1
	topBarLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	topBarLabel.Position = UDim2.fromScale(0.105, 0.23)
	topBarLabel.Size = UDim2.fromScale(0.7, 0.4)
	topBarLabel.Text = text
	topBarLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	topBarLabel.TextScaled = true
	topBarLabel.TextStrokeColor3 = Color3.fromRGB(139, 111, 91)
	topBarLabel.TextStrokeTransparency = 1
	topBarLabel.TextXAlignment = Enum.TextXAlignment.Left
	topBarLabel.Parent = topBarFrame

	return topBarFrame
end

return {
	ChangeTopBarLabel = changeTopBarLabel,
	CreateTopInfoBar = createTopInfoBar,
}
