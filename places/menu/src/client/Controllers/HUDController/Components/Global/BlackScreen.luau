local TweenService = game:GetService("TweenService")

-- Create a black frame that covers the entire screen
return function(
	fadeInDur: number,
	fadeOutDur: number,
	onFadeInComplete: () -> ()?,
	onFadeOutComplete: () -> ()?,
	manualReverseTween: boolean?
)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BlackScreen_ScreenGui"
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	screenGui.DisplayOrder = 100
	screenGui.IgnoreGuiInset = true

	local blackFrame = Instance.new("Frame")
	blackFrame.Name = "BlackFrame"
	blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	blackFrame.Size = UDim2.fromScale(1, 1)
	blackFrame.BackgroundTransparency = 1
	blackFrame.ZIndex = 100
	blackFrame.Parent = screenGui

	-- Tween the black frame to fade in
	local tweenInfo = TweenInfo.new(fadeInDur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local forwardTween = TweenService:Create(blackFrame, tweenInfo, { BackgroundTransparency = 0 })
	warn("Tweening black frame to fade in with duration:", fadeInDur, "and fade out with duration:", fadeOutDur)
	forwardTween:Play()

	forwardTween.Completed:Once(function()
		if onFadeInComplete then
			onFadeInComplete()
		end

		-- Tween the black frame to fade out
		if manualReverseTween then
			return
		end
		local reverseTweenInfo = TweenInfo.new(fadeOutDur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local reverseTween = TweenService:Create(blackFrame, reverseTweenInfo, { BackgroundTransparency = 1 })
		reverseTween:Play()

		reverseTween.Completed:Once(function()
			if onFadeOutComplete then
				onFadeOutComplete()
			end
			-- Remove the black frame after the fade-out is complete
			screenGui:Destroy()
		end)
	end)

	return screenGui, forwardTween
end
