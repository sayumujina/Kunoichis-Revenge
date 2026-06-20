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

	char.HumanoidRootPart.CFrame = targets[1].HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
end
