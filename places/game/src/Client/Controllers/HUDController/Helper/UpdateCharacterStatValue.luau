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

local function getMatchingContainers(playerGui: PlayerGui, char: _TYPES.Character)
	local matchingContainers = {}

	for _, descendant in pairs(playerGui:GetDescendants()) do
		if not descendant:IsA("ObjectValue") or descendant.Name ~= "AssociatedCharValue" then
			continue
		end

		if descendant.Value ~= char or not descendant.Parent then
			continue
		end

		table.insert(matchingContainers, descendant.Parent)
	end

	return matchingContainers
end

return function(
	playerGui: PlayerGui,
	char: _TYPES.Character,
	statType: "realStats" | "currentStats",
	newStats: { [string]: number }
)
	local statTypeKey = statType == "realStats" and matchingRealStatsName or matchingCurrentStatsName

	for _, container in pairs(getMatchingContainers(playerGui, char)) do
		for statName, statValue in pairs(newStats) do
			if not statTypeKey[statName] then
				continue
			end

			local statValueObject = container:FindFirstChild("Character" .. statTypeKey[statName] .. "Value", true)
			if statValueObject then
				statValueObject.Value = statValue
			end
		end
	end
end
