local rep = game:GetService("ReplicatedStorage")
local icons = require(rep.Assets.Asphalt.Icons)
-- Services
local TeleportService = game:GetService("TeleportService")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Packages
local TopBarIcons = require(rep.Packages.topbarplus)
local Zap = require(StarterPlayerScripts.Client.zap)
-- Components
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)

--- Creates the campaign button in the top bar
return function()
	local returnToMenuIcon = TopBarIcons.new()
	returnToMenuIcon:setLabel("Return to Menu")
	returnToMenuIcon:align("Right")
	returnToMenuIcon:modifyTheme({ "IconLabel", "FontFace", Font.new("rbxasset://fonts/families/Balthazar.json") })
	returnToMenuIcon.selected:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		local blackScreenGui, forwardTween = CreateBlackScreen(0.6, nil, 0, function() end, nil, true)
		forwardTween.Completed:Once(function()
			TeleportService:SetTeleportGui(blackScreenGui)
			Zap.RequestReturnToMenu.Fire()
		end)
	end)
end
