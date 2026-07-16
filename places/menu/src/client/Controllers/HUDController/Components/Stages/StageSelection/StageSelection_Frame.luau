local Stages = require(game.ReplicatedStorage.Data.data_Stages)
local CreateStageCard = require(script.Parent.Stage_Card)
local CreateWorldCard = require(script.Parent.World_Card)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createStageList(worldId: string)
	local stageListFrame = Instance.new("Frame")
	stageListFrame.Name = "UI_" .. worldId .. "_StageList_Frame"
	stageListFrame.BackgroundTransparency = 1
	stageListFrame.Position = UDim2.fromScale(0.23, 0.185)
	stageListFrame.Size = UDim2.fromScale(0.75, 0.78)
	stageListFrame.Visible = false

	local selectedStageValue = Instance.new("StringValue")
	selectedStageValue.Name = "SelectedStage"
	selectedStageValue.Value = ""
	selectedStageValue.Parent = stageListFrame

	local stageListScrollingFrame = Instance.new("ScrollingFrame")
	stageListScrollingFrame.Name = "StageList_ScrollingFrame"
	stageListScrollingFrame.Active = true
	stageListScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
	stageListScrollingFrame.BackgroundTransparency = 1
	stageListScrollingFrame.CanvasSize = UDim2.fromScale(1.125, 0)
	stageListScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	stageListScrollingFrame.ScrollBarImageColor3 = Color3.new()
	stageListScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
	stageListScrollingFrame.Size = UDim2.fromScale(1, 1)

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingLeft = UDim.new(0, 16)
	uIPadding.PaddingRight = UDim.new(0, 16)
	uIPadding.Parent = stageListScrollingFrame

	local stageList = Instance.new("Frame")
	stageList.Name = "StageList_Frame"
	stageList.BackgroundTransparency = 1
	stageList.Size = UDim2.fromScale(1, 1)
	stageList.Parent = stageListScrollingFrame
	stageListScrollingFrame.Parent = stageListFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Padding = UDim.new(0, 16)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = stageList

	for stageKey, stageData in pairs(Stages[worldId].stages) do
		local stageCard = CreateStageCard.CreateStageCard(
			stageKey,
			worldId,
			stageData.name,
			stageData.description,
			stageData.stageOrder
		)
		stageCard.Parent = stageList
	end

	return stageListFrame
end

local function createWorldList()
	local worldListFrame = Instance.new("Frame")
	worldListFrame.Name = "UI_WorldList_Frame"
	worldListFrame.BackgroundTransparency = 1
	worldListFrame.Position = UDim2.fromScale(0.015, 0.23)
	worldListFrame.Size = UDim2.fromScale(0.21, 0.7)

	local selectedWorldValue = Instance.new("StringValue")
	selectedWorldValue.Name = "SelectedWorld"
	selectedWorldValue.Value = ""
	selectedWorldValue.Parent = worldListFrame

	local worldListScrollingFrame = Instance.new("ScrollingFrame")
	worldListScrollingFrame.Name = "WorldList_ScrollingFrame"
	worldListScrollingFrame.Active = true
	worldListScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	worldListScrollingFrame.BackgroundTransparency = 1
	worldListScrollingFrame.CanvasSize = UDim2.fromScale(0, 1.125)
	worldListScrollingFrame.ScrollBarImageColor3 = Color3.new()
	worldListScrollingFrame.ScrollBarImageTransparency = 1
	worldListScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	worldListScrollingFrame.Size = UDim2.fromScale(1, 1)
	worldListScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	worldListScrollingFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingBottom = UDim.new(0, 16)
	uIPadding.PaddingTop = UDim.new(0, 16)
	uIPadding.Parent = worldListScrollingFrame

	local worldList = Instance.new("Frame")
	worldList.Name = "WorldList"
	worldList.BackgroundTransparency = 1
	worldList.Size = UDim2.fromScale(1, 1)
	worldList.Parent = worldListScrollingFrame
	worldListScrollingFrame.Parent = worldListFrame

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.Padding = UDim.new(0, 16)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uIListLayout.Parent = worldList

	-- Create a stage folder
	local stagesFolder = Instance.new("Folder")
	stagesFolder.Name = "Stages"
	stagesFolder.Parent = playerGui:FindFirstChild("StageSelection_ScreenGui", true)

	local firstWorldId

	for worldKey, worldData in pairs(Stages) do
		local worldCard =
			CreateWorldCard.CreateWorldCard(worldKey, worldData.name, worldData.description, worldData.worldOrder)
		worldCard.Parent = worldList

		if worldData.worldOrder == 1 then
			firstWorldId = worldKey
		end

		-- Create a stage list for the world and add it to the world card
		local stageList = createStageList(worldKey)
		stageList.Parent = stagesFolder
	end

	-- Set the first world as selected by default
	local firstWorldCard = worldList:FindFirstChild("World_" .. firstWorldId .. "_OuterFrame", true)
	if firstWorldCard then
		CreateWorldCard.ToggleSelection(firstWorldCard.World_Frame, firstWorldId, true)
		selectedWorldValue.Value = firstWorldId
	end

	return worldListFrame
end

return {
	CreateWorldList = createWorldList,
	CreateStageList = createStageList,
}
