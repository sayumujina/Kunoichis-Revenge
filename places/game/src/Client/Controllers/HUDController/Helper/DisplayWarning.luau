--
local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local TweenService = game:GetService("TweenService")
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local createWarningLabel =
	require(StarterPlayerScripts.Client.Controllers.HUDController.Components.Combat.Warning.Warning_Popup)
--

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return function(playerGui: PlayerGui, message: string)
	-- If there's already a warning label, remove it before creating a new one
	local existingWarningLabel = playerGui:FindFirstChild("Warning_Popup", true)
	if existingWarningLabel then
		existingWarningLabel:Destroy()
	end

	-- Create a new warning label
	local warningPopup = createWarningLabel(message)
	warningPopup.Parent = playerGui:FindFirstChild("ScreenGui").PlayerUI
	local warningLabel = warningPopup:FindFirstChild("Warning_Label")

	-- Tween the bg to fade out and move up
	local goal = { Position = UDim2.fromScale(0.2, 0.15), BackgroundTransparency = 0 }
	local tween = TweenService:Create(warningPopup, TWEEN_INFO, goal)
	tween:Play()

	-- Tween the warning label to fade out
	local labelGoal = { Position = UDim2.fromScale(0.2, 0.15), TextTransparency = 0 }
	local labelTween = TweenService:Create(warningLabel, TWEEN_INFO, labelGoal)
	labelTween:Play()

	-- Destroy the warning label after a delay to ensure it doesn't linger in the player's GUI
	task.delay(2, function()
		-- Tween the bg to fade out and move up
		local fadeOutTween = TweenService:Create(warningPopup, TWEEN_INFO, { BackgroundTransparency = 1 })
		fadeOutTween:Play()

		-- Tween the warning label to fade out
		local labelFadeOutTween = TweenService:Create(warningLabel, TWEEN_INFO, { TextTransparency = 1 })
		labelFadeOutTween:Play()

		--
		if warningLabel then
			warningLabel:Destroy()
		end
	end)
end
