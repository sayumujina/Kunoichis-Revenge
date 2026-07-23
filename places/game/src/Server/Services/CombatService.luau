local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)
local AnimationService = require(Services.AnimationService)
local PlayerService = require(Services.PlayerService)
-- Utility
local Utility = require(rep.Shared.Modules.Utility)
-- Packages
local Zap = require(Services.Parent.zap)
-- Data
local Stages = require(rep.Data.data_Stages)

local CombatService = {}

local CombatData: {
	[_TYPES.RobloxPlayerType]: {
		npcs: { _TYPES.Character },
		playables: { _TYPES.Character },
		selectedNPCIndex: number, -- The main enemy index (for blast attacks)
		selectedPlayableIndex: number, -- The main playable index (for blast attacks)
		--
		battleFinished: boolean, -- Whether the battle has finished for the player
		elapsedActionValue: number, -- The total action value used by the player in the current stage
		downedCharacters: number, -- The total number of downed characters in the current stage
		--
		currentStageData: {
			stageId: string,
			worldId: string,
			extraObjectives: { [string]: { objectiveInfo: _TYPES.ExtraObjective, failed: boolean } }?,
		},
		--
		isProcessingAttack: boolean, -- Whether the player is currently processing an attack
	},
} =
	{}

--- Called when the service starts
function CombatService.OnStart()
	-- Listens to spawn finished event to initialise combat data for the player
	EventService.Events.SpawnFinished:Connect(function(spawnData)
		local player = spawnData.player
		if not player then
			return
		end

		-- Get the stage data for the current stage
		local stageData = Stages[spawnData.data.stageData.worldId]
				and Stages[spawnData.data.stageData.worldId].stages[spawnData.data.stageData.stageId]
			or nil

		local objectives = {}
		-- Store a copy of the extra objectives for the stage along with a failed flag for each objective
		if stageData and stageData.extraObjectives then
			for _, objective in pairs(stageData.extraObjectives) do
				objectives[objective.objectiveId] = { objectiveInfo = objective, failed = false }
			end
		end

		-- Initialize combat data for the player
		CombatData[player] = {
			npcs = workspace.Characters.NPC:GetChildren(),
			playables = workspace.Characters.Playable:GetChildren(),
			selectedNPCIndex = 0,
			selectedPlayableIndex = 0,
			--
			battleFinished = false,
			elapsedActionValue = 0,
			downedCharacters = 0,
			--
			currentStageData = {
				stageId = spawnData.data.stageData.stageId,
				worldId = spawnData.data.stageData.worldId,
				extraObjectives = objectives,
			},
			--
			isProcessingAttack = false,
		}

		-- Count the number of enemies and set the primary selected enemy index to the middle one
		-- In case of the index not being an integer, it will round down to the lower index
		local enemyCount = #CombatData[player].npcs
		local playableCount = #CombatData[player].playables
		CombatData[player].selectedNPCIndex = math.ceil(enemyCount / 2)
		CombatData[player].selectedPlayableIndex = math.ceil(playableCount / 2)
	end)

	-- Listens to turn started event
	EventService.Events.TurnStarted:Connect(function(turnData)
		local char = turnData.data.char
		if char :: any ~= turnData.data.char then
			return
		end

		-- Play the default idle animation for the character at the start of their turn
		AnimationService.PlayDefaultIdleAnimation(char :: _TYPES.Character)

		-- Update the move preview for the player with the default move
		local defaultMove = Utility.GetCharacterDefaultMove(char :: _TYPES.Character)
		CombatService.UpdateMovePreview(turnData.player, char :: _TYPES.Character, defaultMove)
	end)

	-- Listens to death event to remove the dead character from the combat data
	EventService.Events.Death:Connect(function(deathEvent)
		-- Get the player who owns the dead character
		local deadChar = deathEvent.char
		local player = PlayerService.GetPlayerFromCharacter(deadChar)

		if not player then
			return
		end

		local combatData = CombatData[player]
		if not combatData then
			return
		end

		local deadCharIndex = deadChar:GetAttribute("Index")

		-- If the dead character is the npc, simply destroy it
		if deadChar:GetAttribute("Side") == "NPC" then
			deadChar:Destroy()

			-- Update the indexes of the remaining npcs
			local list = combatData.npcs
			local index = table.find(list, deadChar)
			if index then
				table.remove(list, index)
				for i, char in pairs(list) do
					char:SetAttribute("Index", i)
				end
			end

			-- Reposition the remaining characters of the side
			Utility.RepositionCharactersOfSide(deadChar:GetAttribute("Side") :: _TYPES.Sides)
			-- If the dead character is a playable, play the downed animation but do not destroy it
		else
			-- Mark the character as downed
			deadChar:SetAttribute("Downed", true)

			-- Add 1 to the downed characters count for the player
			combatData.downedCharacters += 1

			-- Check if the player has failed the downed characters objective
			for objectiveId, objective in pairs(combatData.currentStageData.extraObjectives or {}) do
				if objective.conditionType ~= "DownedCharacters" or objective.failed then
					continue
				end
				if combatData.downedCharacters > objective.value then
					objective.failed = true

					-- Fire the ObjectiveFailed event to notify the client that the player has failed the objective
					EventService.Events.ObjectiveFailed:Fire({
						player = player,
						data = { objectiveId = objectiveId },
					})
				end
			end

			-- Set their original index value for the camera to use as reference
			deadChar:SetAttribute("originalIndex", deadCharIndex)

			-- Set their index to 0 so that they are not selectable as a target
			deadChar:SetAttribute("Index", 0)

			local anim = AnimationService.Play(deadChar, "Downed")
			if not anim then
				warn("Failed to play downed animation for character: " .. deadChar.Name)
				return
			end

			anim.Stopped:Connect(function()
				-- Play the downed loop animation after the downed animation finishes
				AnimationService.Play(deadChar, "Downed_Loop")
			end)
		end

		-- If the dead character was the primary selected target, switch to the previous target if that index is no longer there
		if deadChar:GetAttribute("Side") == "NPC" then
			if deadCharIndex > #combatData.npcs then
				CombatService.SwitchToPreviousTarget(player, deadChar:GetAttribute("Side") :: _TYPES.Sides)
			end
		else
			if deadCharIndex > #combatData.playables then
				CombatService.SwitchToPreviousTarget(player, deadChar:GetAttribute("Side") :: _TYPES.Sides)
			end
		end

		-- If one side has no more characters, the stage is completed
		if #combatData.playables == 0 or #combatData.npcs == 0 then
			combatData.battleFinished = true
		end

		if #combatData.npcs == 0 then
			-- Compile the successful extra objectives for the player
			local successfulObjectives = {}
			for objectiveId, objective in pairs(combatData.currentStageData.extraObjectives or {}) do
				if not objective.failed then
					table.insert(successfulObjectives, objectiveId)
				end
			end

			-- Fire the BattleEnded event to notify the client that the player has completed the stage
			EventService.Events.BattleEnded:Fire({
				player = player,
				data = {
					passed = true,
					stageId = combatData.currentStageData.stageId,
					worldId = combatData.currentStageData.worldId,
					successfulExtraObjectives = successfulObjectives,
				},
			})
		elseif combatData.downedCharacters == #combatData.playables then
			-- Fire the BattleEnded event to notify the client that the player has completed the stage
			EventService.Events.BattleEnded:Fire({
				player = player,
				data = {
					passed = false,
					stageId = combatData.currentStageData.stageId,
					worldId = combatData.currentStageData.worldId,
					successfulExtraObjectives = nil,
				},
			})
		end
	end)

	-- Clean up combat data for the player when they leave the game
	game.Players.PlayerRemoving:Connect(function(player)
		CombatData[player] = nil
	end)

	-- Listen to despawn event to clean up combat data for the player
	EventService.Events.DespawnSuccessful:Connect(function(despawnEvent)
		local player = despawnEvent.player
		CombatData[player] = nil
	end)
end

--- Switches to the next target in the combat data for the player
--- @param player - The player whose target to switch
--- @param side - The side to switch targets on ("Playable" or "NPC")
function CombatService.SwitchToPreviousTarget(player: _TYPES.RobloxPlayerType, side: _TYPES.Sides)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	local charsCount = if side == "Playable" then #combatData.playables else #combatData.npcs
	if charsCount == 0 then
		return
	end

	-- Collect all the available indexes
	if side == "NPC" then
		combatData.selectedNPCIndex = math.clamp(combatData.selectedNPCIndex - 1, 1, charsCount)
	else
		local availableIndexes = {}
		for _, char in pairs(combatData.playables) do
			if not char:GetAttribute("Downed") then
				table.insert(availableIndexes, char:GetAttribute("Index"))
			end
		end

		-- Do not switch target if it can't be found
		local newIndex = math.clamp(combatData.selectedPlayableIndex - 1, 1, charsCount)
		warn(availableIndexes, newIndex)
		if not table.find(availableIndexes, newIndex) then
			return
		end
		combatData.selectedPlayableIndex = newIndex
	end
end

--- Switches to the next target in the combat data for the player
--- @param player - The player whose target to switch
--- @param side - The side to switch targets on ("Playable" or "NPC")
function CombatService.SwitchToNextTarget(player: _TYPES.RobloxPlayerType, side: _TYPES.Sides)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	local charsCount = if side == "Playable" then #combatData.playables else #combatData.npcs
	if charsCount == 0 then
		return
	end

	if side == "NPC" then
		combatData.selectedNPCIndex = math.clamp(combatData.selectedNPCIndex + 1, 1, charsCount)
	else
		local availableIndexes = {}
		for _, char in pairs(combatData.playables) do
			if not char:GetAttribute("Downed") then
				table.insert(availableIndexes, char:GetAttribute("Index"))
			end
		end

		-- Do not switch target if it can't be found
		local newIndex = math.clamp(combatData.selectedPlayableIndex + 1, 1, charsCount)
		warn(availableIndexes, newIndex)
		if not table.find(availableIndexes, newIndex) then
			return
		end
		combatData.selectedPlayableIndex = newIndex
	end
end

--- Sets the primary selected target index for the player
--- @param player - The player whose target to set
--- @param index - The index to set as the primary selected target
--- @param side - The side to set the target on ("Playable" or "NPC")
function CombatService.SetPrimarySelectedTargetIndex(player: _TYPES.RobloxPlayerType, index: number, side: _TYPES.Sides)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	local charsCount = if side == "Playable" then #combatData.playables else #combatData.npcs
	if charsCount == 0 then
		return
	end

	if index < 1 or index > charsCount then
		return
	end

	if side == "NPC" then
		combatData.selectedNPCIndex = index
	else
		combatData.selectedPlayableIndex = index
	end
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

	-- If the primary target index is valid, update the move preview with the current primary target index
	local primaryTargetIndex = if moveData.selectedSide == "Playable"
		then combatData.selectedPlayableIndex
		else combatData.selectedNPCIndex
	local charsCount = if moveData.selectedSide == "Playable" then #combatData.playables else #combatData.npcs

	if primaryTargetIndex < 1 or primaryTargetIndex > charsCount then
		warn("Invalid primary target index for move preview:", primaryTargetIndex, "for move:", moveName)
		return
	end

	Zap.UpdateMovePreview.Fire(player, {
		char = char,
		data = {
			moveName = moveName,
			primaryTargetIndex = primaryTargetIndex,
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

--- Update the elapsed action value for the player
--- @param player - The player whose elapsed action value to update
--- @param value - The value to add to the elapsed action value
function CombatService.IncrementElapsedActionValue(player: _TYPES.RobloxPlayerType, value: number)
	local combatData = CombatData[player]
	if not combatData then
		return
	end

	combatData.elapsedActionValue += value

	-- Fire the ActionValueElapsed event to notify the client of the updated elapsed action value
	EventService.Events.ActionValueElapsed:Fire({
		player = player :: _TYPES.RobloxPlayerType,
		data = {
			currentTotalActionValue = combatData.elapsedActionValue,
		},
	})

	--

	-- If the elapsed action value exceeds the extra objective values, mark that objective as failed
	for objectiveId, objective in pairs(combatData.currentStageData.extraObjectives or {}) do
		-- Skip if the objective is not of type "UsedActionValue" or if it has already been marked as failed
		if objective.objectiveInfo.conditionType ~= "UsedActionValue" or objective.failed then
			continue
		end

		-- If the elapsed action value exceeds the objective value, mark the objective as failed
		if combatData.elapsedActionValue > objective.objectiveInfo.value then
			objective.failed = true

			-- Fire the ObjectiveFailed event to notify the client that the player has failed the objective
			EventService.Events.ObjectiveFailed:Fire({
				player = player,
				data = { objectiveId = objectiveId },
			})
		end
	end
end

return CombatService
