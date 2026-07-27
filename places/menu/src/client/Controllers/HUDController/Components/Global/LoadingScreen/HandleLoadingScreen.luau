-- Services
local TweenService = game:GetService("TweenService")
-- Components
local CreateLoadingScreen = require(script.Parent.LoadingScreen)
-- Packages
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Zap = require(StarterPlayerScripts.Client.zap)

return function()
	local loadingScreenGui = CreateLoadingScreen()
	loadingScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	loadingScreenGui.Enabled = true

	local loadingScreen = loadingScreenGui:WaitForChild("LoadingScreen_FullFrame")
	loadingScreen.Visible = true

	local loadingText = loadingScreen:WaitForChild("LoadingText")
	local minimumLoadingDuration = 4
	local maximumLoadingDuration = 20
	local minimumLoadingDurationReached = false
	local startTime = tick()
	local datastoreLoaded = false

	-- Dynamically update the loading text
	task.spawn(function()
		local Dots = {
			"LOADING IN PROGRESS.",
			"LOADING IN PROGRESS..",
			"LOADING IN PROGRESS...",
		}

		local Index = 1

		while not (minimumLoadingDurationReached and datastoreLoaded) do
			loadingText.Text = Dots[Index]

			Index += 1
			if Index > #Dots then
				Index = 1
			end

			task.wait(0.4)
		end
	end)

	-- Even if the datastore loads quickly, we want to ensure the loading screen is displayed for a minimum duration to avoid abrupt transitions.
	task.spawn(function()
		while not minimumLoadingDurationReached do
			if tick() - startTime >= minimumLoadingDuration then
				minimumLoadingDurationReached = true
				break
			end
			task.wait(0.05)
		end
	end)

	local dataStoreLoadedConn
	dataStoreLoadedConn = Zap.PlayerDatastoreLoaded.On(function()
		datastoreLoaded = true
		dataStoreLoadedConn()
	end)

	-- If the maximum loading duration is reached, kick the player to prevent them from being stuck on the loading screen indefinitely
	while not (minimumLoadingDurationReached and datastoreLoaded) do
		if tick() - startTime >= maximumLoadingDuration then
			game.Players.LocalPlayer:Kick("Loading failed. Please re-join the experience")
			break
		end

		task.wait(0.05)
	end

	if minimumLoadingDurationReached and datastoreLoaded then
		loadingText.Text = "PRESS ANY KEY TO CONTINUE"
	end

	-- Wait for a key press
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function()
		if not (minimumLoadingDurationReached and datastoreLoaded) then
			return
		end

		local fadeTween = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for _, object in pairs(loadingScreenGui:GetDescendants()) do
			if object:IsA("Frame") then
				TweenService:Create(object, fadeTween, {
					BackgroundTransparency = 1,
				}):Play()
			elseif object:IsA("TextLabel") then
				TweenService:Create(object, fadeTween, {
					TextTransparency = 1,
					BackgroundTransparency = 1,
				}):Play()
			elseif object:IsA("ImageLabel") then
				TweenService:Create(object, fadeTween, {
					ImageTransparency = 1,
					BackgroundTransparency = 1,
				}):Play()
			end
		end

		task.wait(1)

		-- Destroy the loading screen
		loadingScreen:Destroy()
	end)
end
