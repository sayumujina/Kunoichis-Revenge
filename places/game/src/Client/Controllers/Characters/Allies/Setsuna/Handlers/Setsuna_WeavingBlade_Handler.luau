local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)

return function(animationTrack: AnimationTrack, char: _TYPES.Character, targets: { _TYPES.Character })
	-- Tween Setsuna's position to the enemy's position
	-- local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	-- local tween =
	-- 	game:GetService("TweenService")
	-- 		:Create(char.PrimaryPart, tweenInfo, { CFrame = targets[1].HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) })
	-- tween:Play()

	local originalCFrame = char.HumanoidRootPart.CFrame
	local target = targets[1]
	local targetCFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6)
	char:PivotTo(CFrame.lookAt(targetCFrame.Position, target.HumanoidRootPart.Position))

	-- Return to her original position when the animation is complete
	animationTrack.Stopped:Connect(function()
		char:PivotTo(originalCFrame)
	end)
end
