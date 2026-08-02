local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local Trove = require(rep.Packages.Trove)
-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
-- Move info
local moveInfo =
	require(game:GetService("ReplicatedStorage").Data.Characters.NPC.Red_MockEnemy.data_Red_MockEnemy_Moves).Skill

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	attackData: _TYPES.AttackData
)
	CameraController.SetSideToLookAt(moveInfo.selectedSide)
	CameraController.LookAtSide(char, attackData.primaryTargetIndex)
	local originalCFrame = char.HumanoidRootPart.CFrame

	-- Offset the position be in front of the target
	local middleTarget = attackData.targets[2]
	local defaultTarget = attackData.targets[1] -- In case the attack lands on 1 target only
	local cframeToLerpTo = if middleTarget
		then middleTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6) * CFrame.Angles(0, math.rad(180), 0)
		else defaultTarget.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6) * CFrame.Angles(0, math.rad(180), 0)
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
		char:PivotTo(originalCFrame)
	end)
	return 2
end
