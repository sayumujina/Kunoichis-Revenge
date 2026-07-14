local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local Trove = require(rep.Packages.Trove)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
-- Move info
local moveInfo =
	require(game:GetService("ReplicatedStorage").Data.Characters.NPC.MockEnemy.data_MockEnemy_Moves).BasicAttack

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	attackData: _TYPES.AttackData
)
	CameraController.SetSideToLookAt(moveInfo.selectedSide)
	CameraController.LookAtSide(char, attackData.primaryTargetIndex)

	local originalCFrame = char.HumanoidRootPart.CFrame
	local target = attackData.targets[1]
	local targetCFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6)
	char:PivotTo(CFrame.lookAt(targetCFrame.Position, target.HumanoidRootPart.Position))

	-- Return to her original position when the animation is complete
	animationTrack.Stopped:Connect(function()
		char:PivotTo(originalCFrame)
	end)

	return 2
end
