local rep = game:GetService("ReplicatedStorage")
local icons = require(rep.Assets.Asphalt.Icons)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local HUDController = StarterPlayerScripts.Client.Controllers.HUDController
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Packages
local TopBarIcons = require(rep.Packages.topbarplus)
-- Components
local StageSelectionMenu = require(HUDController.Components.Stages.StageSelectionMenu)
local CreateBlackScreen = require(rep.Shared.GlobalUIComponents.BlackScreen)
local CharacterSelectionFrame = require(
	StarterPlayerScripts.Client.Controllers.HUDController.Components.Stages.CharacterSelection.CharacterSelection_Frame
)

return function()
	-- Create a campaign icon
	local campaignIcon = TopBarIcons.new()
	campaignIcon:setImage(icons.menu.UI_Icons_Campaign)
	campaignIcon:setLabel("Campaign")
	campaignIcon:align("Right")
	campaignIcon:modifyTheme({ "IconLabel", "FontFace", Font.new("rbxasset://fonts/families/Balthazar.json") })
	campaignIcon.selected:Connect(function()
		SoundController.Play("Sound_UniversalClick")
		-- Lock the icon
		campaignIcon:lock()

		-- Create a black screen
		CreateBlackScreen(0.6, nil, 0.4, function()
			-- Show the stage selection menu when the campaign icon is selected
			StageSelectionMenu.ToggleStageSelectionMenu(true)

			-- Unlock the icon after the black screen is done
			campaignIcon:unlock()
		end, nil)
	end)
	campaignIcon.deselected:Connect(function()
		SoundController.Play("Sound_UniversalClick")
		-- Hide the stage selection menu when the campaign icon is deselected
		-- Lock the icon
		campaignIcon:lock()

		-- Create a black screen
		CreateBlackScreen(0.6, nil, 0.4, function()
			-- Hide the character selection screen
			CharacterSelectionFrame.ExitCharacterSelection()

			-- Show the stage selection menu when the campaign icon is selected
			StageSelectionMenu.ToggleStageSelectionMenu(false)

			-- Unlock the icon after the black screen is done
			campaignIcon:unlock()
		end, nil)
	end)
end
