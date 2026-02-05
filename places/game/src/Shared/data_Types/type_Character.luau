--- @within data_TYPES
--- @type R6CharacterChildren { Humanoid: Humanoid & { Animator: Animator, HumanoidDescription: HumanoidDescription }, HumanoidRootPart: Part & any, Torso: Part & any, ["Left Arm"]: Part & any, ["Right Arm"]: Part & any, ["Left Leg"]: Part & any, ["Right Leg"]: Part & any, Head: Part }
export type R6CharacterChildren = {
	Humanoid: Humanoid & {
		Animator: Animator,
		HumanoidDescription: HumanoidDescription,
	},
	HumanoidRootPart: Part & any,
	Torso: Part & any,
	["Left Arm"]: Part & any,
	["Right Arm"]: Part & any,
	["Left Leg"]: Part & any,
	["Right Leg"]: Part & any,
	Head: Part,
}

--- @within data_TYPES
--- @type RobloxPlayerType Player & { PlayerGui: PlayerGui & { BubbleChat: ScreenGui, Chat: ScreenGui, Freecam: ScreenGui, }, PlayerScripts: PlayerScripts & { BubbleChat: LocalScript, ChatScript: LocalScript, PlayerScriptsLoader: LocalScript, RbxCharacterSounds: LocalScript, PlayerModule: ModuleScript, }, ActiveCharacter: ObjectValue & { Value: Character? } }
export type RobloxPlayerType = Player & {
	PlayerGui: PlayerGui & {
		BubbleChat: ScreenGui,
		Chat: ScreenGui,
		Freecam: ScreenGui,
	},
	PlayerScripts: PlayerScripts & {
		BubbleChat: LocalScript,
		ChatScript: LocalScript,
		PlayerScriptsLoader: LocalScript,
		RbxCharacterSounds: LocalScript,
		PlayerModule: ModuleScript,
	},
	ActiveCharacter: ObjectValue & {
		Value: Character?,
	},
}

--- @within data_TYPES
--- @type Character Model & CharacterChildren
export type Character = Model & R6CharacterChildren

return nil