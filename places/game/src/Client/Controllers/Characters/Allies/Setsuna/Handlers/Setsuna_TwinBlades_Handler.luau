local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

return function(animationTrack: AnimationTrack, char: _TYPES.Character, targets: { _TYPES.Character })
	-- Tween Setsuna's position to the enemy's position
	-- local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	-- local tween = game:GetService("TweenService"):Create(
	-- 	char.HumanoidRootPart,
	-- 	tweenInfo,
	-- 	{ CFrame = targets[1].HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) }
	-- )
	-- tween:Play()

	local originalPosition = char.HumanoidRootPart.CFrame
	char.HumanoidRootPart.CFrame = targets[1].HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)

	local connection
	connection = animationTrack.Stopped:Connect(function()
		-- After the animation is done, reset Setsuna's position to her original position
		char.HumanoidRootPart.CFrame = originalPosition
		connection:Disconnect()
	end)
end
