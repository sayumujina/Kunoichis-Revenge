local function toggleShopScreenGui(show: boolean)
	local shopScreenGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Shop_ScreenGui", true)
	if shopScreenGui then
		shopScreenGui.Enabled = show
	end
end

return {
	ToggleShopScreenGui = toggleShopScreenGui,
}
