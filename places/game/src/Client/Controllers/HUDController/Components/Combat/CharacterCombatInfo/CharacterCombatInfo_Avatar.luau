local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local GetAvatarImageForCharacter =
	require(StarterPlayerScripts.Client.Controllers.HUDController.Helper.GetAvatarImageForCharacter)

return function(charName: string): Frame
	local characterInfoAvatar = Instance.new("Frame")
	characterInfoAvatar.Name = "CharacterInfo_Avatar"
	characterInfoAvatar.BackgroundTransparency = 1
	characterInfoAvatar.Position = UDim2.fromScale(0.03, 0)
	characterInfoAvatar.Size = UDim2.fromScale(0.63, 0.63)

	local characterInfoAvatarImageLabel = Instance.new("ImageLabel")
	characterInfoAvatarImageLabel.Name = "ImageLabel"
	characterInfoAvatarImageLabel.BackgroundTransparency = 1
	characterInfoAvatarImageLabel.Image = GetAvatarImageForCharacter(charName)
	characterInfoAvatarImageLabel.Size = UDim2.fromScale(1, 1)
	characterInfoAvatarImageLabel.Parent = characterInfoAvatar

	local characterInfoAvatarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	characterInfoAvatarAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	characterInfoAvatarAspectRatioConstraint.Parent = characterInfoAvatar

	return characterInfoAvatar
end
