return function()
	local loadingScreenGui = Instance.new("ScreenGui")
	loadingScreenGui.Name = "LoadingScreen_ScreenGui"
	loadingScreenGui.ScreenInsets = Enum.ScreenInsets.None
	loadingScreenGui.DisplayOrder = 200

	local fullFrame = Instance.new("Frame")
	fullFrame.Name = "LoadingScreen_FullFrame"
	fullFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
	fullFrame.BorderColor3 = Color3.new()
	fullFrame.BorderSizePixel = 0
	fullFrame.Size = UDim2.fromScale(1, 1)

	local loadingText = Instance.new("TextLabel")
	loadingText.Name = "LoadingText"
	loadingText.BackgroundTransparency = 1
	loadingText.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	loadingText.Position = UDim2.fromScale(0.26, 0.41)
	loadingText.Size = UDim2.fromScale(0.48, 0.08)
	loadingText.Text = "LOADING ASSETS..."
	loadingText.TextColor3 = Color3.new(1, 1, 1)
	loadingText.TextScaled = true
	loadingText.Parent = fullFrame

	fullFrame.Parent = loadingScreenGui

	-- Create an invisible button
	local invisibleButton = Instance.new("ImageButton")
	invisibleButton.Name = "InvisibleButton"
	invisibleButton.BackgroundTransparency = 1
	invisibleButton.ImageTransparency = 1
	invisibleButton.Size = UDim2.fromScale(1, 1)
	invisibleButton.Parent = fullFrame
	invisibleButton.Visible = true

	return loadingScreenGui
end
