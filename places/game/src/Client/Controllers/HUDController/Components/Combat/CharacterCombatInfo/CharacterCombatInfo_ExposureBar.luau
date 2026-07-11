local function getExposureScale(current: number, max: number): number
	if max == 0 then
		return 0
	end
	return current / max
end

local FILL_POSITION_OFFSET = 0.008
local FILL_SIZE_X_OFFSET = FILL_POSITION_OFFSET * 2
local FILL_SIZE_Y_SCALE = 0.9

return function(size: UDim2?, position: UDim2?)
	local exposureBar = Instance.new("Frame")
	exposureBar.Name = "CharacterInfo_ExposureBar"
	exposureBar.BackgroundTransparency = 1
	exposureBar.Position = position or UDim2.fromScale(0, 0.747)
	exposureBar.Size = size or UDim2.fromScale(1, 0.253)

	local currentExposureValue = Instance.new("NumberValue")
	currentExposureValue.Name = "CharacterCurrentExposureValue"
	currentExposureValue.Value = 0
	currentExposureValue.Parent = exposureBar

	local maxExposureValue = Instance.new("NumberValue")
	maxExposureValue.Name = "CharacterMaxExposureValue"
	maxExposureValue.Value = 0
	maxExposureValue.Parent = exposureBar

	local exposureBarFill = Instance.new("Frame")
	exposureBarFill.Name = "CharacterInfo_ExposureBarFill"
	exposureBarFill.AnchorPoint = Vector2.new(0, 0.5)
	exposureBarFill.BackgroundTransparency = 1
	exposureBarFill.ClipsDescendants = true
	exposureBarFill.Position = UDim2.fromScale(FILL_POSITION_OFFSET, 0.5)

	local exposureBarFillImageLabel = Instance.new("ImageLabel")
	exposureBarFillImageLabel.Name = "ImageLabel"
	exposureBarFillImageLabel.BackgroundTransparency = 1
	exposureBarFillImageLabel.Image = "rbxassetid://93013412082634"
	exposureBarFillImageLabel.Size = UDim2.new(1, 0, 0, exposureBar.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)

	local function updateExposureBar()
		local exposureScale = getExposureScale(currentExposureValue.Value, maxExposureValue.Value)
		exposureBarFill.Size = UDim2.fromScale(math.max(exposureScale - FILL_SIZE_X_OFFSET, 0), FILL_SIZE_Y_SCALE)
	end

	exposureBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		exposureBarFillImageLabel.Size = UDim2.new(1, 0, 0, exposureBar.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	end)

	currentExposureValue.Changed:Connect(updateExposureBar)
	maxExposureValue.Changed:Connect(updateExposureBar)
	updateExposureBar()

	exposureBarFillImageLabel.Parent = exposureBarFill
	exposureBarFill.Parent = exposureBar

	return exposureBar
end
