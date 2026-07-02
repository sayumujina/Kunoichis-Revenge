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
-- Constants
local START_TURN_TIMEOUT = 2 -- second(s)

local CombatService = {}

local CombatData: {
	[_TYPES.RobloxPlayerType]: {
		npcs: { _TYPES.Character },
		playables: { _TYPES.Character },
		primarySelectedTargetIndex: number, -- The main enemy index (for blast attacks)
		--
		isProcessingAttack: boolean, -- Whether the player is currently processing an attack
		startTurnTimeout: any, -- Timeout before starting the next turn
	},
} =
	{}

--- Called when the service starts
function CombatService.OnStart()
	-- Listens to spawn finished event to initialise combat data for the player
	EventService.Events.SpawnFinished:Connect(function(data)
		local player = data.player
		if not player then
			return
		end

		-- Initialize combat data for the player
		CombatData[player] = {
			npcs = workspace.Characters.NPC:GetChildren(),
			playables = workspace.Characters.Playable:GetChildren(),
			primarySelectedTargetIndex = 0,
			--
			isProcessingAttack = false,
			startTurnTimeout = Utility.SetupTimeout(START_TURN_TIMEOUT),
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

		local defaultMove = Utility.GetCharacterDefaultMove(char :: _TYPES.Character)
		if not defaultMove then
			return
		end
		-- Play the idle animation of the default move
		AnimationService.Play(char :: _TYPES.Character, defaultMove .. "_Idle")
		-- Update the move preview for the player with the default move
		CombatService.UpdateMovePreview(turnData.player, char :: _TYPES.Character, defaultMove)
	end)

	-- Clean up combat data for the player when they leave the game
	game.Players.PlayerRemoving:Connect(function(player)
		if CombatData[player].startTurnTimeout then
			CombatData[player].startTurnTimeout:Destroy()
		end
		CombatData[player] = nil
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

--- Sets the attacking state for the player
--- @param player - The player whose attacking state to set
--- @param isAttacking - Whether the player is currently processing an attack
function CombatService.SetAttackingState(player: _TYPES.RobloxPlayerType, isAttacking: boolean)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	combatData.isProcessingAttack = isAttacking
end

--- Get the combat data for the player
--- @param player - The player whose combat data to get
function CombatService.GetCombatData(player: _TYPES.RobloxPlayerType)
	return CombatData[player]
end

return CombatService
