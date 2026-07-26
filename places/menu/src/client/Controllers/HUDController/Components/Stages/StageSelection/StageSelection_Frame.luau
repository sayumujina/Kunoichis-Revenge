local Stages = require(game.ReplicatedStorage.Data.data_Stages)
local CreateStageCard = require(script.Parent.Stage_Card)
local CreateWorldCard = require(script.Parent.World_Card)
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--- Creates a stage selection menu UI with the given unlocked world data and owned characters.
--- @param unlockedWorldData -- A table containing the unlocked world data.
--- @param ownedCharacters -- A table containing the owned characters data.
local function createStageList(worldId: string, unlockedStages: { string })
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
			stageData.stageOrder,
			table.find(unlockedStages, stageKey) and true or false -- Whether the stage is unlocked or not
		)
		stageCard.Parent = stageList
	end

	return stageListFrame
end

local function populateWorldList(worldListFrame: Frame, unlockedWorlds: { [string]: { stages: { string } } })
	local selectedWorldValue = worldListFrame:FindFirstChild("SelectedWorld") :: StringValue
	local previousSelectedWorldId = selectedWorldValue and selectedWorldValue.Value or ""
	local previousSelectedStages = {}

	local stageSelectionGui = playerGui:FindFirstChild("StageSelection_ScreenGui", true)
	if not stageSelectionGui then
		return
	end

	local existingStagesFolder = stageSelectionGui:FindFirstChild("Stages")
	if existingStagesFolder then
		for _, stageListFrame in existingStagesFolder:GetChildren() do
			if not stageListFrame:IsA("Frame") then
				continue
			end

			local worldId = stageListFrame.Name:match("^UI_(.+)_StageList_Frame$")
			local selectedStageValue = stageListFrame:FindFirstChild("SelectedStage")
			if worldId and selectedStageValue and selectedStageValue:IsA("StringValue") then
				previousSelectedStages[worldId] = selectedStageValue.Value
			end
		end

		existingStagesFolder:Destroy()
	end

	local worldListScrollingFrame = worldListFrame:FindFirstChild("WorldList_ScrollingFrame")
	local worldList = worldListScrollingFrame and worldListScrollingFrame:FindFirstChild("WorldList")
	if not worldList then
		return
	end

	for _, child in worldList:GetChildren() do
		if child:IsA("Frame") and child.Name:match("^World_.+_OuterFrame$") then
			child:Destroy()
		end
	end

	local stagesFolder = Instance.new("Folder")
	stagesFolder.Name = "Stages"
	stagesFolder.Parent = stageSelectionGui

	local firstUnlockedWorldId
	local firstWorldId

	for worldKey, worldData in pairs(Stages) do
		local worldCard = CreateWorldCard.CreateWorldCard(
			worldKey,
			worldData.name,
			worldData.description,
			worldData.worldOrder,
			unlockedWorlds[worldKey] ~= nil
		)
		worldCard.Parent = worldList

		if not firstWorldId or worldData.worldOrder < Stages[firstWorldId].worldOrder then
			firstWorldId = worldKey
		end

		if
			unlockedWorlds[worldKey]
			and (not firstUnlockedWorldId or worldData.worldOrder < Stages[firstUnlockedWorldId].worldOrder)
		then
			firstUnlockedWorldId = worldKey
		end

		if not unlockedWorlds[worldKey] then
			continue
		end

		local stageList = createStageList(worldKey, unlockedWorlds[worldKey].stages)
		stageList.Parent = stagesFolder

		local previousSelectedStage = previousSelectedStages[worldKey]
		if previousSelectedStage and table.find(unlockedWorlds[worldKey].stages, previousSelectedStage) then
			local selectedStageValue = stageList:FindFirstChild("SelectedStage")
			if selectedStageValue and selectedStageValue:IsA("StringValue") then
				selectedStageValue.Value = previousSelectedStage
			end
		end
	end

	selectedWorldValue.Value = ""

	local nextSelectedWorldId = previousSelectedWorldId
	if nextSelectedWorldId == "" or not unlockedWorlds[nextSelectedWorldId] then
		nextSelectedWorldId = firstUnlockedWorldId or firstWorldId or ""
	end

	if nextSelectedWorldId == "" then
		return
	end

	local selectedWorldCard = worldList:FindFirstChild("World_" .. nextSelectedWorldId .. "_OuterFrame", true)
	if selectedWorldCard then
		CreateWorldCard.ToggleSelection(selectedWorldCard.World_Frame, nextSelectedWorldId, true)
		selectedWorldValue.Value = nextSelectedWorldId
	end
end

--- Creates a stage selection menu UI with the given unlocked world data and owned characters.
--- @param unlockedWorldData -- A table containing the unlocked world data.
--- @param ownedCharacters -- A table containing the owned characters data.
local function createWorldList(unlockedWorlds: { [string]: { stages: { string } } }, unlockedChars: { string })
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

	populateWorldList(worldListFrame, unlockedWorlds)

	return worldListFrame
end

return {
	CreateWorldList = createWorldList,
	CreateStageList = createStageList,
	RefreshWorldList = populateWorldList,
}
