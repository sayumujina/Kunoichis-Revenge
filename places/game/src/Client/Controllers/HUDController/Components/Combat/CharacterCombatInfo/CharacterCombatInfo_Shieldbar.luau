return function()
	local characterInfoShieldbar = Instance.new("Frame")
	characterInfoShieldbar.Name = "CharacterInfo_Shieldbar"
	characterInfoShieldbar.BackgroundTransparency = 1
	characterInfoShieldbar.Position = UDim2.fromScale(0, 0.66)
	characterInfoShieldbar.Size = UDim2.fromScale(0.976, 0.151)
	characterInfoShieldbar.Visible = false -- for now

	local characterInfoShieldImageLabel = Instance.new("ImageLabel")
	characterInfoShieldImageLabel.Name = "ImageLabel"
	characterInfoShieldImageLabel.BackgroundTransparency = 1
	characterInfoShieldImageLabel.Image = "rbxassetid://84100549722129"
	characterInfoShieldImageLabel.Size = UDim2.fromScale(1, 1)

	local characterInfoShieldUIGradient = Instance.new("UIGradient")
	characterInfoShieldUIGradient.Name = "UIGradient"
	characterInfoShieldUIGradient.Parent = characterInfoShieldImageLabel

	characterInfoShieldImageLabel.Parent = characterInfoShieldbar

	return characterInfoShieldbar
end
