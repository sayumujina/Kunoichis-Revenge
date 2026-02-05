local _TYPES = require(game:GetService("ReplicatedStorage").Shared.data_Types)
local rep = game:GetService("ReplicatedStorage")
--
local localPlayer = game:GetService("Players").LocalPlayer

--- @class EffectsController
--- @server
--- @tag Client
local EffectsController = {}

local allEnemies: { _TYPES.Character }

local function applyHighlightEffectToEnemy(enemy: _TYPES.Character, show: boolean?)
	-- Create a Highlight instance
	if show then
		local highlight = Instance.new("Highlight")
		highlight.Adornee = enemy
		highlight.FillColor = Color3.new(1, 0, 0) -- Red color
		highlight.OutlineColor = Color3.new(1, 1, 0) -- Yellow outline
		highlight.Parent = enemy
	else
		-- Remove existing Highlight instance if any
		local existingHighlight = enemy:FindFirstChildOfClass("Highlight")
		if existingHighlight then
			existingHighlight:Destroy()
		end
	end
end
--- Called when the controller starts
function EffectsController.OnStart()
	-- Cache all enemies on the field
	allEnemies = workspace.Characters.Enemies:GetChildren()
	-- Create a selection mark for every enemy on the field
	-- for _, enemy in pairs(allEnemies) do
	-- 	local selectionMark = rep.Shared.Assets.UI.Combat.SelectionMark:Clone()
	-- 	selectionMark.Parent = enemy.HumanoidRootPart
	-- 	selectionMark.Enabled = false
	-- end
end

--- Handle effects on the selected enemy(s)
--- @param enemies { _TYPES.Character }
function EffectsController.HandleEnemySelectionMark(enemies: { _TYPES.Character }, primaryIndex: number?)
	-- Toggle selection mark for selected enemies
	for _, enemy in pairs(allEnemies) do
		-- If the enemy is in the selected enemies list, highlight
		if table.find(enemies, enemy) then
			applyHighlightEffectToEnemy(enemy, true)
		else
			applyHighlightEffectToEnemy(enemy, false)
		end
	end
end

return EffectsController
