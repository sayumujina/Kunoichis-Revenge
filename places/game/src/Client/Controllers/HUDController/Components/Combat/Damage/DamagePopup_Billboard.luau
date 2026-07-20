local _TYPES = require(game:GetService("ReplicatedStorage").Data.data_Types)

-- Popup sizes
local NORMAL_POPUP_SIZE = UDim2.fromScale(4, 2)
local CRIT_POPUP_SIZE = UDim2.fromScale(7, 3.75)
local DAMAGE_TEXT_COLOR = Color3.new(1, 1, 1)
local HEAL_TEXT_COLOR = Color3.fromRGB(85, 255, 0)
local SHIELD_TEXT_COLOR = Color3.fromRGB(255, 170, 0)

local RANDOM_OFFSET_MIN_DISTANCE = 0.2
local rng = Random.new()
local function randomiseAxisOffset()
	local direction = if rng:NextNumber() < 0.5 then -1 else 1
	return direction * rng:NextNumber(RANDOM_OFFSET_MIN_DISTANCE, 1)
end

local function randomiseOffset()
	local xOffset = randomiseAxisOffset()
	local yOffset = rng:NextNumber(-1, 1)
	return Vector3.new(xOffset, yOffset, -3)
end

return function(target: _TYPES.Character, isCrit: boolean, damage: number, isShield: boolean)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "BillboardGui"
	billboardGui.Active = true
	billboardGui.ClipsDescendants = true
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 1
	billboardGui.Size = if isCrit then CRIT_POPUP_SIZE else NORMAL_POPUP_SIZE
	billboardGui.StudsOffsetWorldSpace = randomiseOffset()
	billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	billboardGui.Adornee = target.HumanoidRootPart

	local damagePopup = Instance.new("Frame")
	damagePopup.Name = "Damage_Popup"
	damagePopup.BackgroundTransparency = 1
	damagePopup.Size = UDim2.fromScale(1, 1)

	local critLabel = Instance.new("TextLabel")
	critLabel.Name = "Crit_Label"
	critLabel.BackgroundTransparency = 1
	critLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	critLabel.Position = UDim2.fromScale(0.325, 0)
	critLabel.Size = UDim2.fromScale(0.35, 0.35)
	critLabel.Text = "CRIT"
	critLabel.TextColor3 = Color3.new(1, 1, 1)
	critLabel.TextScaled = true
	critLabel.TextStrokeTransparency = 0
	critLabel.TextTransparency = 1
	--
	critLabel.Parent = damagePopup

	local damagePopupLabel = Instance.new("TextLabel")
	damagePopupLabel.Name = "DamagePopup_Label"
	damagePopupLabel.BackgroundTransparency = 1
	damagePopupLabel.FontFace =
		Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	damagePopupLabel.Position = UDim2.fromScale(0.2, 0.2)
	damagePopupLabel.Size = UDim2.fromScale(0.6, 0.6)
	-- Add a "+" sign for healing
	damagePopupLabel.Text = if damage < 0 or isShield
		then "+" .. tostring(math.round(math.abs(damage)))
		else tostring(math.round(damage))
	damagePopupLabel.TextColor3 = if damage < 0
		then HEAL_TEXT_COLOR
		elseif isShield then SHIELD_TEXT_COLOR
		else DAMAGE_TEXT_COLOR
	damagePopupLabel.TextScaled = true
	damagePopupLabel.TextStrokeTransparency = 0
	damagePopupLabel.TextTransparency = 1
	--
	damagePopupLabel.Parent = damagePopup

	damagePopup.Parent = billboardGui

	return billboardGui
end
