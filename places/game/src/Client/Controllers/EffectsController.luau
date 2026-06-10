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
		warn("Spawn finished, effects controller received the signal!")
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

--- Handle effects on the selected enemy(s)
--- @param targets { _TYPES.Character }
function EffectsController.HandleTargetsSelectionMark(targets: { _TYPES.Character }, primaryIndex: number?)
	-- Toggle selection mark for selected enemies
	for _, enemy in pairs(allEnemies) do
		-- If the enemy is in the selected enemies list, highlight
		if table.find(targets, enemy) then
			toggleHighlights(enemy, true)
		else
			toggleHighlights(enemy, false)
		end
	end
end

return EffectsController
