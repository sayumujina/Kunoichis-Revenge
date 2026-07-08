local TweenService = game:GetService("TweenService")
local createDamagePopupBillboard = require(script.Parent.Parent.Components.Combat.Damage.DamagePopup_Billboard)
local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
--
local totalDamage = 0
local damageTweens: { Tween } = {}
local DAMAGE_POPUP_LIFETIME = 1

-- Helper function to get the damage card
local function getDamageCard(playerGui: PlayerGui): Frame?
	local damageCard = playerGui:FindFirstChild("UI_DamageCard", true)
	if damageCard and damageCard:IsA("Frame") then
		return damageCard
	end

	return nil
end

-- Helper function to reset the total damage
local function resetTotalDamage()
	totalDamage = 0
end

-- Helper function to toggle the visibility of the damage card UI
local function toggleDamageUIVisibility(playerGui: PlayerGui, visible: boolean)
	local damageCard = getDamageCard(playerGui)
	if not damageCard then
		return
	end

	-- -- If the visibility state is already the same as the desired state, do nothing
	-- if damageCard.Visible == visible then
	-- 	warn("Damage card visibility is already set to " .. tostring(visible) .. ". No changes made.")
	-- 	return
	-- end

	-- -- Set the visibility of the damage card
	-- damageCard.Visible = visible

	-- Cancel any existing tween before creating a new one
	for _, tween in pairs(damageTweens) do
		tween:Cancel()
	end
	damageTweens = {}

	-- Create a fade effect for the damage card visibility change
	local labelTween = TweenService:Create(
		damageCard:FindFirstChild("TotalDamage_Label"),
		TweenInfo.new(0.1),
		{ TextTransparency = visible and 0 or 1 }
	)
	table.insert(damageTweens, labelTween)
	local valueTween = TweenService:Create(
		damageCard:FindFirstChild("TotalDamage_Value"),
		TweenInfo.new(0.1),
		{ TextTransparency = visible and 0 or 1 }
	)
	table.insert(damageTweens, valueTween)

	-- Play the tweens
	for _, tween in pairs(damageTweens) do
		tween:Play()
	end
end

-- Helper function to update the total damage UI on the damage card
local function updateTotalDamageUI(playerGui: PlayerGui, damage: number)
	-- Only update the total damage if the damage is positive (i.e., actual damage dealt)
	if damage < 0 then
		return
	end

	local damageCard = getDamageCard(playerGui)
	if not damageCard then
		return
	end

	-- Update the total damage value and display it on the damage card
	if not damageCard.Visible then
		damageCard.Visible = true
	end

	-- Update the total damage value and display it on the damage card
	totalDamage += damage

	-- Update the total damage value on the damage card UI
	local totalDamageValue = damageCard:FindFirstChild("TotalDamage_Value", true)
	if totalDamageValue and totalDamageValue:IsA("TextLabel") then
		totalDamageValue.Text = tostring(math.round(totalDamage))
	end
end

-- Helper function to create a damage popup above the target's head
local function createDamagePopup(playerGui: PlayerGui, damageData: _TYPES.Damage)
	local billboardGuiFolder = playerGui:FindFirstChild("UI_BillboardGui_Folder", true)
	if not billboardGuiFolder then
		return
	end

	-- If the damage is a critical hit, make the damage popup larger to emphasize the critical hit
	local damagePopupBillboard =
		createDamagePopupBillboard(damageData.target :: _TYPES.Character, damageData.isCrit, damageData.damage, false)
	damagePopupBillboard.Parent = billboardGuiFolder
	local damagePopupFrame = damagePopupBillboard:FindFirstChild("Damage_Popup", true)
	if not damagePopupFrame then
		return
	end

	local critLabel = nil
	local damageLabel = damagePopupFrame:FindFirstChild("DamagePopup_Label", true)

	-- If is crit, also twen the "CRIT" label to fade in and out
	if damageData.isCrit then
		critLabel = damagePopupFrame:FindFirstChild("Crit_Label", true)
		TweenService:Create(critLabel, TweenInfo.new(0.2), { TextTransparency = 0, TextStrokeTransparency = 0 }):Play()
	end

	TweenService:Create(damageLabel, TweenInfo.new(0.2), { TextTransparency = 0, TextStrokeTransparency = 0 }):Play()

	-- Wait for one second before fading out the damage popup
	task.delay(DAMAGE_POPUP_LIFETIME, function()
		warn("Fading out damage popup for target: " .. damageData.target.Name .. ", Damage: " .. damageData.damage)
		-- Tween the damage label to fade out
		TweenService:Create(damageLabel, TweenInfo.new(0.2), { TextTransparency = 1, TextStrokeTransparency = 1 })
			:Play()
		-- Tween the "CRIT" label to fade out if it exists
		if critLabel then
			TweenService:Create(critLabel, TweenInfo.new(0.2), { TextTransparency = 1, TextStrokeTransparency = 1 })
				:Play()
		end

		-- Destroy the damage popup billboard after the fade-out animation completes
		task.delay(0.2, function()
			damagePopupBillboard:Destroy()
		end)
	end)
end

-- Helper function to create a shield popup above the target's head
local function createShieldPopup(playerGui: PlayerGui, shieldData: { target: _TYPES.Character, shieldAmount: number })
	local billboardGuiFolder = playerGui:FindFirstChild("UI_BillboardGui_Folder", true)
	if not billboardGuiFolder then
		return
	end

	-- Create a shield popup above the target's head
	local shieldPopupBillboard =
		createDamagePopupBillboard(shieldData.target :: _TYPES.Character, false, shieldData.shieldAmount, true)
	shieldPopupBillboard.Parent = billboardGuiFolder
	local shieldPopupFrame = shieldPopupBillboard:FindFirstChild("Damage_Popup", true)
	if not shieldPopupFrame then
		return
	end

	local shieldLabel = shieldPopupFrame:FindFirstChild("DamagePopup_Label", true)

	-- Tween the shield label to fade in
	TweenService:Create(shieldLabel, TweenInfo.new(0.2), { TextTransparency = 0, TextStrokeTransparency = 0 }):Play()

	-- Wait for one second before fading out the shield popup
	task.delay(DAMAGE_POPUP_LIFETIME, function()
		warn(
			"Fading out shield popup for target: "
				.. shieldData.target.Name
				.. ", Shield Amount: "
				.. shieldData.shieldAmount
		)
		-- Tween the shield label to fade out
		TweenService:Create(shieldLabel, TweenInfo.new(0.2), { TextTransparency = 1, TextStrokeTransparency = 1 })
			:Play()

		-- Destroy the shield popup billboard after the fade-out animation completes
		task.delay(0.2, function()
			shieldPopupBillboard:Destroy()
		end)
	end)
end

return {
	ToggleDamageUIVisibility = toggleDamageUIVisibility,
	UpdateTotalDamageUI = updateTotalDamageUI,
	ResetTotalDamage = resetTotalDamage,
	CreateDamagePopup = createDamagePopup,
	CreateShieldPopup = createShieldPopup,
}
