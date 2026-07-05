local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)

--- This utility is for NPCs to determine the primary target index for their moves
return function(): number?
	local playablesFolder = game.Workspace.Characters.Playable -- NPCs are on the NPC side and their targets are in the Playable folder
	if not playablesFolder then
		warn("Playable folder not found in Workspace.")
		return nil
	end

	-- Randomly select a target from the Playable folder
	local playables = playablesFolder:GetChildren()
	if #playables == 0 then
		warn("No playable characters found in the Playable folder.")
		return nil
	end

	local randomIndex = math.random(1, #playables)
	warn("Randomly selected primary target index:", randomIndex)

	return randomIndex
end
