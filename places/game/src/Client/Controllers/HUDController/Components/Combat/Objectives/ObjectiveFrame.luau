local ObjectiveCard = require(script.Parent.ObjectiveCard)

local HIDDEN_POSITION = UDim2.fromScale(1, 0.25)
local SHOWN_POSITION = UDim2.fromScale(0.75, 0.25)

local pendingTween: Tween | nil = nil
local Tween = game:GetService("TweenService")

--- Creates a frame that contains all the objective cards
--- @param objectives -- A table of objectives, each containing a name, description, and passed state
local function createObjectiveFrame(
	size: UDim2,
	position: UDim2,
	transparency: number,
	objectives: {
		{
			id: string,
			description: string,
			passed: boolean,
		}
	}
)
	local objectivesFrame = Instance.new("Frame")
	objectivesFrame.Name = "UI_ObjectivesFrame"
	objectivesFrame.BackgroundColor3 = Color3.new()
	objectivesFrame.BackgroundTransparency = transparency
	objectivesFrame.Position = position
	objectivesFrame.Size = size
	objectivesFrame.Position = HIDDEN_POSITION

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.Padding = UDim.new(0.03, 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = objectivesFrame

	for _, objective in pairs(objectives) do
		local objectiveCard = ObjectiveCard.CreateObjectiveCard(objective.id, objective.description, objective.passed)
		objectiveCard.Parent = objectivesFrame
	end

	return objectivesFrame
end

--- Toggles the visibility of the objective frame
--- @param objectivesFrame -- The objective frame to toggle the visibility of
local function toggleObjectiveFrame(show: boolean)
	local playerGui = game.Players.LocalPlayer.PlayerGui
	local objectivesFrame = playerGui:FindFirstChild("Combat_ScreenGui"):FindFirstChild("UI_ObjectivesFrame") :: Frame
	if not objectivesFrame then
		return
	end

	local function tweenFrame()
		local newPos = if show then SHOWN_POSITION else HIDDEN_POSITION
		pendingTween = Tween:Create(
			objectivesFrame,
			TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{ Position = newPos }
		)
		pendingTween.Completed:Once(function()
			pendingTween = nil
		end)
		pendingTween:Play()
	end

	-- Wait for any pending tweens to finish before starting a new one
	if pendingTween then
		pendingTween.Completed:Once(function()
			pendingTween = nil
			tweenFrame()
		end)
	else
		tweenFrame()
	end
end

return {
	CreateObjectiveFrame = createObjectiveFrame,
	ToggleObjectiveFrame = toggleObjectiveFrame,
}
