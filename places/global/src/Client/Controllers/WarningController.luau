-- Services
local TweenService = game:GetService("TweenService")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
-- Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local WarningController = {}

function WarningController.OnStart()
	-- Listens to warning events
	Zap.Warning.On(function(warningEvent)
		WarningController.DisplayWarning(warningEvent.message)
	end)
end

local function createWarningLabel(message: string)
	local warningPopup = Instance.new("Frame")
	warningPopup.Name = "Warning_Popup"
	warningPopup.BackgroundColor3 = Color3.new(1, 1, 1)
	warningPopup.BorderColor3 = Color3.new()
	warningPopup.BorderSizePixel = 0
	warningPopup.ClipsDescendants = true
	warningPopup.Position = UDim2.fromScale(0.2, 0.2)
	warningPopup.Size = UDim2.fromScale(0.6, 0.05)
	warningPopup.BackgroundTransparency = 1
	warningPopup.ZIndex = 1000

	local warningBG = Instance.new("UIGradient")
	warningBG.Name = "Warning_BG"
	warningBG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new()),
		ColorSequenceKeypoint.new(1, Color3.new()),
	})
	warningBG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.35, 0.7),
		NumberSequenceKeypoint.new(0.805486, 0.70625),
		NumberSequenceKeypoint.new(1, 1),
	})
	warningBG.Parent = warningPopup

	local warningLabel = Instance.new("TextLabel")
	warningLabel.Name = "Warning_Label"
	warningLabel.BackgroundTransparency = 1
	warningLabel.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	warningLabel.Position = UDim2.fromScale(0.2, 0.2)
	warningLabel.Size = UDim2.fromScale(0.6, 0.6)
	warningLabel.Text = message
	warningLabel.TextColor3 = Color3.new(1, 1, 1)
	warningLabel.TextScaled = true
	warningLabel.Parent = warningPopup

	return warningPopup
end

--- Displays a warning message to the player
function WarningController.DisplayWarning(message: string)
	-- If there's already a warning label, remove it before creating a new one
	local playerGui = game.Players.LocalPlayer.PlayerGui
	local existingWarningLabel = playerGui:FindFirstChild("Warning_Popup", true)
	if existingWarningLabel then
		existingWarningLabel:Destroy()
	end

	-- Create a new warning label
	local warningPopup = createWarningLabel(message)
	local globalScreenGui = playerGui:FindFirstChild("Global_ScreenGui", true)
	warningPopup.Parent = globalScreenGui
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

return WarningController
