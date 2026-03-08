local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
-- Packages
local rep = game:GetService("ReplicatedStorage")
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)
--
local localPlayer = game:GetService("Players").LocalPlayer

local CameraController = {}

-- Camera positioning constants
local CAMERA_DISTANCE = 25 -- 20-30 studs from battlefield center
local CAMERA_HEIGHT = 20 -- 15-25 studs above ground
local CAMERA_SIDE_OFFSET = -20 -- Negative X offset to position camera to the side

function CameraController.OnStart()
	-- Set camera to Scriptable mode
	Camera.CameraType = Enum.CameraType.Scriptable
	print("CameraController started")

	Camera.CFrame = CFrame.new(-12.526, 15.672, -15.471) * CFrame.Angles(math.rad(20), math.rad(-180), 0)
end

--- Look at a given CFrame (legacy function)
--- @param targetCFrame - The CFrame to look at
function CameraController.LookAtTarget(target: _TYPES.Character, origin: _TYPES.Character)
	-- CameraController.SetCombatCamera(origin, targets)
	-- Camera.CFrame = CFrame.lookAt(origin.HumanoidRootPart.Position, target.HumanoidRootPart.Position)
end

return CameraController
