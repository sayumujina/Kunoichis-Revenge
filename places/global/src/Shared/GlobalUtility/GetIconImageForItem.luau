local icons = require(game.ReplicatedStorage.Assets.Asphalt.Icons)

--- Gets the icon image for a given item name.
--- @param itemName -- The name of the item.
return function(itemName: string): string
	local folder = icons.items

	local itemIconPath = folder["UI_Icons_" .. itemName]
	if itemIconPath then
		return itemIconPath
	else
		warn("No icon found for item: " .. itemName)
		return "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end
end
