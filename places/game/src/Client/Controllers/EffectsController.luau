local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local rep = game:GetService("ReplicatedStorage")
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)
--
local localPlayer = game:GetService("Players").LocalPlayer

--- @class EffectsController
--- @server
--- @tag Client
local EffectsController = {}

local allEnemies: { _TYPES.Character }

--- Called when the controller starts
function EffectsController.OnStart()
	-- Listen to spawn finished event
	Zap.SpawnFinished.On(function()
		-- Get all enemies
		allEnemies = workspace.Characters.Enemies:GetChildren() :: { _TYPES.Character }
	end)
end

-- Helper function to toggle the highlight effect on selected enemies
local function toggleHighlights(target: _TYPES.Character, enable: boolean)
	local highlight = target:FindFirstChild("Highlight")
	if highlight and highlight:IsA("Highlight") then
		highlight.Enabled = enable
	end
end

--- Enable selection mark effects on the selected targets
--- @param targets { _TYPES.Character }
function EffectsController.EnableTargetsSelectionMark(
	side: "Allies" | "Enemies",
	targets: { _TYPES.Character },
	primaryIndex: number?
)
	-- Toggle selection mark for selected targets

	-- 1. Turn off all the selection marks for the opposite side
	local oppositeSide = side == "Allies" and "Enemies" or "Allies"
	for _, target in pairs(workspace.Characters[oppositeSide]:GetChildren()) do
		toggleHighlights(target, false)
	end

	-- 2. Turn on the selection marks for the selected targets
	for _, target in pairs(workspace.Characters[side]:GetChildren()) do
		if table.find(targets, target) then
			toggleHighlights(target, true)
		else
			toggleHighlights(target, false)
		end
	end
end

--- Disable selection mark effects on all targets
function EffectsController.DisableAllSelectionMark()
	-- Toggle selection mark for all enemies
	for _, enemy in pairs(allEnemies) do
		toggleHighlights(enemy, false)
	end
end

return EffectsController
