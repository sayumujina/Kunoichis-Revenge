return function()
    local characterInfoHealthbar = Instance.new("Frame")
    characterInfoHealthbar.Name = "CharacterInfo_Healthbar"
    characterInfoHealthbar.BackgroundTransparency = 1
    characterInfoHealthbar.Position = UDim2.fromScale(0.005, 0.669)
    characterInfoHealthbar.Size = UDim2.fromScale(0.964, 0.1344)

    local characterInfoHealthbarBorder = Instance.new("Frame")
    characterInfoHealthbarBorder.Name = "CharacterInfo_HealthbarBorder"
    characterInfoHealthbarBorder.BackgroundTransparency = 1
    characterInfoHealthbarBorder.Size = UDim2.fromScale(1, 1)

    local characterInfoHealthbarBorderImageLabel = Instance.new("ImageLabel")
    characterInfoHealthbarBorderImageLabel.Name = "ImageLabel"
    characterInfoHealthbarBorderImageLabel.BackgroundTransparency = 1
    characterInfoHealthbarBorderImageLabel.Image = "rbxassetid://84100549722129"
    characterInfoHealthbarBorderImageLabel.Size = UDim2.fromScale(1, 1)

    local characterInfoHealthbarBorderUIGradient = Instance.new("UIGradient")
    characterInfoHealthbarBorderUIGradient.Name = "UIGradient"
    characterInfoHealthbarBorderUIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new()),
        ColorSequenceKeypoint.new(1, Color3.new()),
    })
    characterInfoHealthbarBorderUIGradient.Parent = characterInfoHealthbarBorderImageLabel

    characterInfoHealthbarBorderImageLabel.Parent = characterInfoHealthbarBorder

    characterInfoHealthbarBorder.Parent = characterInfoHealthbar

    local characterInfoHealthbarFill = Instance.new("Frame")
    characterInfoHealthbarFill.Name = "CharacterInfo_HealthbarFill"
    characterInfoHealthbarFill.AnchorPoint = Vector2.new(0, 0.5)
    characterInfoHealthbarFill.BackgroundTransparency = 1
    characterInfoHealthbarFill.ClipsDescendants = true
    characterInfoHealthbarFill.Position = UDim2.fromScale(-2.84956e-08, 0.5)
    characterInfoHealthbarFill.Size = UDim2.fromScale(0.733939, 1)

    local characterInfoHealthbarFillImageLabel = Instance.new("ImageLabel")
    characterInfoHealthbarFillImageLabel.Name = "ImageLabel"
    characterInfoHealthbarFillImageLabel.BackgroundTransparency = 1
    characterInfoHealthbarFillImageLabel.Image = "rbxassetid://93013412082634"
    characterInfoHealthbarFillImageLabel.Size = UDim2.fromScale(1, 1)

    local characterInfoHealthbarFillUIGradient = Instance.new("UIGradient")
    characterInfoHealthbarFillUIGradient.Name = "UIGradient"
    characterInfoHealthbarFillUIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new()),
        ColorSequenceKeypoint.new(1, Color3.new()),
    })
    characterInfoHealthbarFillUIGradient.Parent = characterInfoHealthbarFillImageLabel

    characterInfoHealthbarFillImageLabel.Parent = characterInfoHealthbarFill

    characterInfoHealthbarFill.Parent = characterInfoHealthbar

    return characterInfoHealthbar
end