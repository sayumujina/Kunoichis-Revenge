local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local GetAvatarImageForCharacter =
	require(StarterPlayerScripts.Client.Controllers.HUDController.Helper.GetAvatarImageForCharacter)
-- Services
local TweenService = game:GetService("TweenService")

return function(charName: string, ultimateName: string)
	local ultimateFlashFrame = Instance.new("Frame")
	ultimateFlashFrame.Name = "UI_UltimateFlash_Frame"
	ultimateFlashFrame.BackgroundTransparency = 1
	ultimateFlashFrame.Position = UDim2.fromScale(0.58, 0.16)
	ultimateFlashFrame.Size = UDim2.fromScale(0.42, 0.35)
	ultimateFlashFrame.ZIndex = 2

	local ultimateFlash = Instance.new("ImageLabel")
	ultimateFlash.Name = "UltimateFlash"
	ultimateFlash.BackgroundTransparency = 1
	ultimateFlash.Image = "rbxassetid://113005762543741"
	ultimateFlash.Position = UDim2.fromScale(0, 0.65)
	ultimateFlash.Size = UDim2.fromScale(1, 1)

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.AspectRatio = 6
	uIAspectRatioConstraint.Parent = ultimateFlash

	ultimateFlash.Parent = ultimateFlashFrame

	local characterInfoAvatar = Instance.new("Frame")
	characterInfoAvatar.Name = "CharacterInfo_Avatar"
	characterInfoAvatar.BackgroundTransparency = 1
	characterInfoAvatar.Position = UDim2.fromScale(0.62, 0.18)
	characterInfoAvatar.Size = UDim2.fromScale(0.8, 0.8)

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImageLabel"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = GetAvatarImageForCharacter(charName)
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = characterInfoAvatar

	local uIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint1.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint1.Parent = characterInfoAvatar

	characterInfoAvatar.Parent = ultimateFlashFrame

	local ultimateNameLabel = Instance.new("TextLabel")
	ultimateNameLabel.Name = "UltimateName_Label"
	ultimateNameLabel.BackgroundTransparency = 1
	ultimateNameLabel.FontFace =
		Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	ultimateNameLabel.Position = UDim2.fromScale(0.04, 0.695)
	ultimateNameLabel.Size = UDim2.fromScale(0.57, 0.27)
	ultimateNameLabel.Text = ultimateName
	ultimateNameLabel.TextColor3 = Color3.new(1, 1, 1)
	ultimateNameLabel.TextScaled = true
	ultimateNameLabel.TextXAlignment = Enum.TextXAlignment.Right
	ultimateNameLabel.Parent = ultimateFlashFrame

	-- Tween the position of the flash frame from outside the screen
	local newPosition = ultimateFlashFrame.Position + UDim2.fromScale(ultimateFlashFrame.Size.X.Scale, 0)
	local oldPosition = ultimateFlashFrame.Position
	ultimateFlashFrame.Position = newPosition

	local posTween = TweenService:Create(
		ultimateFlashFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = oldPosition }
	)

	local reversePosTween = TweenService:Create(
		ultimateFlashFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = newPosition }
	)

	-- Create a frame that covers the entire screen to darken it
	local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
	local darkenFrame = Instance.new("Frame")
	darkenFrame.Name = "DarkenFrame"
	darkenFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	darkenFrame.BackgroundTransparency = 1
	darkenFrame.ZIndex = 1
	darkenFrame.Size = UDim2.fromScale(1, 1)
	darkenFrame.Parent = playerGui.Combat_ScreenGui

	-- Tween the darken frame's transparency to create a darkening effect
	local darkenTween = TweenService:Create(
		darkenFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.3 }
	)

	local reverseDarkenTween = TweenService:Create(
		darkenFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)

	posTween:Play()
	darkenTween:Play()
	task.delay(1.2, function()
		reversePosTween:Play()
		reverseDarkenTween:Play()
	end)

	return ultimateFlashFrame
end
