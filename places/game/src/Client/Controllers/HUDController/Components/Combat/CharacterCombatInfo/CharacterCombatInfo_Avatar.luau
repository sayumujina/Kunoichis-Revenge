return function()
    local characterInfoAvatar = Instance.new("Frame")
    characterInfoAvatar.Name = "CharacterInfo_Avatar"
    characterInfoAvatar.BackgroundTransparency = 1
    characterInfoAvatar.Position = UDim2.fromScale(0.03, 0)
    characterInfoAvatar.Size = UDim2.fromScale(0.63, 0.63)

    local characterInfoAvatarImageLabel = Instance.new("ImageLabel")
    characterInfoAvatarImageLabel.Name = "ImageLabel"
    characterInfoAvatarImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
    characterInfoAvatarImageLabel.BorderColor3 = Color3.new()
    characterInfoAvatarImageLabel.BorderSizePixel = 0
    characterInfoAvatarImageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    characterInfoAvatarImageLabel.Size = UDim2.fromScale(1, 1)
    characterInfoAvatarImageLabel.Parent = characterInfoAvatar

    local characterInfoAvatarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    characterInfoAvatarAspectRatioConstraint.Name = "UIAspectRatioConstraint"
    characterInfoAvatarAspectRatioConstraint.Parent = characterInfoAvatar

    return characterInfoAvatar
end