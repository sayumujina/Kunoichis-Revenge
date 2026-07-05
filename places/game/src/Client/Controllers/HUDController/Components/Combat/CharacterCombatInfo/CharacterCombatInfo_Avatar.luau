local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local GetAvatarImageForCharacter =
	require(StarterPlayerScripts.Client.Controllers.HUDController.Helper.GetAvatarImageForCharacter)

return function(charName: string): Frame
	local avatar = Instance.new("Frame")
	avatar.Name = "CharacterInfo_Avatar"
	avatar.BackgroundTransparency = 1
	avatar.Position = UDim2.fromScale(0.03, 0)
	avatar.Size = UDim2.fromScale(0.63, 0.63)

	local avatarImageLabel = Instance.new("ImageLabel")
	avatarImageLabel.Name = "ImageLabel"
	avatarImageLabel.BackgroundTransparency = 1
	avatarImageLabel.Image = GetAvatarImageForCharacter(charName)
	avatarImageLabel.Size = UDim2.fromScale(1, 1)
	avatarImageLabel.Parent = avatar

	local avatarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	avatarAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	avatarAspectRatioConstraint.Parent = avatar

	return avatar
end
