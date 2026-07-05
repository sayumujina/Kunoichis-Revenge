local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local Trove = require(rep.Packages.Trove)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Controllers = StarterPlayerScripts.Client.Controllers
local CameraController = require(Controllers.CameraController)

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	attackData: _TYPES.AttackData
)
	local target = attackData.targets[1]
	CameraController.LookAtSide(char, target:GetAttribute("Index") :: number)

	return 1
end
