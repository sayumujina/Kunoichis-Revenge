local SELECTION_COLOR = Color3.fromRGB(43, 26, 16)
local DEFAULT_COLOR = Color3.fromRGB(139, 111, 91)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local WarningController = require(StarterPlayerScripts.Client.GlobalControllers.WarningController)
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Services
local TweenService = game:GetService("TweenService")
--
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local tweens = {} :: { [string]: { tweens: Tween, visible: boolean } }

--- Toggles the selection state of a world card.
--- @param worldFrame -- The frame representing the world card.
--- @param isSelected -- A boolean indicating whether the world card is selected or not.
local function toggleSelection(worldFrame, worldId: string, isSelected: boolean)
	local stageListFolder = playerGui.StageSelection_ScreenGui:FindFirstChild("Stages")

	local function toggleStageListVisibility(stageListFrame, visible)
		if not stageListFrame then
			return
		end

		local excluded = { "StageList_Frame", "StageDesc_Frame" }

		-- Cancel any existing tweens to prevent overlapping animations
		for id, tweenList in pairs(tweens) do
			for _, tween in pairs(tweenList.tweens) do
				tween:Cancel()
			end

			local cancelledWorldIdFrame = stageListFolder:FindFirstChild("UI_" .. id .. "_StageList_Frame")
			if cancelledWorldIdFrame then
				cancelledWorldIdFrame.Visible = tweenList.visible
			end
		end

		-- Tween the visibility change for a smooth transition
		for _, child in pairs(stageListFrame:GetDescendants()) do
			if not child:IsA("Frame") and not child:IsA("TextLabel") or table.find(excluded, child.Name) then
				continue
			end

			if isSelected then
				stageListFrame.Visible = true
			end

			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tweenProperty = if child:IsA("Frame")
				then { BackgroundTransparency = visible and 0 or 1 }
				else { TextTransparency = visible and 0 or 1 }
			local tween = TweenService:Create(child, tweenInfo, tweenProperty)
			tweens[worldId] = { tweens = { tween }, visible = visible }
			tween:Play()

			tween.Completed:Connect(function()
				if not visible and next(tweens) == nil then
					warn("Hiding stage list frame for worldId: ", worldId)
					tweens[worldId] = nil
					stageListFrame.Visible = false
				end
			end)
		end
	end

	-- Change to selected color
	worldFrame.BackgroundColor3 = if isSelected then SELECTION_COLOR else DEFAULT_COLOR

	-- Hide the associated stage list for the previously selected world
	local stageListFrame = stageListFolder:FindFirstChild("UI_" .. worldId .. "_StageList_Frame")
	toggleStageListVisibility(stageListFrame, isSelected)
end

--- Creates a world card UI element with the given parameters.
--- @param id -- The unique identifier for the world.
--- @param name -- The display name of the world.
--- @param description -- A brief description of the world.
--- @param order -- The layout order for the world card.
local function createWorldCard(id: string, name: string, description: string, order: number, isUnlocked: boolean?)
	local worldOuterFrame = Instance.new("Frame")
	worldOuterFrame.Name = "World_" .. id .. "_OuterFrame"
	worldOuterFrame.BackgroundColor3 = Color3.fromRGB(78, 59, 49)
	worldOuterFrame.Size = UDim2.fromScale(0.94, 0.2)
	worldOuterFrame.LayoutOrder = order

	local associatedWorldId = Instance.new("StringValue")
	associatedWorldId.Name = "AssociatedWorldId"
	associatedWorldId.Value = id
	associatedWorldId.Parent = worldOuterFrame

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = worldOuterFrame

	local worldFrame = Instance.new("Frame")
	worldFrame.Name = "World_Frame"
	worldFrame.BackgroundColor3 = Color3.fromRGB(139, 111, 91)
	worldFrame.Position = UDim2.fromScale(0.01, 0.012)
	worldFrame.Size = UDim2.fromScale(0.98, 0.97)

	local worldIdFrame = Instance.new("Frame")
	worldIdFrame.Name = "WorldId_Frame"
	worldIdFrame.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	worldIdFrame.Size = UDim2.fromScale(1, 0.4)

	local uICorner1 = Instance.new("UICorner")
	uICorner1.Name = "UICorner"
	uICorner1.BottomLeftRadius = UDim.new(0, 12)
	uICorner1.BottomRightRadius = UDim.new(0, 12)
	uICorner1.CornerRadius = UDim.new(0, 12)
	uICorner1.TopLeftRadius = UDim.new(0, 12)
	uICorner1.TopRightRadius = UDim.new(0, 12)
	uICorner1.Parent = worldIdFrame

	local worldNameLabel = Instance.new("TextLabel")
	worldNameLabel.Name = "WorldName_Label"
	worldNameLabel.BackgroundTransparency = 1
	worldNameLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	worldNameLabel.Position = UDim2.fromScale(0.14, 0.1)
	worldNameLabel.Size = UDim2.fromScale(0.72, 0.8)
	worldNameLabel.Text = name
	worldNameLabel.TextColor3 = Color3.fromRGB(43, 26, 16)
	worldNameLabel.TextScaled = true
	worldNameLabel.Parent = worldIdFrame

	worldIdFrame.Parent = worldFrame

	local worldDescFrame = Instance.new("Frame")
	worldDescFrame.Name = "WorldDesc_Frame"
	worldDescFrame.BackgroundTransparency = 1
	worldDescFrame.Position = UDim2.fromScale(0.06, 0.4)
	worldDescFrame.Size = UDim2.fromScale(0.88, 0.6)

	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "UICorner"
	uICorner2.BottomLeftRadius = UDim.new(0, 12)
	uICorner2.BottomRightRadius = UDim.new(0, 12)
	uICorner2.CornerRadius = UDim.new(0, 12)
	uICorner2.TopLeftRadius = UDim.new(0, 12)
	uICorner2.TopRightRadius = UDim.new(0, 12)
	uICorner2.Parent = worldDescFrame

	local worldDescLabel = Instance.new("TextLabel")
	worldDescLabel.Name = "WorldDesc_Label"
	worldDescLabel.BackgroundTransparency = 1
	worldDescLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	worldDescLabel.Position = UDim2.fromScale(0, 0.02)
	worldDescLabel.Size = UDim2.fromScale(1, 1)
	worldDescLabel.Text = description
	worldDescLabel.TextColor3 = Color3.new(1, 1, 1)
	worldDescLabel.TextSize = 30
	worldDescLabel.TextWrapped = true
	worldDescLabel.Parent = worldDescFrame

	worldDescFrame.Parent = worldFrame

	local uICorner3 = Instance.new("UICorner")
	uICorner3.Name = "UICorner"
	uICorner3.BottomLeftRadius = UDim.new(0, 12)
	uICorner3.BottomRightRadius = UDim.new(0, 12)
	uICorner3.CornerRadius = UDim.new(0, 12)
	uICorner3.TopLeftRadius = UDim.new(0, 12)
	uICorner3.TopRightRadius = UDim.new(0, 12)
	uICorner3.Parent = worldFrame

	local invisibleButton = Instance.new("ImageButton")
	invisibleButton.Name = "InvisibleButton"
	invisibleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	invisibleButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	invisibleButton.ImageTransparency = 1
	invisibleButton.Size = UDim2.fromScale(1, 1)
	invisibleButton.ZIndex = 10
	invisibleButton.AutoButtonColor = false
	invisibleButton.Parent = worldOuterFrame
	invisibleButton.BackgroundTransparency = if isUnlocked then 1 else 0.4
	invisibleButton.MouseButton1Click:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		-- Handle the selection logic only if the world is unlocked
		if isUnlocked then
			-- Do nothing if this world is already selected
			local worldListFrame =
				game.Players.LocalPlayer.PlayerGui.StageSelection_ScreenGui:FindFirstChild("UI_WorldList_Frame")

			if not worldListFrame then
				return
			end

			local previouslySelectedWorldValue = worldListFrame:FindFirstChild("SelectedWorld")

			if previouslySelectedWorldValue then
				-- Do nothing if this world is already selected
				if previouslySelectedWorldValue.Value == id then
					return
				elseif previouslySelectedWorldValue.Value ~= "" then
					local previouslySelectedWorldCard = worldListFrame:FindFirstChild(
						"World_" .. previouslySelectedWorldValue.Value .. "_OuterFrame",
						true
					)
					toggleSelection(previouslySelectedWorldCard.World_Frame, previouslySelectedWorldValue.Value, false)
				end
			end

			-- Mark this world as selected
			toggleSelection(worldFrame, id, true)

			-- Update the SelectedWorld value
			previouslySelectedWorldValue.Value = id
		-- Create a warning popup if the world is locked
		else
			WarningController.DisplayWarning(false, "This world is locked.")
		end
	end)

	local uICorner4 = Instance.new("UICorner")
	uICorner4.Name = "UICorner"
	uICorner4.BottomLeftRadius = UDim.new(0, 12)
	uICorner4.BottomRightRadius = UDim.new(0, 12)
	uICorner4.CornerRadius = UDim.new(0, 12)
	uICorner4.TopLeftRadius = UDim.new(0, 12)
	uICorner4.TopRightRadius = UDim.new(0, 12)
	uICorner4.Parent = invisibleButton

	worldFrame.Parent = worldOuterFrame

	return worldOuterFrame
end

return {
	CreateWorldCard = createWorldCard,
	ToggleSelection = toggleSelection,
}
