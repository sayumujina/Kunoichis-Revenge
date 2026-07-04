local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
local _TYPES_CHAR = require(rep.Shared.Data.Characters.Playable.Setsuna.data_Setsuna_Types)
-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.Services
local TurnService = require(Services.TurnService)
local PlayerService = require(Services.PlayerService)
local CombatService = require(Services.CombatService)
local EventService = require(Services.EventService)
-- Packages
local Trove = require(rep.Packages.Trove)

-- Attack handlers
local Handlers = {
	WeavingBlade = require(script.Parent.Handlers.Setsuna_WeavingBlade),
	TwinBlades = require(script.Parent.Handlers.Setsuna_TwinBlades),
} :: { [string]: (_TYPES.Character, _TYPES_CHAR.ServerCharData) -> boolean }

-- Action to move mapping at the top of the file
local ActionToMoveMap = {
	BasicAttack = "WeavingBlade",
	Skill = "TwinBlades",
}

local charName = "Setsuna"
local Chars = {} :: { [_TYPES.Character]: _TYPES_CHAR.ServerCharData }

local Setsuna_CombatService = {}

function Setsuna_CombatService.OnStart() end

function Setsuna_CombatService.Init(char: _TYPES.Character)
	-- Initialize the character's combat data if it doesn't exist
	if not Chars[char] then
		Chars[char] = {
			Info = {
				selectedMove = "WeavingBlade",
			},
			Trove = Trove.new(),
		} :: _TYPES_CHAR.ServerCharData
	end

	-- Clean up when the character is destroyed
	char.Destroying:Connect(function()
		if Chars[char] then
			Chars[char].Trove:Destroy()
			Chars[char] = nil
		end
	end)
end

--- Handle input for Setsuna's combat service
--- @param char -- The character performing the action
--- @param inputData -- The input data containing the action and target information
function Setsuna_CombatService.HandleInput(char: _TYPES.Character, inputData: _TYPES.InputData)
	-- Check if the input is for this character
	local currentTurnChar =
		TurnService.GetCurrentTurn(PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType)
	if not currentTurnChar or char :: any ~= currentTurnChar.char then
		return false
	end

	local player = PlayerService.GetPlayerFromCharacter(char) :: _TYPES.RobloxPlayerType
	local action = inputData.action

	local charData = Chars[char]

	-- Handle target selection actions
	if action == "PreviousTarget" then
		CombatService.SwitchToPreviousTarget(player)
		CombatService.UpdateMovePreview(player, char, charData.Info.selectedMove)
		return true
	elseif action == "NextTarget" then
		CombatService.SwitchToNextTarget(player)
		CombatService.UpdateMovePreview(player, char, charData.Info.selectedMove)
		return true
	-- Handle move selection actions
	elseif ActionToMoveMap[action] then
		local mappedMove = ActionToMoveMap[action]

		-- If the move isn't the same as the currently selected move, it means the player is selecting a new move
		-- Only confirm the move if the player has selected the same move twice in a row
		if mappedMove and charData.Info.selectedMove ~= mappedMove then
			charData.Info.selectedMove = mappedMove
			-- Update the selection type reference for the new move
			CombatService.UpdateMovePreview(player, char, mappedMove)

			return true
		end

		-- Handle the input based on the action
		if charData.Info.selectedMove == "WeavingBlade" then
			return Handlers.WeavingBlade(char, charData)
		elseif charData.Info.selectedMove == "TwinBlades" then
			return Handlers.TwinBlades(char, charData)
		end
	end

	return false
end

--- Get the attack handlers for Setsuna's combat service
function Setsuna_CombatService.GetAttackHandlers()
	return Handlers
end

return Setsuna_CombatService
