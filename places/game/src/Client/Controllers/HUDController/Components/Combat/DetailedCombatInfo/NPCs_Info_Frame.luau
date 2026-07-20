local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
local CharacterCombatInfoHealthbar = require(script.Parent.Parent.CharacterCombatInfo.CharacterCombatInfo_Healthbar)
local CreateCharacterCombatInfoExposureBar =
	require(script.Parent.Parent.CharacterCombatInfo.CharacterCombatInfo_ExposureBar)
local CreateCharacterCombatInfoShieldbar =
	require(script.Parent.Parent.CharacterCombatInfo.CharacterCombatInfo_Shieldbar)

return function(char: _TYPES.Character)
	local npcsInfoFrame = Instance.new("Frame")
	npcsInfoFrame.Name = "NPCs_Info_Frame"
	npcsInfoFrame.BackgroundColor3 = Color3.fromRGB(185, 185, 185)
	npcsInfoFrame.BackgroundTransparency = 0.7
	npcsInfoFrame.LayoutOrder = 2
	npcsInfoFrame.Size = UDim2.fromScale(0.9, 0.13)

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = npcsInfoFrame

	local infoFrame = Instance.new("Frame")
	infoFrame.Name = "Info_Frame"
	infoFrame.BackgroundTransparency = 1
	infoFrame.Position = UDim2.fromScale(0.09, 0)
	infoFrame.Size = UDim2.fromScale(0.9, 1)

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
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	characterNameLabel.LayoutOrder = 1
	characterNameLabel.Size = UDim2.fromScale(1, 0.35)
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
	barsFrame.Size = UDim2.fromScale(0.9, 0.2)

	local healthbar =
		CharacterCombatInfoHealthbar.CreateHealthbar(char, UDim2.fromScale(1, 0.7), UDim2.fromScale(0, 0), true)
	healthbar.Name = "DetailedInfo_Healthbar"
	healthbar.Parent = barsFrame
	healthbar.LayoutOrder = 1
	-- We don't need the damage fill for this healthbar, so we can destroy it to save resources
	local damageFill = healthbar:FindFirstChild("CharacterInfo_DamageFill")
	if damageFill then
		damageFill:Destroy()
	end

	local shieldbar = CreateCharacterCombatInfoShieldbar(UDim2.fromScale(1, 0.7), UDim2.fromScale(0, 0))
	shieldbar.Name = "DetailedInfo_Shieldbar"
	shieldbar.Parent = barsFrame
	shieldbar.LayoutOrder = 1

	local exposureBar = CreateCharacterCombatInfoExposureBar(UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0.7))
	exposureBar.Name = "DetailedInfo_ExposureBar"
	exposureBar.Parent = barsFrame
	exposureBar.LayoutOrder = 2

	barsFrame.Parent = infoFrame

	infoFrame.Parent = npcsInfoFrame

	return npcsInfoFrame
end
