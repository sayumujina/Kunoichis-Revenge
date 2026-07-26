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
local SelectionState = require(script.Parent.SelectionState)
local CharacterSelectionFrame = require(
	StarterPlayerScripts.Client.Controllers.HUDController.Components.Stages.CharacterSelection.CharacterSelection_Frame
)
local campaignIcon = TopBarIcons.new()

--- Creates the campaign button in the top bar
local function createCampaignButton()
	-- Create a campaign icon
	campaignIcon:setImage(icons.menu.UI_Icons_Campaign)
	campaignIcon:setLabel("Campaign")
	campaignIcon:align("Right")
	campaignIcon:modifyTheme({ "IconLabel", "FontFace", Font.new("rbxasset://fonts/families/Balthazar.json") })
	SelectionState.Register(campaignIcon)
	campaignIcon.selected:Connect(function()
		SoundController.Play("Sound_UniversalClick")
		SelectionState.LockAll()

		-- Create a black screen
		CreateBlackScreen(0.6, nil, 0.4, function()
			-- Show the stage selection menu when the campaign icon is selected
			StageSelectionMenu.ToggleStageSelectionMenu(true)

			SelectionState.ApplySelectionLocks()
		end, nil)
	end)
	campaignIcon.deselected:Connect(function()
		SoundController.Play("Sound_UniversalClick")
		SelectionState.LockAll()

		-- Create a black screen
		CreateBlackScreen(0.6, nil, 0.4, function()
			-- Hide the character selection screen
			CharacterSelectionFrame.ExitCharacterSelection()

			-- Show the stage selection menu when the campaign icon is selected
			StageSelectionMenu.ToggleStageSelectionMenu(false)

			SelectionState.ApplySelectionLocks()
		end, nil)
	end)
end

--- Toggles the campaign button's selection state
--- @param select -- Whether to select or deselect the campaign button
local function toggleCampaignButton(select: boolean)
	if select then
		campaignIcon:select()
	else
		campaignIcon:deselect()
	end
end

return {
	CreateCampaignButton = createCampaignButton,
	ToggleCampaignButton = toggleCampaignButton,
}
