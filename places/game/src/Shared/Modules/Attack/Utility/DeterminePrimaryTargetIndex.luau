local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)

--- This utility is for NPCs to determine the primary target index for their moves
return function(): number?
	local alliesFolder = game.Workspace.Characters.Allies -- NPCs are on the Enemies side and their targets are in the Allies folder
	if not alliesFolder then
		warn("Allies folder not found in Workspace.")
		return nil
	end

	-- Randomly select a target from the Allies folder
	local allies = alliesFolder:GetChildren()
	if #allies == 0 then
		warn("No allies found in the Allies folder.")
		return nil
	end

	local randomIndex = math.random(1, #allies)

	return randomIndex
end
