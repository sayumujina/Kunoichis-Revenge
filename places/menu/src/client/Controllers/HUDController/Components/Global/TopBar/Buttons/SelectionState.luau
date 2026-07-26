local rep = game:GetService("ReplicatedStorage")
local TopBarIcons = require(rep.Packages.topbarplus)

local SelectionState = {}

type Icon = TopBarIcons.Icon

local registeredIcons: { Icon } = {}

function SelectionState.Register(icon: Icon)
	if table.find(registeredIcons, icon) then
		return
	end

	table.insert(registeredIcons, icon)
end

function SelectionState.LockAll()
	for _, icon in registeredIcons do
		icon:lock()
	end
end

--- Basically, we lock the icon that is selected, so that the user cannot deselect it and go back to the blank-ahh workspace that I have right now
function SelectionState.ApplySelectionLocks()
	local hasSelectedIcon = false

	for _, icon in registeredIcons do
		if icon.isSelected then
			hasSelectedIcon = true
			icon:lock()
		else
			icon:unlock()
		end
	end

	if hasSelectedIcon then
		return
	end

	for _, icon in registeredIcons do
		icon:unlock()
	end
end

return SelectionState
