local Camera = workspace.CurrentCamera
-- Packages
local rep = game:GetService("ReplicatedStorage")
local Zap = require(game.StarterPlayer.StarterPlayerScripts.Client.zap)
--
local localPlayer = game:GetService("Players").LocalPlayer

local CameraController = {}

function CameraController.OnStart()
	-- Listen for spawn successful event
	Zap.SpawnSuccessful.On(function()
		-- warn("Spawn successful event received in CameraController")
		-- Camera.CameraType = Enum.CameraType.Scriptable

		-- -- Rotate the camera 180 degrees around the Y axis
		-- local currentCFrame = Camera.CFrame
		-- local rotation = CFrame.Angles(0, math.rad(180), 0)
		-- Camera.CFrame = currentCFrame * rotation
	end)
	print("CameraController started")
end

--- Look at a given target
function CameraController.LookAt(targetCFrame: CFrame)
	Camera.CFrame = CFrame.new(localPlayer.HumanoidRootPart.Position, targetCFrame.Position)
end

return CameraController
