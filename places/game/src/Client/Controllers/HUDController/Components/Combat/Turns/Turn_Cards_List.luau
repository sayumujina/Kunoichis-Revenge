local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Data.data_Types)
--
local createMainTurnCard = require(script.Parent.MainTurn_Card)
local createExtraActionCard = require(script.Parent.ExtraAction_Card)

return function(char: _TYPES.Character, turnId: number, order: number, side: _TYPES.Sides, actionValue: number)
	local turnCardsList = Instance.new("Frame")
	turnCardsList.Name = "Turn_Cards_List_" .. turnId
	turnCardsList.AnchorPoint = Vector2.new(1, 0)
	turnCardsList.BackgroundTransparency = 1
	turnCardsList.Position = UDim2.fromScale(1, 0)
	turnCardsList.Size = UDim2.fromScale(1, 0.08)
	turnCardsList.LayoutOrder = order

	local turnCardListLayout = Instance.new("UIListLayout")
	turnCardListLayout.Name = "UIListLayout"
	turnCardListLayout.FillDirection = Enum.FillDirection.Horizontal
	turnCardListLayout.Padding = UDim.new(0.02, 0)
	turnCardListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	--
	turnCardListLayout.Parent = turnCardsList

	local idValue = Instance.new("NumberValue")
	idValue.Name = "TurnIdValue"
	idValue.Value = turnId
	--
	idValue.Parent = turnCardsList

	local orderValue = Instance.new("NumberValue")
	orderValue.Name = "OrderValue"
	orderValue.Value = order
	--
	orderValue.Parent = turnCardsList

	-- Update the turn card's layout order whenever the order changes
	orderValue.Changed:Connect(function()
		turnCardsList.LayoutOrder = orderValue.Value
	end)

	-- Add a turn frame
	createMainTurnCard(char, turnId, order, side, actionValue).Parent = turnCardsList

	return turnCardsList
end
