local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Local player
local localPlayer = game:GetService("Players").LocalPlayer

local CameraController = {}

-- Camera positioning constants
local CAMERA_HEIGHT = 4.5 -- Height above the character
local CAMERA_SIDE_OFFSET = -9.2 -- Negative X offset to position camera to the side
local CAMERA_Z_OFFSET = -16 -- Negative Z offset to position camera behind the character
local CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY = 1
local CAMERA_Y_OFFSET = 190

function CameraController.OnStart()
	-- Set camera to Scriptable mode
	Camera.CameraType = Enum.CameraType.Scriptable
	print("CameraController started")

	Camera.CFrame = CFrame.new(-12.526, 15.672, -15.471) * CFrame.Angles(math.rad(20), math.rad(-180), 0)
end

--- Look at a given CFrame
--- @param targetCFrame - The CFrame to look at
function CameraController.LookAtEnemies(origin: _TYPES.Character, selectedTargetIndex: number)
	-- Place the camera so that
	-- The origin is in the bottom left of the screen

	-- 1. Get the CFrame of the origin looking at the target
	local originCFrame = origin.HumanoidRootPart.CFrame

	-- 2. Shift the camera to the left of the origin by CAMERA_SIDE_OFFSET
	local cameraXPos = originCFrame.Position.X + CAMERA_SIDE_OFFSET

	-- 3. Get the enemy in the middle as the point of focus
	local numberOfEnemies = #workspace.Characters.Enemies:GetChildren()
	local middleIndex = math.ceil(numberOfEnemies / 2)

	-- 4. Calculate the base camera Y rotation angle, looking from the origin to the middle index
	local cameraYRotation
	for _, enemy in pairs(workspace.Characters.Enemies:GetChildren()) do
		if enemy:GetAttribute("Index") == middleIndex then
			local lookAtCFrame = CFrame.lookAt(originCFrame.Position, enemy.HumanoidRootPart.Position)
			local _, YRotation, _ = lookAtCFrame:ToWorldSpace(lookAtCFrame):ToOrientation()
			warn("Y rotation:", YRotation)
			cameraYRotation = YRotation + CAMERA_Y_OFFSET
			break
		end
	end

	-- 5. Calculate the camera's Y rotation based on the difference between the middle index and the selected index
	if middleIndex - selectedTargetIndex >= 0 then
		cameraYRotation = cameraYRotation + CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY * (middleIndex - selectedTargetIndex)
	else
		cameraYRotation = cameraYRotation - CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY * (selectedTargetIndex - middleIndex)
	end

	warn(
		"Camera Y Rotation:",
		cameraYRotation,
		"middleIndex:",
		middleIndex,
		"selectedTargetIndex:",
		selectedTargetIndex
	)

	-- 6. Set the camera's Y position to be CAMERA_HEIGHT above the origin
	local cameraYPos = originCFrame.Position.Y + CAMERA_HEIGHT

	-- 7. Set the camera's Z position to be CAMERA_DISTANCE away from the origin
	local cameraZPos = originCFrame.Position.Z + CAMERA_Z_OFFSET

	-- 8. Create a new CFrame for the camera
	local newCameraCFrame = CFrame.new(Vector3.new(cameraXPos, cameraYPos, cameraZPos))
	newCameraCFrame = newCameraCFrame * CFrame.fromEulerAnglesYXZ(math.rad(-10), math.rad(cameraYRotation), math.rad(0))
	-- Set the camera's X position to be cameraXPos, but keep the Y and Z positions the same
	local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = newCameraCFrame:GetComponents()
	newCameraCFrame = CFrame.new(
		cameraXPos,
		newCameraCFrame.Position.Y,
		newCameraCFrame.Position.Z,
		r00,
		r01,
		r02,
		r10,
		r11,
		r12,
		r20,
		r21,
		r22
	)

	-- 9. Tween the camera's CFrame to look at the target
	TweenService:Create(Camera, TweenInfo.new(0.5), { CFrame = newCameraCFrame }):Play()
	-- Camera.CFrame = newCameraCFrame
	Camera.FieldOfView = 34
end

return CameraController
