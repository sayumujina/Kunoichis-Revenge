local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)
local AnimationService = require(Services.AnimationService)
local PlayerService = require(Services.PlayerService)
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
		--
		isProcessingAttack: boolean, -- Whether the player is currently processing an attack
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

		if player then
			local deadCharIndex = deadChar:GetAttribute("Index")

			-- If the dead character was the primary selected target, switch to the next target
			if CombatData[player].primarySelectedTargetIndex == deadCharIndex then
				CombatService.SwitchToNextTarget(player, deadChar:GetAttribute("Side") :: _TYPES.Sides)
			end

			-- If the dead character is the npc, simply destroy it
			if deadChar:GetAttribute("Side") == "NPC" then
				deadChar:Destroy()

				-- Update the indexes of the remaining npcs
				local list = CombatData[player].npcs
				table.remove(list, table.find(list, deadChar))
				for i, char in pairs(list) do
					char:SetAttribute("Index", i)
				end

				-- Reposition the remaining characters of the side
				Utility.RepositionCharactersOfSide(deadChar:GetAttribute("Side") :: _TYPES.Sides)
			-- If the dead character is a playable, play the downed animation
			else
				-- Mark the character as downed
				deadChar:SetAttribute("Downed", true)

				-- Set their index to 0 so that they are not selectable as a target
				deadChar:SetAttribute("Index", 0)

				local anim = AnimationService.Play(deadChar, "Downed")
				if not anim then
					warn("Failed to play downed animation for character: " .. deadChar.Name)
				end

				anim.Stopped:Connect(function()
					-- Play the downed loop animation after the downed animation finishes
					AnimationService.Play(deadChar, "Downed_Loop")
				end)
			end
		end
	end)

	-- Clean up combat data for the player when they leave the game
	game.Players.PlayerRemoving:Connect(function(player)
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

	combatData.primarySelectedTargetIndex = math.clamp(combatData.primarySelectedTargetIndex - 1, 1, charsCount)
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

	combatData.primarySelectedTargetIndex = math.clamp(combatData.primarySelectedTargetIndex + 1, 1, charsCount)
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

	warn("Setting primary selected target index for player:", player.Name, "to index:", index, "on side:", side)
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

	-- If the primary target index is valid, update the move preview with the current primary target index
	local primaryTargetIndex = combatData.primarySelectedTargetIndex
	local charsCount = if moveData.selectedSide == "Playable" then #combatData.playables else #combatData.npcs
	if primaryTargetIndex < 1 or primaryTargetIndex > charsCount then
		warn("Invalid primary target index for move preview:", primaryTargetIndex, "for move:", moveName)
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
