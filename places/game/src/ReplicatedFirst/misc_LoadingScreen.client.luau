local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--
local TweenService = game:GetService("TweenService")
--
local WAIT_TIME = 1 -- Time to wait before fading out the loading screen
local FADE_OUT_DURATION = 0.4 -- Time for the fade-out tween

-- Listens to player adding event
local tpGui = TeleportService:GetArrivingTeleportGui()

if tpGui then
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	tpGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	warn("Teleport GUI parented to PlayerGui:", tpGui.Parent)

	-- Wait for the game to load, with 1 second on top before fading out
	game.Loaded:Wait()

	task.wait(WAIT_TIME)

	-- Tween the gui transparency back
	local reverseTweenInfo = TweenInfo.new(FADE_OUT_DURATION, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local blackFrame = tpGui:FindFirstChild("BlackFrame")
	if not blackFrame then
		return
	end
	local reverseTween = TweenService:Create(blackFrame, reverseTweenInfo, { BackgroundTransparency = 1 })
	reverseTween.Completed:Once(function()
		tpGui:Destroy()
	end)

	reverseTween:Play()
end
