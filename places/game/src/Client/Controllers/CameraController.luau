local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Local player
local localPlayer = game:GetService("Players").LocalPlayer

local CameraController = {}

local CameraStates: {
	[_TYPES.RobloxPlayerType]: {
		sideToLookAt: "Allies" | "Enemies",
	},
} = {}

-- Camera positioning constants
local CAMERA_FOV = 34
local CAMERA_TWEEN_DURATION = 0.3
-- Enemies camera positioning constants
local ENEMIES_CAMERA_HEIGHT = 4.5 -- Height above the character
local ENEMIES_CAMERA_SIDE_OFFSET = -9.2 -- Negative X offset to position camera to the side
local ENEMIES_CAMERA_Z_OFFSET = -16 -- Negative Z offset to position camera behind the character
local ENEMIES_CAMERA_X_ROTATION = -10
local ENEMIES_CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY = 1
local ENEMIES_CAMERA_Y_OFFSET = 190
-- Allies camera positioning constants
local ALLIES_CAMERA_HEIGHT = 4.5 -- Height above the character
local ALLIES_CAMERA_FRONT_OFFSET = 24 -- Positive Z offset to position camera in front of the character

function CameraController.OnStart()
	-- Initalise camera state
	if not CameraStates[localPlayer] then
		CameraStates[localPlayer] = {
			sideToLookAt = "Allies",
		}
	end

	-- Set camera to Scriptable mode
	Camera.CameraType = Enum.CameraType.Scriptable
	print("CameraController started")

	-- Set the camera's field of view and initial position
	Camera.FieldOfView = CAMERA_FOV
	Camera.CFrame = CFrame.new(-12.526, 15.672, -15.471) * CFrame.Angles(math.rad(20), math.rad(-180), 0)
end

--- Look at the side of the battlefield based on the current camera state
--- @param origin - The character to look at
--- @param selectedTargetIndex - The index of the selected target to look at
function CameraController.LookAtSide(origin: _TYPES.Character, selectedTargetIndex: number)
	if CameraStates[localPlayer].sideToLookAt == "Allies" then
		CameraController.LookAtAllies()
	else
		CameraController.LookAtEnemies(origin, selectedTargetIndex)
	end
end

--- Look at a given CFrame
--- @param targetCFrame - The CFrame to look at
function CameraController.LookAtEnemies(origin: _TYPES.Character, selectedTargetIndex: number)
	-- Place the camera so that
	-- The origin is in the bottom left of the screen

	-- 1. Get the CFrame of the origin looking at the target
	local originCFrame = origin.HumanoidRootPart.CFrame

	-- 2. Shift the camera to the left of the origin by ENEMIES_CAMERA_SIDE_OFFSET
	local cameraXPos = originCFrame.Position.X + ENEMIES_CAMERA_SIDE_OFFSET

	-- 3. Get the enemy in the middle as the point of focus
	local numberOfEnemies = #workspace.Characters.Enemies:GetChildren()
	local middleIndex = math.ceil(numberOfEnemies / 2)

	-- 4. Calculate the base camera Y rotation angle, looking from the origin to the middle index
	local cameraYRotation
	for _, enemy in pairs(workspace.Characters.Enemies:GetChildren()) do
		if enemy:GetAttribute("Index") == middleIndex then
			local lookAtCFrame = CFrame.lookAt(originCFrame.Position, enemy.HumanoidRootPart.Position)
			local _, YRotation, _ = lookAtCFrame:ToWorldSpace(lookAtCFrame):ToOrientation()
			cameraYRotation = YRotation + ENEMIES_CAMERA_Y_OFFSET
			break
		end
	end

	-- 5. Calculate the camera's Y rotation based on the difference between the middle index and the selected index
	if middleIndex - selectedTargetIndex >= 0 then
		cameraYRotation = cameraYRotation
			+ ENEMIES_CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY * (middleIndex - selectedTargetIndex)
	else
		cameraYRotation = cameraYRotation
			- ENEMIES_CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY * (selectedTargetIndex - middleIndex)
	end

	-- 6. Set the camera's Y position to be ENEMIES_CAMERA_HEIGHT above the origin
	local cameraYPos = originCFrame.Position.Y + ENEMIES_CAMERA_HEIGHT

	-- 7. Set the camera's Z position to be ENEMIES_CAMERA_Z_OFFSET away from the origin
	local cameraZPos = originCFrame.Position.Z + ENEMIES_CAMERA_Z_OFFSET

	-- 8. Create a new CFrame for the camera
	local newCameraCFrame = CFrame.new(Vector3.new(cameraXPos, cameraYPos, cameraZPos))
	newCameraCFrame = newCameraCFrame
		* CFrame.fromEulerAnglesYXZ(math.rad(ENEMIES_CAMERA_X_ROTATION), math.rad(cameraYRotation), math.rad(0))

	-- 9. Set the camera's X position to be cameraXPos, but keep the Y and Z positions the same
	-- I really CANNOT think of a better way to do this since camera position cannot be directly changed
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

	-- 10. Tween the camera's CFrame to look at the target
	TweenService:Create(
		Camera,
		TweenInfo.new(CAMERA_TWEEN_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ CFrame = newCameraCFrame }
	):Play()
end

function CameraController.LookAtAllies()
	-- Place the camera so that all allies are in the view

	-- 1. Get the origin of the ally in the middle
	local numberOfAllies = #workspace.Characters.Allies:GetChildren()
	local middleIndex = math.ceil(numberOfAllies / 2)
	local middleAlly
	for _, ally in pairs(workspace.Characters.Allies:GetChildren()) do
		if ally:GetAttribute("Index") == middleIndex then
			middleAlly = ally
			break
		end
	end

	-- 2. Place the camera in front of that ally
	local cameraYPos = middleAlly.HumanoidRootPart.Position.Y + ALLIES_CAMERA_HEIGHT
	local cameraZPos = middleAlly.HumanoidRootPart.Position.Z + ALLIES_CAMERA_FRONT_OFFSET

	-- 3. Make the camera look at the ally in the middle
	local newCameraCFrame = CFrame.lookAt(
		Vector3.new(middleAlly.HumanoidRootPart.Position.X, cameraYPos, cameraZPos),
		middleAlly.HumanoidRootPart.Position
	)

	-- 4. Set the camera CFrame
	TweenService:Create(
		Camera,
		TweenInfo.new(CAMERA_TWEEN_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ CFrame = newCameraCFrame }
	):Play()
end

--- Sets the side of the battlefield to look at
--- @param side - The side to look at ("Allies" or "Enemies")
function CameraController.SetSideToLookAt(side: "Allies" | "Enemies")
	CameraStates[localPlayer].sideToLookAt = side
end

return CameraController
