local ui = require(game.ReplicatedStorage.Assets.Asphalt.UI)

--- Gets the avatar image for a given character name.
--- @param charId -- The ID of the character.
--- @param getSilhouette -- Whether to get the silhouette version of the avatar. Defaults to false.
return function(charId: string, getSilhouette: boolean?): string
	local folder = if getSilhouette then ui.avatarSilhouettes else ui.avatar

	local characterAvatarPath = folder["UI_Avatar_" .. charId .. (if getSilhouette then "_Silhouette" else "")]
	if characterAvatarPath then
		return characterAvatarPath
	else
		warn("No avatar found for character: " .. charId)
		return "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end
end
