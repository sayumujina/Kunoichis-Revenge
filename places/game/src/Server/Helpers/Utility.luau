--- @class Utility
--- @server
--- @tag Helper
local Utility = {}

--- Performs a raycast 
--- @param position -- The starting position of the raycast
--- @param endVector -- The direction and distance of the raycast
--- @param VELOCITY_FACTOR -- Optional factor to adjust the raycast distance based on velocity
--- @return RaycastResult? -- The result of the raycast, or nil if nothing was hit
function Utility.Raycast(position: Vector3, endVector: Vector3, VELOCITY_FACTOR: number?): RaycastResult?
	local dir = endVector.Unit
	local velDistance = endVector.Magnitude / (VELOCITY_FACTOR or 1)

	-- Prepare the raycast to check for collisions
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances =
		{ workspace:WaitForChild("Map").Content, workspace:WaitForChild("Map").Decoration }
	raycastParams.IgnoreWater = true

	-- Raycast to check for obstructions
	local result = workspace:Raycast(position, dir * velDistance, raycastParams)
    return result
end

return Utility