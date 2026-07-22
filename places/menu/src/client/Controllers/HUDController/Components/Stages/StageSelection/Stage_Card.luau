-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local WarningController = require(StarterPlayerScripts.Client.GlobalControllers.WarningController)
-- Components
local CreateBlackScreen = require(game.ReplicatedStorage.Shared.GlobalUIComponents.BlackScreen)

local FADE_IN_DURATION = 0.6
local FADE_OUT_DURATION = 0.4

--- Creates a stage card UI element with the given parameters.
--- @param id -- The unique identifier for the stage.
--- @param name -- The display name of the stage.
--- @param description -- A brief description of the stage.
--- @param order -- The layout order for the stage card.
local function createStageCard(
	id: string,
	worldId: string,
	name: string,
	description: string,
	order: number,
	isUnlocked: boolean
)
	local stageOuterFrame = Instance.new("Frame")
	stageOuterFrame.Name = "Stage" .. id .. "_OuterFrame"
	stageOuterFrame.BackgroundColor3 = Color3.fromRGB(78, 59, 49)
	stageOuterFrame.Size = UDim2.fromScale(0.23, 0.93)
	stageOuterFrame.LayoutOrder = order
	stageOuterFrame.BackgroundTransparency = 1

	local associatedStageId = Instance.new("StringValue")
	associatedStageId.Name = "AssociatedStageId"
	associatedStageId.Value = id
	associatedStageId.Parent = stageOuterFrame

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = stageOuterFrame

	local stageFrame = Instance.new("Frame")
	stageFrame.Name = "Stage_Frame"
	stageFrame.BackgroundColor3 = Color3.fromRGB(139, 111, 91)
	stageFrame.Position = UDim2.fromScale(0.015, 0.005)
	stageFrame.Size = UDim2.fromScale(0.97, 0.99)
	stageFrame.BackgroundTransparency = 1

	local nameFrame = Instance.new("Frame")
	nameFrame.Name = "StageName_Frame"
	nameFrame.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	nameFrame.Size = UDim2.fromScale(1, 0.15)
	nameFrame.BackgroundTransparency = 1

	local uICorner1 = Instance.new("UICorner")
	uICorner1.Name = "UICorner"
	uICorner1.BottomLeftRadius = UDim.new(0, 12)
	uICorner1.BottomRightRadius = UDim.new(0, 12)
	uICorner1.CornerRadius = UDim.new(0, 12)
	uICorner1.TopLeftRadius = UDim.new(0, 12)
	uICorner1.TopRightRadius = UDim.new(0, 12)
	uICorner1.Parent = nameFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "StageName_Label"
	nameLabel.BackgroundTransparency = 1
	nameLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	nameLabel.Position = UDim2.fromScale(0.12, 0.21)
	nameLabel.Size = UDim2.fromScale(0.72, 0.6)
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(43, 26, 16)
	nameLabel.TextScaled = true
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = nameFrame

	nameFrame.Parent = stageFrame

	local descFrame = Instance.new("Frame")
	descFrame.Name = "StageDesc_Frame"
	descFrame.BackgroundTransparency = 1
	descFrame.Position = UDim2.fromScale(0.06, 0.15)
	descFrame.Size = UDim2.fromScale(0.88, 0.75)
	descFrame.BackgroundTransparency = 1

	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "UICorner"
	uICorner2.BottomLeftRadius = UDim.new(0, 12)
	uICorner2.BottomRightRadius = UDim.new(0, 12)
	uICorner2.CornerRadius = UDim.new(0, 12)
	uICorner2.TopLeftRadius = UDim.new(0, 12)
	uICorner2.TopRightRadius = UDim.new(0, 12)
	uICorner2.Parent = descFrame

	local stageDescLabel = Instance.new("TextLabel")
	stageDescLabel.Name = "StageDesc_Label"
	stageDescLabel.BackgroundTransparency = 1
	stageDescLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	stageDescLabel.Position = UDim2.fromScale(0, 0.02)
	stageDescLabel.Size = UDim2.fromScale(1, 1)
	stageDescLabel.Text = description
	stageDescLabel.TextColor3 = Color3.new(1, 1, 1)
	stageDescLabel.TextSize = 50
	stageDescLabel.TextWrapped = true
	stageDescLabel.TextYAlignment = Enum.TextYAlignment.Top
	stageDescLabel.Parent = descFrame
	stageDescLabel.BackgroundTransparency = 1

	descFrame.Parent = stageFrame

	local uICorner3 = Instance.new("UICorner")
	uICorner3.Name = "UICorner"
	uICorner3.BottomLeftRadius = UDim.new(0, 12)
	uICorner3.BottomRightRadius = UDim.new(0, 12)
	uICorner3.CornerRadius = UDim.new(0, 12)
	uICorner3.TopLeftRadius = UDim.new(0, 12)
	uICorner3.TopRightRadius = UDim.new(0, 12)
	uICorner3.Parent = stageFrame

	local invisibleButton = Instance.new("ImageButton")
	invisibleButton.Name = "InvisibleButton"
	invisibleButton.BackgroundTransparency = if isUnlocked then 1 else 0.4
	invisibleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	invisibleButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	invisibleButton.ImageTransparency = 1
	invisibleButton.Size = UDim2.fromScale(1, 1)
	invisibleButton.ZIndex = 10
	invisibleButton.AutoButtonColor = false
	invisibleButton.Parent = stageOuterFrame
	-- Clicking on the stage card will show set the selected stage value and show the character selection screen
	invisibleButton.MouseButton1Click:Connect(function()
		if isUnlocked then
			local playerGui = game.Players.LocalPlayer.PlayerGui
			local stageListFolder = playerGui.StageSelection_ScreenGui:FindFirstChild("Stages")
			local stageListFrame = stageListFolder:FindFirstChild("UI_" .. worldId .. "_StageList_Frame")

			-- Set the selected stage value in the stage list frame
			local selectedStageValue = stageListFrame:FindFirstChild("SelectedStage")
			if selectedStageValue then
				selectedStageValue.Value = id
			end

			CreateBlackScreen(FADE_IN_DURATION, nil, FADE_OUT_DURATION, function()
				-- Hide the stage lists and world list
				for _, child in pairs(stageListFolder:GetChildren()) do
					if child:IsA("Frame") then
						child.Visible = false
					end
				end
				playerGui.StageSelection_ScreenGui:FindFirstChild("UI_WorldList_Frame").Visible = false

				-- Show the character selection screen
				local characterSelectionFrame =
					playerGui.StageSelection_ScreenGui:FindFirstChild("UI_StageCharacterSelection_Frame")
				if characterSelectionFrame then
					characterSelectionFrame.Visible = true
				end
			end, function()
				-- Do nothing after fade out is complete
			end)
		else
			WarningController.DisplayWarning("This stage is locked.")
		end
	end)

	stageFrame.Parent = stageOuterFrame

	return stageOuterFrame
end

return {
	CreateStageCard = createStageCard,
}
