local function getExposureScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

return function()
	local characterInfoExposureBar = Instance.new("Frame")
	characterInfoExposureBar.Name = "CharacterInfo_ExposureBar"
	characterInfoExposureBar.BackgroundColor3 = Color3.fromRGB(252, 250, 255)
	characterInfoExposureBar.Position = UDim2.fromScale(0, 0.747)
	characterInfoExposureBar.Size = UDim2.fromScale(1, 0.253)

	local characterInfoCurrentExposureValue = Instance.new("NumberValue")
	characterInfoCurrentExposureValue.Name = "CharacterCurrentExposureValue"
	characterInfoCurrentExposureValue.Value = 0
	characterInfoCurrentExposureValue.Parent = characterInfoExposureBar

	local characterInfoMaxExposureValue = Instance.new("NumberValue")
	characterInfoMaxExposureValue.Name = "CharacterMaxExposureValue"
	characterInfoMaxExposureValue.Value = 0
	characterInfoMaxExposureValue.Parent = characterInfoExposureBar

	-- Listens to exposure changed events to update the exposure bar fill
	characterInfoCurrentExposureValue.Changed:Connect(function()
		-- Recalculate the exposure bar fill size based on the new exposure value
		local exposureScale =
			getExposureScale(characterInfoCurrentExposureValue.Value, characterInfoMaxExposureValue.Value)

		-- Update the exposure bar fill size based on the new exposure value
		characterInfoExposureBar.Size = UDim2.fromScale(exposureScale, 0.253)

		-- Update the label that shows the current exposure value
		local characterInfoCard = characterInfoExposureBar.Parent
		if not characterInfoCard then
			return
		end
	end)

	return characterInfoExposureBar
end
