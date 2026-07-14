local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

-- Local player
local localPlayer = game:GetService("Players").LocalPlayer

local CameraController = {}

local CameraStates: {
	[_TYPES.RobloxPlayerType]: {
		sideToLookAt: "Playable" | "NPC",
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
-- Camera constants in the detailed combat info menu
local DETAILED_MENU_CAMERA_HEIGHT = 4.5 -- Height above the character
local DETAILED_MENU_CAMERA_Z_OFFSET = 16 -- Positive Z offset to position camera in front of the character
local DETAILED_MENU_CAMERA_X_OFFSET = 3 -- Positive X offset to position camera to the left of the character AFTER looking at the character
local DETAILED_MENU_CAMERA_FOV = 28

function CameraController.OnStart()
	-- Initalise camera state
	if not CameraStates[localPlayer] then
		CameraStates[localPlayer] = {
			sideToLookAt = "Playable",
		}
	end

	-- Set camera to Scriptable mode
	Camera.CameraType = Enum.CameraType.Scriptable
	print("CameraController started")

	-- Set the camera's field of view and initial position
	Camera.FieldOfView = CAMERA_FOV
	Camera.CFrame = CFrame.new(-12.526, 15.672, -15.471) * CFrame.Angles(math.rad(20), math.rad(-180), 0)
end

--- Look at the side of the battlefield based on the current camera state.
---
--- A kind reminder: the "side" that the camera looks at depends on the current side of the character.
--- So, if the character is an enemy, then the "LookAtNPC" function will look at THEIR ENEMIES, which are the player's allies
--- @param origin - The character to look at
--- @param selectedTargetIndex - The index of the selected target to look at
function CameraController.LookAtSide(origin: _TYPES.Character, selectedTargetIndex: number)
	local charSide = origin:GetAttribute("Side")
	local sideToLookAt = CameraStates[localPlayer].sideToLookAt

	if charSide == "Playable" then
		if sideToLookAt == "Playable" then
			CameraController.LookAtTheirSide(origin)
		else
			CameraController.LookAtOpposingSide(origin, selectedTargetIndex)
		end
	else
		-- If the character is an enemy, then the camera should look at the allies
		if sideToLookAt == "Playable" then
			CameraController.LookAtOpposingSide(origin, selectedTargetIndex)
		else
			CameraController.LookAtTheirSide(origin)
		end
	end
end

--- Look at the opposing side of the battlefield based on the character's side.
--- @param origin - The character to look at
--- @param selectedTargetIndex - The index of the selected target to look at
function CameraController.LookAtOpposingSide(origin: _TYPES.Character, selectedTargetIndex: number)
	-- Place the camera so that
	-- The origin is in the bottom left of the screen
	local folder
	local valuesMult = 1
	local anglesAddition = 0
	if origin:GetAttribute("Side") == "Playable" then
		folder = workspace.Characters.NPC
	elseif origin:GetAttribute("Side") == "NPC" then
		folder = workspace.Characters.Playable

		-- If the enemy is looking at the allies, some values are flipped
		valuesMult = -1
		anglesAddition = 180
	end

	-- 1. Get the CFrame of the origin looking at the target
	local originCFrame = origin.HumanoidRootPart.CFrame

	-- 2. Shift the camera to the left of the origin by ENEMIES_CAMERA_SIDE_OFFSET
	local cameraXPos = originCFrame.Position.X + ENEMIES_CAMERA_SIDE_OFFSET * valuesMult

	-- 3. Get the target in the middle as the point of focus
	local numberOfTargets = #folder:GetChildren()
	local middleIndex = math.ceil(numberOfTargets / 2)

	-- 4. Calculate the base camera Y rotation angle, looking from the origin to the middle index
	local cameraYRotation
	for _, target in pairs(folder:GetChildren()) do
		if target:GetAttribute("Index") == middleIndex then
			local lookAtCFrame = CFrame.lookAt(originCFrame.Position, target.HumanoidRootPart.Position)
			local _, YRotation, _ = lookAtCFrame:ToWorldSpace(lookAtCFrame):ToOrientation()
			cameraYRotation = YRotation + ENEMIES_CAMERA_Y_OFFSET + anglesAddition
			break
		end
	end

	-- 5. Calculate the camera's Y rotation based on the difference between the middle index and the selected index
	if middleIndex - selectedTargetIndex >= 0 then
		cameraYRotation = cameraYRotation
			+ ENEMIES_CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY * (middleIndex - selectedTargetIndex) * valuesMult
	else
		cameraYRotation = cameraYRotation
			- ENEMIES_CAMERA_Y_ROTATION_DIFFERENCE_PER_ENEMY * (selectedTargetIndex - middleIndex) * valuesMult
	end

	-- 6. Set the camera's Y position to be ENEMIES_CAMERA_HEIGHT above the origin
	local cameraYPos = originCFrame.Position.Y + ENEMIES_CAMERA_HEIGHT

	-- 7. Set the camera's Z position to be ENEMIES_CAMERA_Z_OFFSET away from the origin
	local cameraZPos = originCFrame.Position.Z + ENEMIES_CAMERA_Z_OFFSET * valuesMult

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

	-- 10. Set the FOV of the camera
	Camera.FieldOfView = CAMERA_FOV

	-- 11. Tween the camera's CFrame to look at the target
	TweenService:Create(
		Camera,
		TweenInfo.new(CAMERA_TWEEN_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ CFrame = newCameraCFrame }
	):Play()
end

--- Look at the side of the battlefield that the character is on.
--- @param origin - The character to look at
function CameraController.LookAtTheirSide(origin: _TYPES.Character)
	-- Place the camera so that all allies are in the view
	local folder
	local valuesMult = 1
	local anglesAddition = 0
	if origin:GetAttribute("Side") == "Playable" then
		folder = workspace.Characters.Playable
	else
		folder = workspace.Characters.NPC

		-- Some values are flipped if the character is an enemy
		valuesMult = -1
		anglesAddition = 180
	end

	-- 1. Get the origin of the target in the middle
	local numberOfTargets = #folder:GetChildren()
	local middleIndex = math.ceil(numberOfTargets / 2)
	local middleTarget
	for _, target in pairs(folder:GetChildren()) do
		if target:GetAttribute("Index") == middleIndex then
			middleTarget = target
			break
		end
	end

	-- 2. Place the camera in front of that target
	local cameraYPos = middleTarget.HumanoidRootPart.Position.Y + ALLIES_CAMERA_HEIGHT
	local cameraZPos = middleTarget.HumanoidRootPart.Position.Z + ALLIES_CAMERA_FRONT_OFFSET * valuesMult

	-- 3. Make the camera look at the target in the middle
	local newCameraCFrame = CFrame.lookAt(
		Vector3.new(middleTarget.HumanoidRootPart.Position.X, cameraYPos, cameraZPos),
		middleTarget.HumanoidRootPart.Position
	)

	-- 4. Set the FOV of the camera
	Camera.FieldOfView = CAMERA_FOV

	-- 5. Set the camera CFrame
	TweenService:Create(
		Camera,
		TweenInfo.new(CAMERA_TWEEN_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ CFrame = newCameraCFrame }
	):Play()
end

--- Look at the character in the detailed combat info menu.
--- @param char - The character to look at
function CameraController.LookAtCharacterInDetailedMenu(char: _TYPES.Character)
	local valuesMult = 1
	if char:GetAttribute("Side") == "NPC" then
		-- If the enemy is looking at the allies, some values are flipped
		valuesMult = -1
	end
	-- 1. Get the CFrame of the character
	local charCFrame = char.HumanoidRootPart.CFrame

	-- 2. Place the camera in front and above  the character
	local cameraYPos = charCFrame.Position.Y + DETAILED_MENU_CAMERA_HEIGHT
	local cameraZPos = charCFrame.Position.Z + DETAILED_MENU_CAMERA_Z_OFFSET * valuesMult

	-- 3. Set the FOV of the caemera
	Camera.FieldOfView = DETAILED_MENU_CAMERA_FOV

	-- 4. Set the camera's CFrame first and look at the character
	local newCameraCFrame =
		CFrame.lookAt(Vector3.new(charCFrame.Position.X, cameraYPos, cameraZPos), charCFrame.Position)

	-- 5. THEN, move the camera to the left of the character
	-- This is important, because we want the camera to go ahead first to look straight at the character first before moving to the left
	newCameraCFrame *= CFrame.new(DETAILED_MENU_CAMERA_X_OFFSET, 0, 0)

	-- 6. Tween the camera's CFrame and FOV to look at the character
	TweenService
		:Create(Camera, TweenInfo.new(CAMERA_TWEEN_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = newCameraCFrame,
		})
		:Play()
end

--- Sets the side of the battlefield to look at
--- @param side - The side to look at ("Playable" or "NPC")
function CameraController.SetSideToLookAt(side: "Playable" | "NPC")
	CameraStates[localPlayer].sideToLookAt = side
end

return CameraController
