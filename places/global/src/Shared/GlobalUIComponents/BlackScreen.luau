local TweenService = game:GetService("TweenService")

-- Create a black frame that covers the entire screen
return function(
	fadeInDur: number,
	fadeDelay: number?,
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

	-- Create a tween to fade in the black frame
	local tweenInfo = TweenInfo.new(fadeInDur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local forwardTween = TweenService:Create(blackFrame, tweenInfo, { BackgroundTransparency = 0 })

	-- Create a tween to fade out the black frame
	local reverseTweenInfo = TweenInfo.new(fadeOutDur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local reverseTween = TweenService:Create(blackFrame, reverseTweenInfo, { BackgroundTransparency = 1 })
	reverseTween.Completed:Once(function()
		if onFadeOutComplete then
			onFadeOutComplete()
		end
		-- Remove the black frame after the fade-out is complete
		screenGui:Destroy()
	end)

	-- Play the forward tween to fade in the black frame
	forwardTween:Play()
	forwardTween.Completed:Once(function()
		if onFadeInComplete then
			onFadeInComplete()
		end

		-- Tween the black frame to fade out
		if manualReverseTween then
			return
		end

		if fadeDelay then
			task.delay(fadeDelay, function()
				reverseTween:Play()
			end)
		else
			reverseTween:Play()
		end
	end)

	return screenGui, forwardTween, reverseTween
end
