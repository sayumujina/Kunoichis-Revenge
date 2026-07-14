local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)

--- Change the text of the top bar label 
--- @param text -- The new text to set for the top bar label
local function changeTopBarLabel(text: string)
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local topBarFrame = playerGui:FindFirstChild("Global_ScreenGui", true):FindFirstChild("TopBar_Frame", true)
    if topBarFrame then
        local topBarLabel = topBarFrame:FindFirstChild("TextLabel", true)
        if topBarLabel then
            topBarLabel.Text = text
        end
    end
end

--- Creates a new top bar frame with the specified text
--- @param text -- The text to display on the top bar
local function createTopBar(text: string)
    local topBarFrame = Instance.new("Frame")
    topBarFrame.Name = "TopBar_Frame"
    topBarFrame.BackgroundTransparency = 1
    topBarFrame.Size = UDim2.fromScale(1, 0.187)
    topBarFrame.ZIndex = 2

    local bG = Instance.new("ImageLabel")
    bG.Name = "BG"
    bG.BackgroundTransparency = 1
    bG.Image = ui.hud.Menu.UI_Menu_TopBar
    bG.Size = UDim2.fromScale(1, 1)
    bG.Parent = topBarFrame

    local topBarLabel = Instance.new("TextLabel")
    topBarLabel.Name = "TextLabel"
    topBarLabel.BackgroundTransparency = 1
    topBarLabel.FontFace = Font.new(
        "rbxasset://fonts/families/Balthazar.json",
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    )
    topBarLabel.Position = UDim2.fromScale(0.125, 0.125)
    topBarLabel.Size = UDim2.fromScale(0.7, 0.4)
    topBarLabel.Text = text
    topBarLabel.TextColor3 = Color3.fromRGB(43, 26, 16)
    topBarLabel.TextScaled = true
    topBarLabel.TextStrokeColor3 = Color3.new(1, 1, 1)
    topBarLabel.TextStrokeTransparency = 0.75
    topBarLabel.TextXAlignment = Enum.TextXAlignment.Left
    topBarLabel.Parent = topBarFrame

    return topBarFrame
end

return {
    ChangeTopBarLabel = changeTopBarLabel,
    CreateTopBar = createTopBar,
}