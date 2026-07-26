-- Services
local TweenService = game:GetService("TweenService")
-- Components
local CreateLoadingScreen = require(script.Parent.LoadingScreen)

return function()
	local loadingScreenGui = CreateLoadingScreen()
	loadingScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	loadingScreenGui.Enabled = true

	local loadingScreen = loadingScreenGui:WaitForChild("LoadingScreen_FullFrame")
	loadingScreen.Visible = true

	local loadingText = loadingScreen:WaitForChild("LoadingText")
	local loadingDuration = 4
	local finished = false

	task.spawn(function()
		local Dots = {
			"LOADING IN PROGRESS.",
			"LOADING IN PROGRESS..",
			"LOADING IN PROGRESS...",
		}

		local Index = 1

		while not finished do
			loadingText.Text = Dots[Index]

			Index += 1
			if Index > #Dots then
				Index = 1
			end

			task.wait(0.4)
		end
	end)

	task.spawn(function()
		while not finished do
			task.wait(0.05)
		end
	end)

	task.wait(loadingDuration)

	finished = true

	loadingText.Text = "PRESS ANY KEY TO CONTINUE"

	-- Wait for a key press
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Once(function()
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
