local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local CreateCharacterCombatInfoEnergy = require(script.Parent.CharacterCombatInfo_Energy)
local CharacterCombatInfoAvatar = require(script.Parent.CharacterCombatInfo_Avatar)
local CharacterCombatInfoHealthbar = require(script.Parent.CharacterCombatInfo_Healthbar)
local CreateCharacterCombatInfoShieldbar = require(script.Parent.CharacterCombatInfo_Shieldbar)

return function(char: _TYPES.Character)
	local characterInfoCard = Instance.new("Frame")
	characterInfoCard.Name = "CharacterInfo_Card_" .. char.Name
	characterInfoCard.BackgroundTransparency = 1
	characterInfoCard.Position = UDim2.fromScale(1, 0)
	characterInfoCard.Size = UDim2.fromScale(1, 1)
	characterInfoCard.LayoutOrder = char:GetAttribute("Index")

	local associatedCharValue = Instance.new("ObjectValue")
	associatedCharValue.Name = "AssociatedCharValue"
	associatedCharValue.Value = char
	associatedCharValue.Parent = characterInfoCard

	local characterInfoAvatar = CharacterCombatInfoAvatar.CreateCharacterCombatInfoAvatar(char)
	characterInfoAvatar.Parent = characterInfoCard

	local characterInfoEnergy = CreateCharacterCombatInfoEnergy()
	characterInfoEnergy.Parent = characterInfoCard

	local characterInfoShieldbar = CreateCharacterCombatInfoShieldbar()
	characterInfoShieldbar.Parent = characterInfoCard

	local characterInfoHealthbar = CharacterCombatInfoHealthbar.CreateHealthbar(
		char,
		UDim2.fromScale(0.964, 0.1344),
		UDim2.fromScale(0.005, 0.669)
	)
	characterInfoHealthbar.Parent = characterInfoCard

	local characterInfoHPLabel = Instance.new("TextLabel")
	characterInfoHPLabel.Name = "CharacterInfo_HPLabel"
	characterInfoHPLabel.AnchorPoint = Vector2.new(1, 0)
	characterInfoHPLabel.BackgroundTransparency = 1
	characterInfoHPLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	characterInfoHPLabel.Position = UDim2.fromScale(0.97, 0.82)
	characterInfoHPLabel.Size = UDim2.fromScale(0.3, 0.1)
	characterInfoHPLabel.Text = "4233"
	characterInfoHPLabel.RichText = true
	characterInfoHPLabel.TextColor3 = Color3.new(1, 1, 1)
	characterInfoHPLabel.TextScaled = true
	characterInfoHPLabel.TextXAlignment = Enum.TextXAlignment.Right
	characterInfoHPLabel.Parent = characterInfoCard

	local characterInfoCardAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	characterInfoCardAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	characterInfoCardAspectRatioConstraint.AspectRatio = 1.387
	characterInfoCardAspectRatioConstraint.Parent = characterInfoCard

	return characterInfoCard
end
