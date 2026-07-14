local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Packages
local TableUtil = require(rep.Packages.TableUtil)

--- This utility is for NPCs to determine the primary target index for their moves
return function(): number?
	local playablesFolder = game.Workspace.Characters.Playable -- NPCs are on the NPC side and their targets are in the Playable folder
	if not playablesFolder then
		warn("Playable folder not found in Workspace.")
		return nil
	end

	-- Randomly select a target from the Playable folder
	-- Filter downed characters (if any) and only select from the remaining characters
	local playables = playablesFolder:GetChildren()
	-- Filter out downed characters
	playables = TableUtil.Filter(playables, function(char)
		return not char:GetAttribute("Downed")
	end)

	if #playables == 0 then
		warn("No playable characters found in the Playable folder.")
		return nil
	end

	local shuffledPlayables = TableUtil.Shuffle(playables)
	local randomIndex = shuffledPlayables[1]:GetAttribute("Index") -- Get the Index attribute of the randomly selected character

	return randomIndex
end
