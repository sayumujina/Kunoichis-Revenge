local CreateReturnToMenuButton = require(script.Buttons.ReturnToMenuButton)

local created = false
return function()
	if created then
		return
	end
	created = true
	CreateReturnToMenuButton()
end
