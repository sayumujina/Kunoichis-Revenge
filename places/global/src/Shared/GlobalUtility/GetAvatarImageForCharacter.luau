local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)

--- Gets the avatar image for a given character name.
--- @param charName -- The name of the character.	
--- @param getSilhouette -- Whether to get the silhouette version of the avatar. Defaults to false.
return function(charName: string, getSilhouette: boolean?): string
	local folder = if getSilhouette then
		ui.avatarSilhouettes
	else
		ui.avatar

	local characterAvatarPath = folder["UI_Avatar_" .. charName .. (if getSilhouette then "_Silhouette" else "")]
	if characterAvatarPath then
		return characterAvatarPath
	else
		warn("No avatar found for character: " .. charName)
		return "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end
end
