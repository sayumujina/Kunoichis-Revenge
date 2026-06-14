local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _TYPES = require(ReplicatedStorage.Shared.data_Types)
-- Services
local Services = game:GetService("ServerScriptService").Server.Services
local EventService = require(Services.EventService)

local AnimationService = {}

local Chars: {
	[_TYPES.Character]: {
		tracks: { [string]: AnimationTrack },
	},
} = {}

--- Initializes the AnimationService by setting up event listeners.
--- @within AnimationService
function AnimationService.OnStart()
	-- Listen to spawn successful event per character to initialize animations
	EventService.Events.SpawnSuccessfulForChar:Connect(function(event)
		AnimationService.Init(event.data.char)
	end)
end
--- Initialize the animations
--- @within AnimationService
--- @param char -- The character to initialize animations for
function AnimationService.Init(char: _TYPES.Character)
	-- Initialize the data for teh character if it doesn't exist already
	if not Chars[char] then
		Chars[char] = {
			tracks = {},
		}
	end

	local chardata = Chars[char]
	local tracks = chardata.tracks
	local animator = char.Humanoid.Animator

	-- Initializing the character's animations
	local charAnims = game.ReplicatedStorage.Assets.Animations.Characters[char.Name]
	local globalAnims = game.ReplicatedStorage.Assets.Animations.Global

	-- Categories of animations to load
	local animsCategories = {
		"Attacks",
		"Hurt",
	}

	-- Load custom animations
	for __, category in animsCategories do
		-- Check if the character has custom animations for the category
		if charAnims:FindFirstChild(category) then
			for __, anim in charAnims[category]:GetChildren() do
				warn("Loading custom animation for " .. char.Name .. ": " .. anim.Name .. "id: " .. anim.AnimationId)
				tracks[anim.Name] = animator:LoadAnimation(anim)

				-- If the category is Attacks, set the priority to Action4
				if category == "Attacks" then
					tracks[anim.Name].Priority = Enum.AnimationPriority.Action4
				end
			end
			-- Load global animations if the character doesn't have custom ones for the category
		else
			for __, anim in globalAnims[category]:GetChildren() do
				tracks[anim.Name] = animator:LoadAnimation(anim)

				-- If the category is Attacks, set the priority to Action4
				if category == "Attacks" then
					tracks[anim.Name].Priority = Enum.AnimationPriority.Action4
				end
			end
		end
	end
end

--- Stops an animation on a character
--- @within AnimationService
--- @param char -- The character to stop the animation on
function AnimationService.Stop(char: _TYPES.Character, animName: string)
	local charData = Chars[char]
	if charData and charData.tracks[animName] then
		charData.tracks[animName]:Stop()
	else
		warn("Animation " .. animName .. " not found for character " .. char.Name)
	end
end

--- Plays an animation on a character
--- @within AnimationService
--- @param char -- The character to play the animation on
--- @param animName -- The name of the animation to play
function AnimationService.Play(char: _TYPES.Character, animName: string): AnimationTrack?
	local charData = Chars[char]
	if charData and charData.tracks[animName] then
		-- Cancel the current animation
		AnimationService.Stop(char, animName)
		-- Play the new animation
		warn("Playing animation for " .. char.Name .. ": " .. animName)
		charData.tracks[animName]:Play()
	else
		warn("Animation " .. animName .. " not found for character " .. char.Name)
		return nil
	end

	return charData.tracks[animName]
end

return AnimationService
