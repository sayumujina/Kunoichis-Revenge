local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local EffectsController = require(StarterPlayerScripts.Client.Controllers.EffectsController)
local CameraController = require(StarterPlayerScripts.Client.Controllers.CameraController)
--
local localPlayer = game:GetService("Players").LocalPlayer

--- @type PlayerData {[_TYPES.RobloxPlayerType]: { selectionMark: Instance }}
--- @within PlayerController
--- A collection of character data.
local CombatData: {
	[_TYPES.RobloxPlayerType]: {
		currentCharacter: _TYPES.Character,
		--
		enemies: { _TYPES.Character },
		primarySelectedEnemyIndex: number, -- The main enemy index (in blast attacks)
	},
} =
	{}

--- Help function to sort enemies by their X position
--- @param enemies { _TYPES.Character }
local function sortEnemyTable(enemies: { _TYPES.Character }): { _TYPES.Character }
	table.sort(enemies, function(a, b)
		return a.HumanoidRootPart.Position.X > b.HumanoidRootPart.Position.X
	end)
	return enemies
end

local CombatController = {}

--- Called when the controller starts
function CombatController.OnStart()
	-- Initialise player data
	if not CombatData[localPlayer] then
		CombatData[localPlayer] = {
			currentCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait(),
			--
			enemies = workspace.Characters.Enemies:GetChildren(),
			primarySelectedEnemyIndex = 0,
		}
	end

	-- Sort enemies table
	CombatData[localPlayer].enemies = sortEnemyTable(CombatData[localPlayer].enemies)

	-- If there are enemies, mark the enemy in the middle as the primary selected enemy
	if #CombatData[localPlayer].enemies > 0 then
		CombatData[localPlayer].primarySelectedEnemyIndex = math.ceil(#CombatData[localPlayer].enemies / 2)
	else
		CombatData[localPlayer].primarySelectedEnemyIndex = 0
	end
end

--- Handle switching primary selected enemy
function CombatController.SwitchPrimarySelectedEnemy(mode: "set" | "increment", index: number)
	if not CombatData[localPlayer].primarySelectedEnemyIndex then
		warn("No primary selected enemy index found!")
		return
	end

	warn(CombatData[localPlayer].enemies)
	local primaryIndex = CombatData[localPlayer].primarySelectedEnemyIndex

	-- Find the index of the specified enemy in the selected enemies list
	if mode == "set" then
		primaryIndex = index
	elseif mode == "increment" then
		-- Clamp the new index within valid range
		primaryIndex = math.clamp(primaryIndex + index, 1, #CombatData[localPlayer].enemies)
	end

	warn("Primary selected enemy index switched to: " .. tostring(primaryIndex))

	-- Notify EffectsController to update selection marks
	-- EffectsController.HandleEnemySelectionMark(selectedEnemies, CombatData[localPlayer].primarySelectedEnemyIndex)

	-- Update primary selected enemy index
	CombatData[localPlayer].primarySelectedEnemyIndex = primaryIndex

	warn(CombatData[localPlayer].enemies[primaryIndex])
	-- Look at the newly selected enemy
	CameraController.LookAtTarget(CombatData[localPlayer].enemies, CombatData[localPlayer].currentCharacter)
end

--- Retrieve the current primary selected enemy index
function CombatController.GetPrimarySelectedEnemyIndex(): number
	return CombatData[localPlayer].primarySelectedEnemyIndex
end

return CombatController
