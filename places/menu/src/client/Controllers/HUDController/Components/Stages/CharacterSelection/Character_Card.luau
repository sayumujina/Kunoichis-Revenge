local rep = game:GetService("ReplicatedStorage")
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local WarningController = require(StarterPlayerScripts.Client.GlobalControllers.WarningController)
local SoundController = require(StarterPlayerScripts.Client.GlobalControllers.SoundController)
-- Utility
local GetAvatarImageForCharacter = require(rep.Shared.GlobalUtility.GetAvatarImageForCharacter)

local function createSelectedOverlay(index: number)
	local selectionOverlay = Instance.new("Frame")
	selectionOverlay.Name = "Selection_Overlay"
	selectionOverlay.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	selectionOverlay.Position = UDim2.fromScale(0.75, 0)
	selectionOverlay.Size = UDim2.fromScale(0.25, 0.25)
	selectionOverlay.ZIndex = 20

	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "UICorner"
	uICorner2.Parent = selectionOverlay

	local indexLabel = Instance.new("TextLabel")
	indexLabel.Name = "Index"
	indexLabel.BackgroundTransparency = 1
	indexLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	indexLabel.Size = UDim2.fromScale(1, 1)
	indexLabel.Text = tostring(index)
	indexLabel.TextColor3 = Color3.new()
	indexLabel.TextScaled = true
	indexLabel.ZIndex = selectionOverlay.ZIndex
	indexLabel.Parent = selectionOverlay

	return selectionOverlay
end

local function createCharacterCard(owned: boolean, charName: string, charLevel: number?, onActivated: ((string) -> ())?)
	local characterFrame = Instance.new("Frame")
	characterFrame.Name = "Character_Frame_" .. charName
	characterFrame.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
	characterFrame.BackgroundTransparency = 0.8
	characterFrame.Size = UDim2.fromScale(0.23, 0.23)
	characterFrame.ZIndex = 10

	local levelValue = Instance.new("IntValue")
	levelValue.Name = "LevelValue"
	levelValue.Value = if charLevel then charLevel else 0
	levelValue.Parent = characterFrame

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.Parent = characterFrame

	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.BackgroundTransparency = 1
	avatar.Image = GetAvatarImageForCharacter(charName, if owned then false else true) -- Get the silhouette if the character is not owned
	avatar.Size = UDim2.fromScale(1, 1)
	avatar.ZIndex = characterFrame.ZIndex
	avatar.Parent = characterFrame

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.BottomLeftRadius = UDim.new(0, 12)
	uICorner.BottomRightRadius = UDim.new(0, 12)
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.TopLeftRadius = UDim.new(0, 12)
	uICorner.TopRightRadius = UDim.new(0, 12)
	uICorner.Parent = characterFrame

	if charLevel then
		local levelLabel = Instance.new("TextLabel")
		levelLabel.Name = "Level_Label"
		levelLabel.BackgroundColor3 = Color3.fromRGB(209, 198, 185)
		levelLabel.FontFace =
			Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		levelLabel.Position = UDim2.fromScale(0, 0.8)
		levelLabel.Size = UDim2.fromScale(1, 0.2)
		levelLabel.Text = "Lv. " .. tostring(charLevel)
		levelLabel.TextColor3 = Color3.new()
		levelLabel.TextScaled = true
		levelLabel.Parent = characterFrame
		levelLabel.ZIndex = characterFrame.ZIndex

		local uICorner1 = Instance.new("UICorner")
		uICorner1.Name = "UICorner"
		uICorner1.BottomLeftRadius = UDim.new(0, 12)
		uICorner1.BottomRightRadius = UDim.new(0, 12)
		uICorner1.CornerRadius = UDim.new(0, 12)
		uICorner1.TopLeftRadius = UDim.new(0, 12)
		uICorner1.TopRightRadius = UDim.new(0, 12)
		uICorner1.Parent = levelLabel
	end

	local invisibleImageButton = Instance.new("ImageButton")
	invisibleImageButton.Name = "InvisibleImageButton"
	invisibleImageButton.BackgroundTransparency = 1
	invisibleImageButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	invisibleImageButton.ImageTransparency = 1
	invisibleImageButton.Size = UDim2.fromScale(1, 1)
	invisibleImageButton.ZIndex = characterFrame.ZIndex + 1
	invisibleImageButton.MouseButton1Click:Connect(function()
		SoundController.Play("Sound_UniversalClick")

		if owned then
			if onActivated then
				onActivated(charName)
			end
		else
			WarningController.DisplayWarning(false, "This character is locked.")
		end
	end)
	invisibleImageButton.Parent = characterFrame

	return characterFrame
end

return {
	CreateCharacterCard = createCharacterCard,
	CreateSelectedOverlay = createSelectedOverlay,
}
