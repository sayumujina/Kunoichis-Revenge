local rep = game:GetService("ReplicatedStorage")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local SpawnController = require(StarterPlayerScripts.Client.Controllers.SpawnController)
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Components
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)
-- Services
local TeleportService = game:GetService("TeleportService")
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)

local RESTART_BUTTON_BG_COLOR = Color3.fromRGB(255, 255, 255)
local RESTART_BUTTON_TEXT_COLOR = Color3.fromRGB(0, 0, 0)
local RETURN_BUTTON_BG_COLOR = Color3.fromRGB(118, 118, 118)
local RETURN_BUTTON_TEXT_COLOR = Color3.fromRGB(255, 255, 255)

return function(buttonName: "Restart" | "Return")
	local button = Instance.new("TextButton")
	button.Name = buttonName .. "_Button"
	button.FontFace = Font.new("rbxasset://fonts/families/Balthazar.json")
	button.Position = UDim2.fromScale(0.5, 0)
	button.Size = UDim2.fromScale(0.4, 1)
	button.Text = buttonName
	button.BackgroundColor3 = buttonName == "Restart" and RESTART_BUTTON_BG_COLOR or RETURN_BUTTON_BG_COLOR
	button.TextColor3 = buttonName == "Restart" and RESTART_BUTTON_TEXT_COLOR or RETURN_BUTTON_TEXT_COLOR
	button.TextSize = 36
	button.TextWrapped = true
	button.ZIndex = 2
	button.AutoButtonColor = false
	--
	button.MouseButton1Click:Connect(function()
		if buttonName == "Restart" then
			SpawnController.Restart()
		elseif buttonName == "Return" then
			local blackScreenGui, forwardTween = CreateBlackScreen(0.6, nil, 0, function() end, nil, true)
			forwardTween.Completed:Once(function()
				TeleportService:SetTeleportGui(blackScreenGui)
				Zap.RequestReturnToMenu.Fire()
			end)
		end

		-- Play the button click sound effect
		SoundController.Play("Sound_UniversalClick")
	end)

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = button

	return button
end
