local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local createCharacterCombatInfoEnergy = require(script.Parent.Parent.CharacterCombatInfo.CharacterCombatInfo_Energy)
local createCharacterCombatInfoHealthbar =
	require(script.Parent.Parent.CharacterCombatInfo.CharacterCombatInfo_Healthbar)
local createCharacterCombatInfoShieldbar =
	require(script.Parent.Parent.CharacterCombatInfo.CharacterCombatInfo_Shieldbar)

return function(char: _TYPES.Character)
	local playablesInfoFrame = Instance.new("Frame")
	playablesInfoFrame.Name = "Playables_Info_Frame"
	playablesInfoFrame.BackgroundColor3 = Color3.fromRGB(185, 185, 185)
	playablesInfoFrame.BackgroundTransparency = 0.7
	playablesInfoFrame.LayoutOrder = 2
	playablesInfoFrame.Size = UDim2.fromScale(0.9, 0.13)

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = playablesInfoFrame

	local infoFrame = Instance.new("Frame")
	infoFrame.Name = "Info_Frame"
	infoFrame.BackgroundTransparency = 1
	infoFrame.Position = UDim2.fromScale(0.18, 0)
	infoFrame.Size = UDim2.fromScale(0.82, 1)

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.ItemLineAlignment = Enum.ItemLineAlignment.Start
	uIListLayout.Padding = UDim.new(0, 8)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = infoFrame

	local characterNameLabel = Instance.new("TextLabel")
	characterNameLabel.Name = "CharacterName_Label"
	characterNameLabel.BackgroundTransparency = 1
	characterNameLabel.FontFace =
		Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	characterNameLabel.LayoutOrder = 1
	characterNameLabel.Size = UDim2.fromScale(1, 0.3)
	characterNameLabel.Text = char.Name
	characterNameLabel.TextColor3 = Color3.new(1, 1, 1)
	characterNameLabel.TextSize = 60
	characterNameLabel.TextStrokeTransparency = 0
	characterNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	characterNameLabel.Parent = infoFrame

	local barsFrame = Instance.new("Frame")
	barsFrame.Name = "Bars_Frame"
	barsFrame.BackgroundTransparency = 1
	barsFrame.LayoutOrder = 2
	barsFrame.Size = UDim2.fromScale(0.9, 0.14)

	local healthbar = createCharacterCombatInfoHealthbar(UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), true)
	healthbar.Name = "Detailed_Healthbar"
	healthbar.Parent = barsFrame

	local shieldbar = createCharacterCombatInfoShieldbar(UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))
	shieldbar.Name = "Detailed_Shieldbar"
	shieldbar.Parent = barsFrame

	barsFrame.Parent = infoFrame

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Name = "CharacterInfo_HPLabel"
	hpLabel.BackgroundTransparency = 1
	hpLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	hpLabel.RichText = true
	hpLabel.LayoutOrder = 3
	hpLabel.Size = UDim2.fromScale(1, 0.2)
	hpLabel.Text = "0"
	hpLabel.TextColor3 = Color3.new(1, 1, 1)
	hpLabel.TextScaled = true
	hpLabel.TextXAlignment = Enum.TextXAlignment.Left
	hpLabel.Parent = infoFrame

	infoFrame.Parent = playablesInfoFrame

	local energyFrame = createCharacterCombatInfoEnergy(UDim2.fromScale(0.66, 0.66), UDim2.fromScale(0.03, 0.17))
	energyFrame.Name = "Energy_Frame"
	energyFrame.Parent = playablesInfoFrame

	return playablesInfoFrame
end
