local function getExposureScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

return function()
	local exposureBar = Instance.new("Frame")
	exposureBar.Name = "CharacterInfo_ExposureBar"
	exposureBar.BackgroundColor3 = Color3.fromRGB(252, 250, 255)
	exposureBar.Position = UDim2.fromScale(0, 0.747)
	exposureBar.Size = UDim2.fromScale(1, 0.253)

	local currentExposureValue = Instance.new("NumberValue")
	currentExposureValue.Name = "CharacterCurrentExposureValue"
	currentExposureValue.Value = 0
	currentExposureValue.Parent = exposureBar

	local maxExposureValue = Instance.new("NumberValue")
	maxExposureValue.Name = "CharacterMaxExposureValue"
	maxExposureValue.Value = 0
	maxExposureValue.Parent = exposureBar

	-- Listens to exposure changed events to update the exposure bar fill
	currentExposureValue.Changed:Connect(function()
		-- Recalculate the exposure bar fill size based on the new exposure value
		local exposureScale = getExposureScale(currentExposureValue.Value, maxExposureValue.Value)

		-- Update the exposure bar fill size based on the new exposure value
		exposureBar.Size = UDim2.fromScale(exposureScale, 0.253)

		-- Update the label that shows the current exposure value
		local characterInfoCard = exposureBar.Parent
		if not characterInfoCard then
			return
		end
	end)

	return exposureBar
end
