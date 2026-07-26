local rep = game:GetService("ReplicatedStorage")
local GetAvatarImageForCharacter = require(rep.Shared.GlobalUtility.GetAvatarImageForCharacter)

-- Services
local TweenService = game:GetService("TweenService")
--
local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)
-- Constants
local ULTIMATE_FLASH_OFFSET = UDim2.fromScale(-0.02, 0.02)

return function(charName: string, ultimateName: string)
	local ultimateFlashFrame = Instance.new("Frame")
	ultimateFlashFrame.Name = "UI_UltimateFlash_Frame"
	ultimateFlashFrame.BackgroundTransparency = 1
	ultimateFlashFrame.Position = UDim2.fromScale(0, 0.16)
	ultimateFlashFrame.Size = UDim2.fromScale(1, 0.35)
	ultimateFlashFrame.ZIndex = 2

	local flashRatio = Instance.new("UIAspectRatioConstraint")
	flashRatio.Name = "UIAspectRatioConstraint"
	flashRatio.AspectRatio = 6
	flashRatio.Parent = ultimateFlashFrame

	local ultimateFlash = Instance.new("ImageLabel")
	ultimateFlash.Name = "UltimateFlash"
	ultimateFlash.BackgroundTransparency = 1
	ultimateFlash.Image = ui.hud.Combat.UI_CombatHud_UltimateFlash
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
	characterInfoAvatar.Position = UDim2.fromScale(0.73, 0.02)
	characterInfoAvatar.Size = UDim2.fromScale(1.6, 1.6)

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
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	ultimateNameLabel.Position = UDim2.fromScale(0.04, 0.95)
	ultimateNameLabel.Size = UDim2.fromScale(0.7, 0.4)
	ultimateNameLabel.Text = ultimateName
	ultimateNameLabel.TextColor3 = Color3.new(1, 1, 1)
	ultimateNameLabel.TextScaled = true
	ultimateNameLabel.TextXAlignment = Enum.TextXAlignment.Right
	ultimateNameLabel.Parent = ultimateFlashFrame

	-- Tween the position of the flash frame from outside the screen
	local newPosition = ultimateFlashFrame.Position + ULTIMATE_FLASH_OFFSET
	local oldPosition = ultimateFlashFrame.Position
	ultimateFlashFrame.Position = newPosition

	local posTween = TweenService:Create(
		ultimateFlashFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{ Position = oldPosition }
	)

	local reverseTransparencyTweens = {}
	for _, child in pairs(ultimateFlashFrame:GetDescendants()) do
		if child:IsA("ImageLabel") then
			-- Tween the transparency of all children of the flash frame to make them visible
			local transparencyTween = TweenService:Create(
				child,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{ ImageTransparency = 0 }
			)

			-- Then store a reverse tween to make them invisible again after a delay
			local reverseTransparencyTween = TweenService:Create(
				child,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{ ImageTransparency = 1 }
			)

			table.insert(reverseTransparencyTweens, reverseTransparencyTween)
			transparencyTween:Play()
		elseif child:IsA("TextLabel") then
			-- Tween the transparency of all children of the flash frame to make them visible
			local transparencyTween = TweenService:Create(
				child,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{ TextTransparency = 0 }
			)

			-- Then store a reverse tween to make them invisible again after a delay
			local reverseTransparencyTween = TweenService:Create(
				child,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{ TextTransparency = 1 }
			)

			table.insert(reverseTransparencyTweens, reverseTransparencyTween)
			transparencyTween:Play()
		end
	end

	-- Create a frame that covers the entire screen to darken it
	local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
	local darkenFrame = Instance.new("Frame")
	darkenFrame.Name = "DarkenFrame"
	darkenFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	darkenFrame.BackgroundTransparency = 1
	darkenFrame.ZIndex = 1
	darkenFrame.Size = UDim2.fromScale(1, 1)
	darkenFrame.Parent = playerGui.Ultimate_ScreenGui

	-- Tween the darken frame's transparency to create a darkening effect
	local darkenTween = TweenService:Create(
		darkenFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.1 }
	)

	local reverseDarkenTween = TweenService:Create(
		darkenFrame,
		TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)

	posTween:Play()
	darkenTween:Play()
	task.delay(0.6, function()
		reverseDarkenTween:Play()
		for _, reverseTween in pairs(reverseTransparencyTweens) do
			reverseTween:Play()
		end
		task.delay(0.6, function()
			darkenFrame:Destroy()
		end)
	end)

	return ultimateFlashFrame
end
