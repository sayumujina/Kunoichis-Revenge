--- @within data_TYPES
--- @type StatusTypes = "Collapsed"
export type StatusTypes = "Collapsed"

--- @within data_TYPES
--- @type StatChangeTypes = {statChangeType: "Flat" | "Mult" | "Set", statToChange: string, value: number}
export type StatChangeTypes = {
	-- Stat change type
	statChangeType: "Flat" | "Mult" | "Override",
	-- Stat to change
	statName: string,
	-- Value of the stat change. Interpretation depends on the statChangeType
	value: number,
}

--- @within data_TYPES
--- @type Status = { name: string, duration: number?, expellable: boolean?, data: any? }
export type Status = {
	-- Status type (e.g., "Collapsed")
	statusType: { StatusTypes }?,
	-- Info
	info: {
		-- Status name
		name: string,
		-- Status description
		description: string,
	},
	-- Data
	data: {
		-- The duration of the status in turns
		-- If nil, the status is considered permanent
		duration: number?,
		-- Whether the status is expellable or not
		expellable: boolean?,
	},
	-- Stats changes
	statChanges: { StatChangeTypes }?,
}

return nil
