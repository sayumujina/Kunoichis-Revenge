local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local createCharacterCombatInfoEnergy = require(script.Parent.CharacterCombatInfo_Energy)
local createCharacterCombatInfoAvatar = require(script.Parent.CharacterCombatInfo_Avatar)
local createCharacterCombatInfoHealthbar = require(script.Parent.CharacterCombatInfo_Healthbar)
local createCharacterCombatInfoShieldbar = require(script.Parent.CharacterCombatInfo_Shieldbar)

return function(char: _TYPES.Character)
	local characterInfoCard = Instance.new("Frame")
	characterInfoCard.Name = "CharacterInfo_Card_" .. char.Name
	characterInfoCard.BackgroundTransparency = 1
	characterInfoCard.Position = UDim2.fromScale(1, 0)
	characterInfoCard.Size = UDim2.fromScale(1, 1)

	local associatedCharValue = Instance.new("ObjectValue")
	associatedCharValue.Name = "AssociatedCharValue"
	associatedCharValue.Value = char
	associatedCharValue.Parent = characterInfoCard

	local characterInfoAvatar = createCharacterCombatInfoAvatar(char.Name)
	characterInfoAvatar.Parent = characterInfoCard

	local characterInfoEnergy = createCharacterCombatInfoEnergy()
	characterInfoEnergy.Parent = characterInfoCard

	local characterInfoHealthbar = createCharacterCombatInfoHealthbar()
	characterInfoHealthbar.Parent = characterInfoCard

	local characterInfoShieldbar = createCharacterCombatInfoShieldbar()
	characterInfoShieldbar.Parent = characterInfoCard

	local characterInfoHealthCountLabel = Instance.new("TextLabel")
	characterInfoHealthCountLabel.Name = "CharacterInfo_HealthCountLabel"
	characterInfoHealthCountLabel.AnchorPoint = Vector2.new(1, 0)
	characterInfoHealthCountLabel.BackgroundTransparency = 1
	characterInfoHealthCountLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	characterInfoHealthCountLabel.Position = UDim2.fromScale(0.97, 0.82)
	characterInfoHealthCountLabel.Size = UDim2.fromScale(0.3, 0.1)
	characterInfoHealthCountLabel.Text = "4233"
	characterInfoHealthCountLabel.TextColor3 = Color3.new(1, 1, 1)
	characterInfoHealthCountLabel.TextScaled = true
	characterInfoHealthCountLabel.TextXAlignment = Enum.TextXAlignment.Right
	characterInfoHealthCountLabel.Parent = characterInfoCard

	local characterInfoCardAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	characterInfoCardAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	characterInfoCardAspectRatioConstraint.AspectRatio = 1.387
	characterInfoCardAspectRatioConstraint.Parent = characterInfoCard

	return characterInfoCard
end
