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
		enemies: { _TYPES.Character },
		selectedEnemies: { _TYPES.Character },
		primarySelectedEnemyIndex: number, -- The main enemy index (in blast attacks)
	},
} =
	{}

--- Help function to sort enemies by their X position
--- @param enemies { _TYPES.Character }
local function sortEnemyTable(enemies: { _TYPES.Character }): { _TYPES.Character }
	table.sort(enemies, function(a, b)
		return a.HumanoidRootPart.Position.X < b.HumanoidRootPart.Position.X
	end)
	return enemies
end

local CombatController = {}

--- Called when the controller starts
function CombatController.OnStart()
	-- Initialise player data
	if not CombatData[localPlayer] then
		CombatData[localPlayer] = {
			enemies = workspace.Characters.Enemies:GetChildren(),
			selectedEnemies = {},
			primarySelectedEnemyIndex = 0,
		}
	end

	-- Sort enemies table
	CombatData[localPlayer].enemies = sortEnemyTable(CombatData[localPlayer].enemies)

	-- If there are enemies, mark the enemy in the middle as the primary selected enemy
	if #CombatData[localPlayer].enemies > 0 then
		CombatData[localPlayer].selectedEnemies[1] = CombatData[localPlayer].enemies[1]
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

	local primaryIndex = CombatData[localPlayer].primarySelectedEnemyIndex

	-- Find the index of the specified enemy in the selected enemies list
	if mode == "set" then
		primaryIndex = index
	elseif mode == "increment" then
		primaryIndex += index
	end

	warn("Primary selected enemy index switched to: " .. tostring(primaryIndex))

	-- Look at the newly selected enemy
	CameraController.LookAt(CombatData[localPlayer].enemies[primaryIndex].HumanoidRootPart.CFrame)

	-- Notify EffectsController to update selection marks
	-- EffectsController.HandleEnemySelectionMark(selectedEnemies, CombatData[localPlayer].primarySelectedEnemyIndex)

	-- Update primary selected enemy index
	CombatData[localPlayer].primarySelectedEnemyIndex = primaryIndex
end

--- Retrieve the current primary selected enemy index
function CombatController.GetPrimarySelectedEnemyIndex(): number
	return CombatData[localPlayer].primarySelectedEnemyIndex
end

return CombatController
