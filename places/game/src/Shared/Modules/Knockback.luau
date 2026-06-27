local rep = game:GetService("ReplicatedStorage")
local _TYPES = require(rep.Shared.data_Types)
-- Services
local RunService = game:GetService("RunService")
-- Utility
local Utility = require(rep.Shared.Modules.Utility)

local Knockback = {}

--- @function force
--- @within Knockback
--- Applies a knockback force to a specified part.
--- @param part -- The part to apply the force to (expects RootAttachment).
--- @param velocity -- The velocity of the force; ignored if nil/zero.
--- @param options -- Optional origin/direction/decay configuration.
function Knockback.force(
	part: BasePart & { RootAttachment: Attachment },
	velocity: Vector3?,
	options: _TYPES.KnockbackOptions?
)
	-- Check if vel is zero or nil
	if not velocity or velocity == Vector3.zero then
		return
	end

	-- Function to calculate direction (used for initial calculation and aimable recalculation)
	local function calculateDirection(currentPart: BasePart): Vector3
		if velocity == Vector3.zero then
			return Vector3.zero
		end

		-- Use current part position for relative direction
		return ((currentPart.CFrame * CFrame.new(velocity)).Position - currentPart.Position).Unit
	end

	local dir: Vector3 = calculateDirection(part)

	-- Create a BodyVelocity instance to apply the force
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Velocity = velocity.Magnitude * dir
	warn(bv.Velocity)

	-- If applying -Y knockback, lessen its effect the closer the part is to the ground
	if bv.Velocity.Y < 0 and not (options and options.downward) then
		-- Raycast downward check for obstructions
		local result = Utility.Raycast(part.Position, part.CFrame.UpVector * bv.Velocity.Y)

		if result then
			local distance = result.Distance

			-- At 0 distance, the Y knockback should be 0
			if distance <= 3.05 then
				bv.Velocity = Vector3.new(bv.Velocity.X, 0, bv.Velocity.Z)
			else
				bv.Velocity = Vector3.new(bv.Velocity.X, bv.Velocity.Y * (1 - distance / bv.Velocity.Y), bv.Velocity.Z)
			end
		end
	end

	-- Tween for velocity decay/increase
	local tween: Tween

	-- Duration and current velocity tracking
	local dur = options and options.dur or 0.2
	local currentVelocity = bv.Velocity

	-- Apply velocity decay if needed
	if options and options.decay then
		-- Create a tween to apply the decay effect
		tween = game:GetService("TweenService"):Create(
			bv,
			TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{ Velocity = Vector3.zero }
		)
		tween.Completed:Once(function()
			tween:Destroy()
			tween = nil :: any -- Ensure tween is nil after completion
		end)
	elseif options and options.decay == false then
		bv.Velocity = Vector3.zero

		-- Create a tween to apply velocity increase
		tween = game:GetService("TweenService"):Create(
			bv,
			TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{ Velocity = currentVelocity }
		)
		tween.Completed:Once(function()
			tween:Destroy()
			tween = nil :: any -- Ensure tween is nil after completion
		end)
	end

	-- decayRate functionality separate from tween decay
	local decayConnection: RBXScriptConnection?
	if options and options.decayRate then
		local originalVelocity = bv.Velocity
		local startTime = tick()
		local targetMultiplier = options.decayRate -- e.g., 0.5 means decay to 50% over duration

		decayConnection = RunService.RenderStepped:Connect(function()
			warn(
				"Knockback RenderStepped: Velocity:",
				bv.Velocity,
				"Original:",
				originalVelocity,
				"Target Multiplier:",
				targetMultiplier
			)
			if not bv.Parent or not part.Parent then
				if decayConnection then
					decayConnection:Disconnect()
					decayConnection = nil
				end
				return
			end

			local elapsedTime = tick() - startTime
			local progress = math.min(elapsedTime / dur, 1) -- 0 to 1 over duration

			-- Calculate decay multiplier: starts at 1, ends at targetMultiplier
			local currentMultiplier = 1 - (1 - targetMultiplier) * progress

			-- Apply decay to original velocity, preserving direction changes from aimable
			local currentDirection = bv.Velocity.Magnitude > 0 and bv.Velocity.Unit or originalVelocity.Unit
			bv.Velocity = currentDirection * (originalVelocity.Magnitude * currentMultiplier)
		end)
	end

	-- Start the tween
	if tween then
		tween:Play()
	end

	bv.Parent = part

	-- Clean up the knockback when the knockback duration has ended
	task.delay(dur, function()
		warn("Knockback ended for part:", part:GetFullName())
		bv:Destroy()

		if tween then
			tween:Destroy()
		end

		if decayConnection then
			decayConnection:Disconnect()
			decayConnection = nil
		end
	end)
end

return Knockback
