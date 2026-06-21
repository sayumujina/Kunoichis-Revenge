local function getComposureScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

return function()
	local characterInfoComposureBar = Instance.new("Frame")
	characterInfoComposureBar.Name = "CharacterInfo_ComposureBar"
	characterInfoComposureBar.BackgroundColor3 = Color3.fromRGB(252, 250, 255)
	characterInfoComposureBar.Position = UDim2.fromScale(0, 0.747)
	characterInfoComposureBar.Size = UDim2.fromScale(1, 0.253)

	local characterInfoCurrentComposureValue = Instance.new("NumberValue")
	characterInfoCurrentComposureValue.Name = "CharacterComposureValue"
	characterInfoCurrentComposureValue.Value = 0
	characterInfoCurrentComposureValue.Parent = characterInfoComposureBar

	local characterInfoMaxComposureValue = Instance.new("NumberValue")
	characterInfoMaxComposureValue.Name = "CharacterMaxComposureValue"
	characterInfoMaxComposureValue.Value = 0
	characterInfoMaxComposureValue.Parent = characterInfoComposureBar

	-- Listens to composure changed events to update the composure bar fill
	characterInfoCurrentComposureValue.Changed:Connect(function()
		-- Recalculate the composure bar fill size based on the new composure value
		local composureScale =
			getComposureScale(characterInfoCurrentComposureValue.Value, characterInfoMaxComposureValue.Value)

		-- Update the composure bar fill size based on the new composure value
		characterInfoComposureBar.Size = UDim2.fromScale(composureScale, 1)

		-- Update the label that shows the current composure value
		local characterInfoCard = characterInfoComposureBar.Parent
		if not characterInfoCard then
			return
		end
	end)

	return characterInfoComposureBar
end
