local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local Trove = require(rep.Packages.Trove)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
-- Move info
local moveInfo =
	require(game:GetService("ReplicatedStorage").Shared.Data.Characters.Enemies.MockEnemy.data_MockEnemy_Moves).Skill

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	attackData: _TYPES.AttackData
)
	CameraController.SetSideToLookAt(moveInfo.selectedSide)
	CameraController.LookAtSide(char, attackData.primaryTargetIndex)
	char.HumanoidRootPart.CFrame = attackData.targets[1].HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)

	return 2
end
