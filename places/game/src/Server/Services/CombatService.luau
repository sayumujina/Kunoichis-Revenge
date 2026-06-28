local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)
local AnimationService = require(Services.AnimationService)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
-- Packages
local Zap = require(Services.Parent.zap)

local CombatService = {}

local CombatData: {
	[_TYPES.RobloxPlayerType]: {
		npcs: { _TYPES.Character },
		playables: { _TYPES.Character },
		primarySelectedTargetIndex: number, -- The main enemy index (for blast attacks)
	},
} =
	{}

--- Called when the service starts
function CombatService.OnStart()
	-- Listens to spawn finished event to initialise combat data for the player
	EventService.Events.SpawnFinished:Connect(function(data)
		if not data.player then
			return
		end

		-- Initialize combat data for the player
		CombatData[data.player] = {
			npcs = workspace.Characters.NPC:GetChildren(),
			playables = workspace.Characters.Playable:GetChildren(),
			primarySelectedTargetIndex = 0,
		}
		-- Count the number of enemies and set the primary selected enemy index to the middle one
		-- In case of the index not being an integer, it will round down to the lower index
		local enemyCount = #CombatData[data.player].npcs
		CombatData[data.player].primarySelectedTargetIndex = math.ceil(enemyCount / 2)
	end)

	-- Listens to turn started event
	EventService.Events.TurnStarted:Connect(function(turnData)
		local char = turnData.data.char
		if char :: any ~= turnData.data.char then
			return
		end

		local moveList = Utility.GetCharacterMoveList(char :: _TYPES.Character)
		for moveName, moveData in pairs(moveList) do
			-- If the move is not default, skip it
			if not moveData.isDefault then
				continue
			end

			-- Play the idle animation of the default move
			AnimationService.Play(char :: _TYPES.Character, moveName .. "_Idle")

			-- Update the move preview for the player with the default move
			CombatService.UpdateMovePreview(turnData.player, char :: _TYPES.Character, moveName)
			break
		end
	end)
end

--- Switches to the next target in the combat data for the player
--- @param player - The player whose target to switch
function CombatService.SwitchToPreviousTarget(player: _TYPES.RobloxPlayerType)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	local npcCount = #combatData.npcs
	if npcCount == 0 then
		return
	end

	-- If the primary selected target index is 1, don't change the index
	if combatData.primarySelectedTargetIndex == 1 then
		return
	end
	combatData.primarySelectedTargetIndex -= 1
end

--- Switches to the next target in the combat data for the player
--- @param player - The player whose target to switch
function CombatService.SwitchToNextTarget(player: _TYPES.RobloxPlayerType)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	local npcCount = #combatData.npcs
	if npcCount == 0 then
		return
	end

	-- If the primary selected target index is equal to the number of NPCs, don't change the index
	if combatData.primarySelectedTargetIndex == npcCount then
		return
	end
	combatData.primarySelectedTargetIndex += 1
end

--- Sets the primary selected target index for the player
--- @param player - The player whose target to set
function CombatService.SetPrimarySelectedTargetIndex(player: _TYPES.RobloxPlayerType, index: number)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	local npcCount = #combatData.npcs
	if npcCount == 0 then
		return
	end

	if index < 1 or index > npcCount then
		return
	end

	combatData.primarySelectedTargetIndex = index
end

--- Update the move preview for the player with the given move name and target selection type
--- @param player - The player whose move preview to update
--- @param moveName - The name of the move to preview
function CombatService.UpdateMovePreview(player: _TYPES.RobloxPlayerType, char: _TYPES.Character, moveName: string)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	local moveList = Utility.GetCharacterMoveList(char :: _TYPES.Character)
	local moveData = moveList[moveName]
	if not moveData then
		return
	end

	Zap.UpdateMovePreview.Fire(player, {
		char = char,
		data = {
			moveName = moveName,
			primaryTargetIndex = combatData.primarySelectedTargetIndex,
		},
	})
end

--- Get the combat data for the player
--- @param player - The player whose combat data to get
function CombatService.GetCombatData(player: _TYPES.RobloxPlayerType)
	return CombatData[player]
end

return CombatService
