local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local Trove = require(rep.Packages.Trove)

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	targets: { _TYPES.Character }
)
	-- Tween Setsuna's position to the enemy's position
	-- local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	-- local tween = game:GetService("TweenService"):Create(
	-- 	char.HumanoidRootPart,
	-- 	tweenInfo,
	-- 	{ CFrame = targets[1].HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) }
	-- )
	-- tween:Play()

	char.HumanoidRootPart.CFrame = targets[1].HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)

	return 2
end
