local rep = game:GetService("ReplicatedStorage")
local SoundsData = require(game:GetService("ReplicatedStorage").Assets.Asphalt.Sounds)
-- Controllers
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
-- Packages
local Zap = require(StarterPlayerScripts.Client.zap)

local SoundController = {}
local sounds = {}

function SoundController.OnStart()
	Zap.RequestPlaySound.On(function(soundName)
		if not sounds[soundName] then
			warn("Sound not found: " .. soundName)
			return
		end

		sounds[soundName]:Play()
	end)
end

--- Create a new sound instance
--- @param soundName -- The name of the sound to create
function SoundController.Create(soundName: string, soundSource: string)
	local sound = Instance.new("Sound")
	sound.Name = soundName
	sound.SoundId = soundSource
	sound.Volume = 1
	sound.Parent = game.SoundService.Sounds

	sounds[soundName] = sound
	return sound
end

--- Plays a sound
--- @param soundName -- The name of the sound to play
function SoundController.Play(soundName: string)
	sounds[soundName]:Play()
end

function SoundController.Init()
	-- Load all sounds into the sounds table
	for _, soundType in pairs(SoundsData) do
		for soundName, soundId in pairs(soundType) do
			SoundController.Create(soundName, soundId)
		end
	end
end
return SoundController
