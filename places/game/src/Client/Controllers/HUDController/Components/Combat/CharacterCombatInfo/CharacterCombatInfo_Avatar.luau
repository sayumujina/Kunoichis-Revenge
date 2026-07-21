local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local TweenService = game:GetService("TweenService")
local GetAvatarImageForCharacter = require(rep.Shared.GlobalUtility.GetAvatarImageForCharacter)

--- Darkens the avatar image when the character is dead.
--- @param char The character to darken the avatar image for.
local function darkensAvatarImage(char: _TYPES.Character)
	-- Get the character info card for the character
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local characterInfoCard =
		playerGui:FindFirstChild("UI_CharacterInfoFrame", true):FindFirstChild("CharacterInfo_Card_" .. char.Name)

	if not characterInfoCard then
		return
	end

	local imageLabel = characterInfoCard:FindFirstChild("CharacterInfo_Avatar", true):FindFirstChild("ImageLabel")
	if not imageLabel then
		return
	end

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(imageLabel, tweenInfo, {
		ImageTransparency = 0.5,
	})
	tween:Play()
end

local function createCharacterCombatInfoAvatar(char: _TYPES.Character): Frame
	local avatar = Instance.new("Frame")
	avatar.Name = "CharacterInfo_Avatar"
	avatar.BackgroundTransparency = 1
	avatar.Position = UDim2.fromScale(0.03, 0)
	avatar.Size = UDim2.fromScale(0.63, 0.63)

	local avatarImageLabel = Instance.new("ImageLabel")
	avatarImageLabel.Name = "ImageLabel"
	avatarImageLabel.BackgroundTransparency = 1
	avatarImageLabel.Image = GetAvatarImageForCharacter(char.Name)
	avatarImageLabel.Size = UDim2.fromScale(1, 1)
	avatarImageLabel.Parent = avatar

	local avatarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	avatarAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	avatarAspectRatioConstraint.Parent = avatar

	local deadOverlay = Instance.new("Frame")
	deadOverlay.Name = "DeadOverlay"
	deadOverlay.Size = UDim2.fromScale(1, 1)
	deadOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	deadOverlay.BackgroundTransparency = 0.5
	deadOverlay.Visible = false
	deadOverlay.ZIndex = 10
	deadOverlay.Parent = avatarImageLabel

	return avatar
end

return {
	CreateCharacterCombatInfoAvatar = createCharacterCombatInfoAvatar,
	DarkensAvatarImage = darkensAvatarImage,
}
