return function()
	local damageCard = Instance.new("Frame")
	damageCard.Name = "UI_DamageCard"
	damageCard.BackgroundTransparency = 1
	damageCard.Size = UDim2.fromScale(0.3, 0.14)
	damageCard.Position = UDim2.fromScale(0.81, 0.25)
	damageCard.Visible = false

	local totalDamageLabel = Instance.new("TextLabel")
	totalDamageLabel.Name = "TotalDamage_Label"
	totalDamageLabel.BackgroundTransparency = 1
	totalDamageLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	totalDamageLabel.Position = UDim2.fromScale(0.2, 0)
	totalDamageLabel.Size = UDim2.fromScale(0.4, 0.4)
	totalDamageLabel.Text = "TOTAL DAMAGE"
	totalDamageLabel.TextColor3 = Color3.new()
	totalDamageLabel.TextScaled = true
	totalDamageLabel.TextXAlignment = Enum.TextXAlignment.Right
	totalDamageLabel.Parent = damageCard

	local totalDamageValue = Instance.new("TextLabel")
	totalDamageValue.Name = "TotalDamage_Value"
	totalDamageValue.BackgroundTransparency = 1
	totalDamageValue.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	totalDamageValue.Position = UDim2.fromScale(0, 0.32)
	totalDamageValue.Size = UDim2.fromScale(0.6, 0.6)
	totalDamageValue.Text = "0"
	totalDamageValue.TextColor3 = Color3.new(1, 1, 1)
	totalDamageValue.TextDirection = Enum.TextDirection.RightToLeft
	totalDamageValue.TextScaled = true
	totalDamageValue.TextXAlignment = Enum.TextXAlignment.Right
	totalDamageValue.Parent = damageCard

	return damageCard
end
