local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
-- Services
local TweenService = game:GetService("TweenService")
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
--
local WAIT_TIME = 3 -- Time to wait before fading out the loading screen
local FADE_OUT_DURATION = 0.4 -- Time for the fade-out tween

-- Listens to player adding event
local tpGui = TeleportService:GetArrivingTeleportGui()

local dataStoreLoadedConnection
local loaded = false
dataStoreLoadedConnection = Zap.PlayerDatastoreLoaded.On(function()
	loaded = true
	-- Disconnect the connection to avoid multiple triggers
	dataStoreLoadedConnection()
end)

if tpGui then
	ReplicatedFirst:RemoveDefaultLoadingScreen()
	tpGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	warn("Teleport GUI parented to PlayerGui:", tpGui.Parent)

	-- Wait for the game to load
	game.Loaded:Wait()

	-- Then wait for the data store to load its initial data
	while not loaded do
		task.wait(1) -- Wait for a short duration before checking again
	end

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
