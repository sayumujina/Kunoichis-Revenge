local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local Trove = require(rep.Packages.Trove)
-- Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	attackData: _TYPES.AttackData
)
	local originalCFrame = char.HumanoidRootPart.CFrame

	-- Offset the position be in front of the middle target
	local cframeToLerpTo = attackData.targets[2].HumanoidRootPart.CFrame
		* CFrame.new(0, 0, -6)
		* CFrame.Angles(0, math.rad(180), 0)

	-- Create a tween to move the character to the position in front of the target
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Value = originalCFrame

	-- Tween the posValue
	TweenService:Create(cframeValue, tweenInfo, { Value = cframeToLerpTo }):Play()

	-- Return to the original position after reaching the "return" marker
	trove:Add(animationTrack:GetMarkerReachedSignal("return"):Connect(function()
		TweenService:Create(cframeValue, tweenInfo, { Value = originalCFrame }):Play()
	end))

	trove:Add(RunService.RenderStepped:Connect(function()
		-- Pivot the modelto the pos value
		char:PivotTo(cframeValue.Value)
	end))

	-- In case the animation is stopped before reaching the "return" marker, return to the original position on trove end
	trove:Add(function()
		warn("Tsuyoka_DestructiveCriticism_Handler trove ended, returning to original position")
		char:PivotTo(originalCFrame)
	end)

	return 2
end
