local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
--
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local GetAvatarImageForCharacter = require(rep.Shared.GlobalUtility.GetAvatarImageForCharacter)

return function(char: _TYPES.Character, extraActionId: number, layoutOrder: number)
	local extraActionFrame = Instance.new("Frame")
	extraActionFrame.Name = "ExtraAction_" .. extraActionId
	extraActionFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	extraActionFrame.BackgroundTransparency = 0.9
	extraActionFrame.BorderColor3 = Color3.new()
	extraActionFrame.BorderSizePixel = 0
	extraActionFrame.LayoutOrder = layoutOrder
	extraActionFrame.Size = UDim2.fromScale(0.95, 1)

	local extraActionIdValue = Instance.new("NumberValue")
	extraActionIdValue.Name = "ExtraActionIdValue"
	extraActionIdValue.Value = extraActionId
	extraActionIdValue.Parent = extraActionFrame

	local associatedCharValue = Instance.new("ObjectValue")
	associatedCharValue.Name = "ExtraTurn_AssociatedChar"
	associatedCharValue.Value = char
	associatedCharValue.Parent = extraActionFrame

	local extraActionRatioConstraint = Instance.new("UIAspectRatioConstraint")
	extraActionRatioConstraint.Name = "UIAspectRatioConstraint"
	extraActionRatioConstraint.AspectRatio = 1.4
	extraActionRatioConstraint.Parent = extraActionFrame

	local bg = Instance.new("Frame")
	bg.Name = "BG"
	bg.AnchorPoint = Vector2.new(1, 0)
	bg.BackgroundColor3 = Color3.new(1, 1, 1)
	bg.BorderColor3 = Color3.new()
	bg.BorderSizePixel = 0
	bg.Position = UDim2.fromScale(1, 0)
	bg.Size = UDim2.fromScale(0.95, 1)
	bg.Transparency = 1

	local uiGradient = Instance.new("UIGradient")
	uiGradient.Name = "UIGradient"
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.35, 0.7),
		NumberSequenceKeypoint.new(1, 1),
	})
	uiGradient.Parent = bg

	bg.Parent = extraActionFrame

	local leftBorder = Instance.new("Frame")
	leftBorder.Name = "Left_Border"
	leftBorder.AnchorPoint = Vector2.new(0, 0.5)
	leftBorder.BackgroundColor3 = Color3.new(1, 1, 1)
	leftBorder.BorderColor3 = Color3.new()
	leftBorder.BorderSizePixel = 0
	leftBorder.Position = UDim2.fromScale(0, 0.5)
	leftBorder.Size = UDim2.new(0, 2, 1, 0)

	local leftBorderGradient = Instance.new("UIGradient")
	leftBorderGradient.Name = "UIGradient"
	leftBorderGradient.Color = if char:GetAttribute("Side") == "Playable"
		then ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 213)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 213)),
		}) -- Blue for playable characters
		else ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(213, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 0, 0)),
		}) -- Red for npcs
	leftBorderGradient.Rotation = 90
	leftBorderGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.35, 0.2),
		NumberSequenceKeypoint.new(0.65, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	leftBorderGradient.Parent = leftBorder

	leftBorder.Parent = extraActionFrame

	local avatarContainer = Instance.new("Frame")
	avatarContainer.Name = "Avatar_Container"
	avatarContainer.BackgroundColor3 = Color3.new(1, 1, 1)
	avatarContainer.BorderColor3 = Color3.new()
	avatarContainer.BorderSizePixel = 0
	avatarContainer.Position = UDim2.fromScale(0.15, 0)
	avatarContainer.Size = UDim2.fromScale(1, 1)
	avatarContainer.BackgroundTransparency = 1

	local avatarContainerRatioConstraint = Instance.new("UIAspectRatioConstraint")
	avatarContainerRatioConstraint.Name = "UIAspectRatioConstraint"
	avatarContainerRatioConstraint.Parent = avatarContainer

	local avatarImageLabel = Instance.new("ImageLabel")
	avatarImageLabel.Name = "ImageLabel"
	avatarImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	avatarImageLabel.BorderColor3 = Color3.new()
	avatarImageLabel.BorderSizePixel = 0
	avatarImageLabel.Image = GetAvatarImageForCharacter(char.Name)
	avatarImageLabel.Size = UDim2.fromScale(1, 1)
	avatarImageLabel.BackgroundTransparency = 1
	avatarImageLabel.ZIndex = 2
	avatarImageLabel.Parent = avatarContainer
	--
	avatarContainer.Parent = extraActionFrame

	return extraActionFrame
end
