local Pole = {}

function PoleMoveAngle(ply, pole_dir, angle)

end

function PoleMove(ply, mv, cmd)
	local eye_pos = ply:EyePos()
	local aim_vec = ply:GetAimVector()
	local origin = mv:GetOrigin()
	local vel = mv:GetVelocity()
	local old_vel = ply:last_vel()
	local dist = 100
	local max_dist = 300
	if mv:KeyDown(IN_ATTACK2) then
		local trace_data = {}
		trace_data.start = eye_pos
		trace_data.endpos = eye_pos+(aim_vec*dist)
		trace_data.filter = ply
		local trace = util.TraceLine(trace_data)

		if not ply.is_grabbing then
			if trace.HitWorld then
				ply.is_grabbing = trace
			end
		else
			if ply.is_grabbing.HitPos:Distance( eye_pos ) <= max_dist then
				ply:SetGroundEntity(NULL)
				print(vel)
				mv:SetVelocity(vel + (((ply.last_aimvec - aim_vec) * 250)*Vector(math.abs(ply.is_grabbing.HitNormal.y), math.abs(ply.is_grabbing.HitNormal.x), 1)))
			end
		end
	else
		ply.is_grabbing = false
	end

	ply.last_aimvec = aim_vec
end

function ButtSlideMove(ply, mv, cmd)
	if ply:OnGround() and mv:KeyDown(IN_DUCK) then
		ply:friction(0.25)
		ply:accel(20)
		ply:SetMaxSpeed(100)
	else
		ply:friction(ply.default.friction)
		ply:accel(ply.default.accel)
	end
	--
end

/*
function HopMove(ply, mv, cmd)
	local eye_pos = ply:EyePos()
	local aim_vec = ply:GetAimVector()
	local vel = mv:GetVelocity()
	local old_vel = ply:last_vel()
	local LateralStoppingAmount = vel:Length2D() - old_vel:Length2D()
	local VerticalStoppingAmount = vel.z - old_vel.z
	local new_vel = vel
end
*/