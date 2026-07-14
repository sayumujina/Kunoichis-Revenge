local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local Trove = require(rep.Packages.Trove)

return function(
	trove: Trove.Trove,
	animationTrack: AnimationTrack,
	char: _TYPES.Character,
	attackData: _TYPES.AttackData
)
	return 2
end
