local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
--
local TweenService = game:GetService("TweenService")
local ui = require(rep.Assets.Asphalt.UI)

-- Table to keep track of the current tweens for health and damage bars
local currentTween = {} :: { [_TYPES.Character]: { Health: Tween?, Damage: Tween? } }

local function getHPScale(current: number, max: number): number
	if max == 0 then
		return 0
	end

	return current / max
end

local FILL_POSITION_OFFSET = 0.008 -- The scale of the healthbar fill relative to the healthbar frame size
local FILL_SIZE_X_OFFSET = 1 - (FILL_POSITION_OFFSET * 2) -- The scale of the healthbar fill relative to the healthbar frame size
local FILL_SIZE_Y_SCALE = 0.9
local SHIELD_TEXT_COLOR = Color3.fromRGB(255, 170, 0)

local function findOwnerContainer(container: Instance?): Instance?
	local current = container
	while current do
		local associatedCharValue = current:FindFirstChild("AssociatedCharValue")
		if associatedCharValue and associatedCharValue:IsA("ObjectValue") then
			return current
		end

		current = current.Parent
	end

	return nil
end

-- Finds a descendant with the specified name and optional class name within the given container
local function findDescendantInContainer(container: Instance?, name: string, className: string?): Instance?
	if not container then
		return nil
	end

	local descendant = container:FindFirstChild(name, true)
	if descendant and (not className or descendant:IsA(className)) then
		return descendant
	end

	return nil
end

-- Updates the HP label text based on the current and max HP values, as well as any shield value if present
local function updateHPLabel(container: Instance?, currentHPValue: number, maxHPValue: number)
	local ownerContainer = findOwnerContainer(container)
	local hpLabel = findDescendantInContainer(ownerContainer, "CharacterInfo_HPLabel", "TextLabel")
	if not hpLabel or not hpLabel:IsA("TextLabel") then
		return
	end

	hpLabel.RichText = true

	local currentShieldValue = findDescendantInContainer(ownerContainer, "CharacterCurrentShieldValue", "NumberValue")
	if currentShieldValue and currentShieldValue:IsA("NumberValue") and currentShieldValue.Value > 0 then
		hpLabel.Text = string.format(
			'%d + <font color="rgb(%d,%d,%d)">%d</font> / %d',
			math.ceil(currentHPValue),
			SHIELD_TEXT_COLOR.R * 255,
			SHIELD_TEXT_COLOR.G * 255,
			SHIELD_TEXT_COLOR.B * 255,
			math.ceil(currentShieldValue.Value),
			math.ceil(maxHPValue)
		)
	else
		hpLabel.Text = string.format("%d / %d", math.ceil(currentHPValue), math.ceil(maxHPValue))
	end
end

--- Tweens the healthbar fill based
--- @param bar - The bar to tween, either "Health" or "Damage"
local function tweenHealthbarFill(char: _TYPES.Character, bar: "Health" | "Damage", frame: Frame)
	local barName = if bar == "Health" then "CharacterInfo_HealthbarFill" else "CharacterInfo_DamageFill"
	local healthbarFill = frame:FindFirstChild(barName)
	if not healthbarFill or not healthbarFill:IsA("Frame") then
		return
	end

	if currentTween[char] and currentTween[char][bar] then
		currentTween[char][bar]:Cancel()
		currentTween[char][bar] = nil
	end

	currentTween[char] = currentTween[char] or {}
	currentTween[char][bar] =
		TweenService:Create(healthbarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(
				getHPScale(frame.CharacterCurrentHPValue.Value, frame.CharacterMaxHPValue.Value) * FILL_SIZE_X_OFFSET,
				FILL_SIZE_Y_SCALE
			),
		})

	-- Delay the tween for the damage bar a bit after move ends
	if bar == "Damage" then
		task.delay(0.5, function()
			-- If the tween still exists by then, play it
			if currentTween[char] and currentTween[char][bar] then
				currentTween[char][bar]:Play()
			end
		end)
	else
		currentTween[char][bar]:Play()
	end
end

--- Updates the size of the healthbar or damage bar based on the current and max HP values
--- @param char - The character whose healthbar is being updated
--- @param bar - The bar to update, either "Health" or "Damage"
local function updateBarSize(char: _TYPES.Character, bar: "Health" | "Damage", tween: boolean?)
	-- Find the gui folder based on the side
	local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
	local guiFolderName = if char:GetAttribute("Side") == "Playable"
		then playerGui:FindFirstChild("CharacterUI", true):FindFirstChild("UI_CharacterInfoFrame")
		else playerGui:FindFirstChild("UI_BillboardGui_Folder", true)

	local detailedInfoFrame = playerGui:FindFirstChild("DetailedCombatInfo_ScreenGui", true)
	if bar == "Health" then
		for _, child in detailedInfoFrame:QueryDescendants("ScrollingFrame") do
			local associatedCharValue = child:FindFirstChild("AssociatedCharValue")
			if
				not associatedCharValue
				or not associatedCharValue:IsA("ObjectValue")
				or associatedCharValue.Value ~= char
			then
				continue
			end

			-- Update bar size for the detailed info frame
			local barsFrame = child:FindFirstChild("Bars_Frame", true)
			if not barsFrame or not barsFrame:IsA("Frame") then
				warn("Bars_Frame not found for character: " .. char.Name)
				continue
			end

			local healthbarFrame = barsFrame:FindFirstChild("DetailedInfo_Healthbar", true)
			local healthbarFillFrame = healthbarFrame:FindFirstChild("CharacterInfo_HealthbarFill", true)

			-- Update the size of the healthbar based on the current and max HP values
			healthbarFillFrame.Size = UDim2.fromScale(
				math.max(
					getHPScale(healthbarFrame.CharacterCurrentHPValue.Value, healthbarFrame.CharacterMaxHPValue.Value)
						* FILL_SIZE_X_OFFSET,
					0
				),
				FILL_SIZE_Y_SCALE
			)
		end
	end

	for _, child in guiFolderName:GetChildren() do
		local associatedCharValue = child:FindFirstChild("AssociatedCharValue")
		if
			not associatedCharValue
			or not associatedCharValue:IsA("ObjectValue")
			or associatedCharValue.Value ~= char
		then
			continue
		end

		local healthbarFrame = child:FindFirstChild("CharacterInfo_Healthbar")
		if not healthbarFrame or not healthbarFrame:IsA("Frame") then
			continue
		end

		local barFill = healthbarFrame:FindFirstChild(
			if bar == "Health" then "CharacterInfo_HealthbarFill" else "CharacterInfo_DamageFill"
		)
		if not barFill or not barFill:IsA("Frame") then
			return
		end

		if tween then
			tweenHealthbarFill(char, bar, healthbarFrame)
		else
			barFill.Size = UDim2.fromScale(
				math.max(
					getHPScale(healthbarFrame.CharacterCurrentHPValue.Value, healthbarFrame.CharacterMaxHPValue.Value)
						* FILL_SIZE_X_OFFSET,
					0
				),
				FILL_SIZE_Y_SCALE
			)
		end
	end
end

--- @param size - The size of the healthbar frame
--- @param position - The position of the healthbar frame
--- @param ignoreBorder - Whether to skip rendering the healthbar border
local function createHealthbar(char: _TYPES.Character, size: UDim2, position: UDim2, ignoreBorder: boolean?)
	local healthbarFrame = Instance.new("Frame")
	healthbarFrame.Name = "CharacterInfo_Healthbar"
	healthbarFrame.BackgroundTransparency = 1
	healthbarFrame.Position = position
	healthbarFrame.Size = size

	local healthbarAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	healthbarAspectRatioConstraint.Name = "CharacterInfo_HealthbarAspectRatioConstraint"
	healthbarAspectRatioConstraint.AspectRatio = 9.9484

	local maxHPValue = Instance.new("NumberValue")
	maxHPValue.Name = "CharacterMaxHPValue"
	maxHPValue.Parent = healthbarFrame

	local currentHPValue = Instance.new("NumberValue")
	currentHPValue.Name = "CharacterCurrentHPValue"
	currentHPValue.Parent = healthbarFrame

	if not ignoreBorder then
		local healthbarBorder = Instance.new("Frame")
		healthbarBorder.Name = "CharacterInfo_HealthbarBorder"
		healthbarBorder.BackgroundTransparency = 1
		healthbarBorder.Size = UDim2.fromScale(1, 1)

		local healthbarBorderImageLabel = Instance.new("ImageLabel")
		healthbarBorderImageLabel.Name = "ImageLabel"
		healthbarBorderImageLabel.BackgroundTransparency = 1
		healthbarBorderImageLabel.Image = ui.hud.Combat.UI_CombatHud_HealthBorder
		healthbarBorderImageLabel.Size = UDim2.fromScale(1, 1)

		local healthbarBorderUIGradient = Instance.new("UIGradient")
		healthbarBorderUIGradient.Name = "UIGradient"
		healthbarBorderUIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new()),
			ColorSequenceKeypoint.new(1, Color3.new()),
		})
		healthbarBorderUIGradient.Parent = healthbarBorderImageLabel

		healthbarBorderImageLabel.Parent = healthbarBorder
		healthbarBorder.Parent = healthbarFrame
	end

	-- Damage fill
	local damageFill = Instance.new("Frame")
	damageFill.Name = "CharacterInfo_DamageFill"
	damageFill.AnchorPoint = Vector2.new(0, 0.5)
	damageFill.BackgroundTransparency = 1
	damageFill.ClipsDescendants = true
	damageFill.Position = UDim2.fromScale(FILL_POSITION_OFFSET, 0.5)
	damageFill.Size =
		UDim2.fromScale(getHPScale(currentHPValue.Value, maxHPValue.Value) * FILL_SIZE_X_OFFSET, FILL_SIZE_Y_SCALE)

	local damageFillImageLabel = Instance.new("ImageLabel")
	damageFillImageLabel.Name = "ImageLabel"
	damageFillImageLabel.BackgroundTransparency = 1
	damageFillImageLabel.ZIndex = 1 -- Place it below the healthbar fill
	damageFillImageLabel.Image = ui.hud.Combat.UI_CombatHud_HealthFill
	damageFillImageLabel.Size = UDim2.new(1, 0, 0, healthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	damageFillImageLabel.Parent = damageFill

	local damageFillUIGradient = Instance.new("UIGradient")
	damageFillUIGradient.Name = "UIGradient"
	damageFillUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})
	damageFillUIGradient.Parent = damageFillImageLabel

	local healthbarFill = Instance.new("Frame")
	healthbarFill.Name = "CharacterInfo_HealthbarFill"
	healthbarFill.AnchorPoint = Vector2.new(0, 0.5)
	healthbarFill.BackgroundTransparency = 1
	healthbarFill.ClipsDescendants = true
	healthbarFill.Position = UDim2.fromScale(FILL_POSITION_OFFSET, 0.5)
	healthbarFill.Size =
		UDim2.fromScale(getHPScale(currentHPValue.Value, maxHPValue.Value) * FILL_SIZE_X_OFFSET, FILL_SIZE_Y_SCALE)

	-- Healthbar fill
	local healthbarFillImageLabel = Instance.new("ImageLabel")
	healthbarFillImageLabel.Name = "ImageLabel"
	healthbarFillImageLabel.BackgroundTransparency = 1
	healthbarFillImageLabel.ZIndex = 2 -- Place it above the damage fill
	healthbarFillImageLabel.Image = ui.hud.Combat.UI_CombatHud_HealthFill
	healthbarFillImageLabel.Size = UDim2.new(1, 0, 0, healthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	healthbarFillImageLabel.Parent = healthbarFill

	local healthbarFillUIGradient = Instance.new("UIGradient")
	healthbarFillUIGradient.Name = "UIGradient"
	healthbarFillUIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 175, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 247, 255)),
	})
	healthbarFillUIGradient.Parent = healthbarFillImageLabel

	healthbarFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		healthbarFillImageLabel.Size = UDim2.new(1, 0, 0, healthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
		damageFillImageLabel.Size = UDim2.new(1, 0, 0, healthbarFrame.AbsoluteSize.Y * FILL_SIZE_Y_SCALE)
	end)

	local shieldValueChangedConnection: RBXScriptConnection? = nil
	local ownerDescendantAddedConnection: RBXScriptConnection? = nil

	local function bindShieldValueListener()
		if shieldValueChangedConnection then
			shieldValueChangedConnection:Disconnect()
			shieldValueChangedConnection = nil
		end

		local ownerContainer = findOwnerContainer(healthbarFrame.Parent)
		local currentShieldValue =
			findDescendantInContainer(ownerContainer, "CharacterCurrentShieldValue", "NumberValue")
		if currentShieldValue and currentShieldValue:IsA("NumberValue") then
			shieldValueChangedConnection = currentShieldValue.Changed:Connect(function()
				updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
			end)
		end
	end

	local function bindOwnerContainerListeners()
		if ownerDescendantAddedConnection then
			ownerDescendantAddedConnection:Disconnect()
			ownerDescendantAddedConnection = nil
		end

		local ownerContainer = findOwnerContainer(healthbarFrame.Parent)
		if not ownerContainer then
			return
		end

		ownerDescendantAddedConnection = ownerContainer.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "CharacterCurrentShieldValue" and descendant:IsA("NumberValue") then
				bindShieldValueListener()
				updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
			end
		end)
	end

	local updatedDamgeFillOnSpawn = false
	currentHPValue.Changed:Connect(function()
		-- Characters spawn, then change current hp value, then change max hp value.
		-- This is to ensure that the damage fill size is not at 0
		-- However it should only trigger once, hence the flag
		if not updatedDamgeFillOnSpawn then
			updatedDamgeFillOnSpawn = true
			updateBarSize(char, "Damage")
			updateBarSize(char, "Health")
			updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
		else
			updateBarSize(char, "Health", true)
			updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
		end
	end)

	maxHPValue.Changed:Connect(function()
		updateBarSize(char, "Health")
		updateBarSize(char, "Damage")
		updateHPLabel(healthbarFrame.Parent, currentHPValue.Value, maxHPValue.Value)
	end)

	bindOwnerContainerListeners()
	bindShieldValueListener()

	healthbarFill.Parent = healthbarFrame
	damageFill.Parent = healthbarFrame

	return healthbarFrame
end

return {
	CreateHealthbar = createHealthbar,
	TweenHealthbarFill = tweenHealthbarFill,
	UpdateBarSize = updateBarSize,
}
