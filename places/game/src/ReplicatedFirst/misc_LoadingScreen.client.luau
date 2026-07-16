local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--
local TweenService = game:GetService("TweenService")

-- Listens to player adding event
local tpGui = TeleportService:GetArrivingTeleportGui()
warn("Teleport GUI:", tpGui)

if tpGui then
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	tpGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	warn("Teleport GUI parented to PlayerGui:", tpGui.Parent)

	game.Loaded:Wait()

	task.wait(1)

	-- Tween the gui transparency back
	local reverseTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local blackFrame = tpGui:FindFirstChild("BlackFrame")
	warn(tpGui:FindFirstChild("BlackFrame"))
	if not blackFrame then
		warn("BlackFrame not found in Teleport GUI")
		return
	end
	local reverseTween = TweenService:Create(blackFrame, reverseTweenInfo, { BackgroundTransparency = 1 })
	reverseTween.Completed:Once(function()
		warn("Teleport GUI fade-out complete. Destroying Teleport GUI.")
		tpGui:Destroy()
	end)

	reverseTween:Play()
end
