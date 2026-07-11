local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)

local STATS_TO_CHECK = {
	["atk"] = { index = 1, name = "ATK" },
	["def"] = { index = 2, name = "DEF" },
	["spd"] = { index = 3, name = "SPD" },
	["critRate"] = { index = 4, name = "Crit Rate" },
	["critDmg"] = { index = 5, name = "Crit DMG" },
	["ultimateGainEfficiency"] = { index = 6, name = "Ultimate Gain Efficiency" },
	["manaGainEfficiency"] = { index = 7, name = "Mana Gain Efficiency" },
}

local function createStatFrame(statKey: string, statName: string, order: number)
	local statFrame = Instance.new("Frame")
	statFrame.Name = "DetailedStat_" .. statName .. "_Frame"
	statFrame.BackgroundColor3 = Color3.fromRGB(185, 185, 185)
	statFrame.BackgroundTransparency = 0.7
	statFrame.Size = UDim2.fromScale(0.9, 0.114)
	statFrame.LayoutOrder = order

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.Parent = statFrame

	local statNameLabel = Instance.new("TextLabel")
	statNameLabel.Name = "StatName_Label"
	statNameLabel.BackgroundTransparency = 1
	statNameLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	statNameLabel.Position = UDim2.fromScale(0.03, 0.05)
	statNameLabel.Size = UDim2.fromScale(0.5, 0.9)
	statNameLabel.Text = statName
	statNameLabel.TextColor3 = Color3.new(1, 1, 1)
	statNameLabel.TextSize = 30
	statNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	statNameLabel.Parent = statFrame

	local statValueLabel = Instance.new("TextLabel")
	statValueLabel.Name = "StatValue_Label"
	statValueLabel.AnchorPoint = Vector2.new(1, 0.5)
	statValueLabel.BackgroundTransparency = 1
	statValueLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	statValueLabel.Position = UDim2.fromScale(0.97, 0.5)
	statValueLabel.Size = UDim2.fromScale(0.35, 0.9)
	statValueLabel.Text = "0"
	statValueLabel.TextColor3 = Color3.new(1, 1, 1)
	statValueLabel.TextSize = 30
	statValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	statValueLabel.Parent = statFrame

	local statValue = Instance.new("NumberValue")
	statValue.Name = "Value"
	statValue.Parent = statFrame
	statValue.Changed:Connect(function()
		statValueLabel.Text = tostring(math.floor(statValue.Value))
	end)

	return statFrame
end

--- Updates the stat value on the detailed combat info scrolling frame for a character
--- @param char -- The character whose stat value is being updated
--- @param newStatData -- A table containing the stat name and the new value for that stat
local function updateStatValue(char: _TYPES.Character, newStatData: { [string]: number })
	local detailedCombatInfoScreenGui =
		game.Players.LocalPlayer.PlayerGui:FindFirstChild("DetailedCombatInfo_ScreenGui")
	if not detailedCombatInfoScreenGui then
		warn("DetailedCombatInfo_ScreenGui not found in PlayerGui")
		return
	end

	-- Get the scrolling frame for the character and update the stat value
	for _, scrollingFrame in pairs(detailedCombatInfoScreenGui:QueryDescendants("ScrollingFrame")) do
		local associatedCharValue = scrollingFrame:FindFirstChild("AssociatedCharValue")
		if not associatedCharValue or associatedCharValue.Value ~= char then
			continue
		end

		for statName: string, value in pairs(newStatData) do
			local statFrame = scrollingFrame:FindFirstChild(
				"DetailedStat_" .. (STATS_TO_CHECK[statName] and STATS_TO_CHECK[statName].name or statName) .. "_Frame",
				true
			)
			if not statFrame then
				continue
			end

			local statValueObject = statFrame:FindFirstChild("Value", true)
			if statValueObject then
				statValueObject.Value = value
			end
		end
	end
end

local function createDetailedStatsFrame(_char: _TYPES.Character)
	local detailedStatsFrame = Instance.new("Frame")
	detailedStatsFrame.Name = "DetailedStats_Frame"
	detailedStatsFrame.BackgroundTransparency = 1
	detailedStatsFrame.LayoutOrder = 3
	detailedStatsFrame.Size = UDim2.fromScale(1, 0.439)

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.Padding = UDim.new(0, 16)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = detailedStatsFrame

	for statKey, statData in pairs(STATS_TO_CHECK) do
		local statFrame = createStatFrame(statKey, statData.name, statData.index)
		statFrame.Parent = detailedStatsFrame
	end

	return detailedStatsFrame
end

return {
	CreateDetailedStatsFrame = createDetailedStatsFrame,
	UpdateStatValue = updateStatValue,
}
