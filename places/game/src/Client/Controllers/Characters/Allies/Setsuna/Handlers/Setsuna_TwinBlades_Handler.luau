local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local Trove = require(rep.Packages.Trove)
--
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	targets: { _TYPES.Character }
)
	local originalCFrame = char.HumanoidRootPart.CFrame

	-- Offset the position be in front of the target
	local cframeToLerpTo = targets[1].HumanoidRootPart.CFrame
		* CFrame.new(0, 0, -6)
		* CFrame.Angles(0, math.rad(180), 0)
	warn("CFrame to lerp to: ", cframeToLerpTo)

	-- Create a tween to move the character to the position in front of the target
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Value = originalCFrame

	-- Tween the posValue
	TweenService:Create(cframeValue, tweenInfo, { Value = cframeToLerpTo }):Play()

	-- Return to the original position after reaching the "return" marker
	trove:Add(animationTrack:GetMarkerReachedSignal("return"):Connect(function()
		warn("Return marker reached, returning to original position")
		TweenService:Create(cframeValue, tweenInfo, { Value = originalCFrame }):Play()
	end))

	trove:Add(RunService.RenderStepped:Connect(function()
		-- Pivot the modelto the pos value
		char:PivotTo(cframeValue.Value)
	end))

	return 1
end
