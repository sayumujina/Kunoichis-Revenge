-- Helper function to update the player's stats value
return function(playerGui: PlayerGui, newValue: number)
	-- Find the mana frame in the player's GUI
	local manaFrame = playerGui:FindFirstChild("UI_ManaFrame", true)

	if not manaFrame then
		return
	end

	-- Update the current mana value
	local currentManaValueObject = manaFrame:FindFirstChild("PlayerCurrentManaValue", true)
	if currentManaValueObject and currentManaValueObject:IsA("NumberValue") then
		currentManaValueObject.Value = newValue
	end
end
