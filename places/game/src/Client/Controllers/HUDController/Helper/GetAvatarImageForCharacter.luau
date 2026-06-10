local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)

return function(charName: string): string
	local characterAvatarPath = ui.avatar["UI_Avatar_" .. charName]
	if characterAvatarPath then
		return characterAvatarPath
	else
		warn("No avatar found for character: " .. charName)
		return "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end
end
