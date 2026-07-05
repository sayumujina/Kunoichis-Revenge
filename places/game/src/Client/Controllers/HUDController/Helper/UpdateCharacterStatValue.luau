local _TYPES = require(game.ReplicatedStorage.Shared.data_Types)

local matchingCurrentStatsName = {
	["energy"] = "CurrentEnergy",
	["hp"] = "CurrentHP",
	["exposure"] = "CurrentExposure",
	["shield"] = "CurrentShield",
}

local matchingRealStatsName = {
	["energy"] = "MaxEnergy",
	["hp"] = "MaxHP",
	["exposure"] = "MaxExposure",
	-- ["shield"] = "MaxShield",
}

-- Helper function to update the stats value of a character
return function(
	playerGui: PlayerGui,
	char: _TYPES.Character,
	statType: "realStats" | "currentStats",
	newStats: { [string]: number }
)
	local characterInfoContainer

	-- Depending on the side of the character
	-- For playable characters, look in the character info frame
	-- For NPCs, look in the billboard gui
	if char:GetAttribute("Side") == "Playable" then
		characterInfoContainer = playerGui:FindFirstChild("UI_CharacterInfoFrame", true)
	else
		characterInfoContainer = playerGui:FindFirstChild("UI_BillboardGui_Folder", true)
	end

	if not characterInfoContainer then
		return
	end

	local statTypeKey = statType == "realStats" and matchingRealStatsName or matchingCurrentStatsName

	-- Find the corresponding character info card using the character reference and update the stat value
	for _, container in pairs(characterInfoContainer:GetChildren()) do
		-- Check if the card is a Frame and has the AssociatedCharValue object value, then compare the character reference
		local associatedCharValue = container:FindFirstChild("AssociatedCharValue", true)
		if not associatedCharValue then
			continue
		end

		-- If the associated character value does not match the character whose stats changed, skip this card
		if associatedCharValue.Value ~= char then
			continue
		end

		-- Update the stat values on the character info card based on the changed stats
		for statName, statValue in pairs(newStats) do
			-- Check if the stat name is one of the stats we are tracking
			if not statTypeKey[statName] then
				continue
			end

			-- Replace the stat value on the character info card with the updated stat value
			local statValueObject = container:FindFirstChild("Character" .. statTypeKey[statName] .. "Value", true)
			if statValueObject then
				statValueObject.Value = statValue
			end
		end

		-- Since we found the matching char and updated its stats, we can break out of the loop
		break
	end
end
