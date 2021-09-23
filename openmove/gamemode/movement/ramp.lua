RampSlide = {}
local Move = FindMetaTable( "CMoveData" )
local distance = 2

hookAdd("Init_Player_Vars", "Init_rampslide", function(ply)
  ply:AddSettings("Sliding", false)
  ply:AddSettings("SlideNormal", 0.75)
  ply:AddSettings("SlopeFix_InAir", false)

  ply:AddSettings("Surfing", false)
end)

function RampSlide.PhysicsClipVelocity( inv, normal, out, overbounce )
	local	backoff
	local	change = 0
	local	angle
	local	i

	local STOP_EPSILON = 0.1

	angle = normal.z

	backoff = inv:Dot( normal ) * overbounce
	for i = 1 , 3 do
		change = normal[i] * backoff
    out[i] =inv[i] -change
		if out[i] > -STOP_EPSILON && out[i] < STOP_EPSILON then
			out[i] = 0
		end
	end
end

function RampSlide.TraceHull(origin, traceEnd, Mins, Maxs)

	return util.TraceHull{
    start = origin,
		endpos = traceEnd,
    mins = Mins,
    maxs = Maxs,
    mask = MASK_PLAYERSOLID_BRUSHONLY,
    filter = function(e1, e2)
      return not e1:IsPlayer()
    end
  }
end

function RampSlide.canSlide(ply, normal, vel, z_slide_vel)
	local slideVelSqr = (30*30)  -- The speed required for sliding on ramps.
	local flSpeedSqr  = vel:Dot( vel )
	local minSlideVel = 150
	-- This checks which direction on the ramp the player is moving

	if
		( 0 > Vector( normal.x, normal.y ):Dot( Vector( vel.x, vel.y ):GetNormalized() ) ) &&
		( 1 > normal.z ) &&
		( normal.z > ply:SlideNormal() ) &&
		( flSpeedSqr > slideVelSqr   ) &&
		( z_slide_vel > minSlideVel )
	then

		return true
	end
	if ( flSpeedSqr > slideVelSqr ) and ply:Sliding() &&
	( 0 > Vector( normal.x, normal.y ):Dot( Vector( vel.x, vel.y ):GetNormalized() ) ) &&
		( 1 > normal.z ) &&
		( normal.z > ply:SlideNormal() )
		then
		return true
	end
	return false
end

function RampSlide.canSurf(ply, normal)

	-- This checks which direction on the ramp the player is moving'

	if ( normal.z > 0.1 ) && ( normal.z <= ply:SlideNormal() ) then


		return true
	end
	return false
end

// Stops you from riding the ramps when trying to strafe out.
function RampSlide.SlideRideFix(mv, cmd, normal)
	local fmove, smove = cmd:GetForwardMove(), cmd:GetSideMove()
	local forward, right = mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right()
	local wishvel, wishspeed, wishdir

  forward.z, right.z = 0
  forward:Normalize()
  right:Normalize()
  wishvel = (forward*fmove) + (right*smove)
	wishvel.z = 0

  wishspeed=wishvel
	wishspeed:Normalize()
  wishspeed = wishspeed:Length()
	wishspeed = wishspeed*mv:GetMaxSpeed()

  if (wishspeed > mv:GetMaxSpeed()) then
		wishvel = wishvel * (mv:GetMaxSpeed()/wishspeed)
  end
  wishdir=wishvel
	local vl = mv:GetVelocity()

	if normal:Dot(wishdir) > 0 && (vl:Dot(normal) > 0) then
		return true
	end
	return false
end

// You actually gain speed when you land on a ramp, instead of rng.
function Move:SlopeFix(trace, vecVelocity, ply)
  local origVel 			 = vecVelocity -- Original velocity.
	local origin				 = self:GetOrigin()
	local minSlideVel		 = 140


	if ( trace.HitNormal.z < 1 )  && ply:OnGround() && (ply:SlopeFix_InAir()) && vecVelocity.z <= 0  then
		local vLast = ply:last_vel()
		vLast.z = vLast.z - (ply:gravity() * FrameTime() * 0.5)
		local BackOff = vLast:Dot(trace.HitNormal)
		local change
		change = trace.HitNormal * BackOff
		vecVelocity = vLast - change
		local Adjust = vecVelocity:Dot(trace.HitNormal)
		if Adjust < 0 then
			vecVelocity = vecVelocity - (trace.HitNormal * Adjust)
		end
		vecVelocity.z = 0
		vLast.z = 0
		if vecVelocity:LengthSqr() > vLast:LengthSqr() then
			self:SetVelocity(vecVelocity)
		end

		ply:SlopeFix_InAir(false)

	end
end

function Move:resolveFlyCollisionSlide( trace, slide_vel, ply )
	local origin		= self:GetOrigin()
	local minSlideVel = 120
  // A backoff of 1.0 is a slide.
  // Anything above 1 makes players bounce.
  local flBackOff = 1
	// Changes the velocity "direction"

	// Slide up ramps that you can walk on when going minSlideVel
	if RampSlide.canSurf(ply, trace.HitNormal) then
		ply:SetGroundEntity( NULL )
		slide_vel = slide_vel + ply:GetBaseVelocity()

		ply:Sliding(false)
		ply:Surfing(true)

		--origin.x = trace.HitPos.x - (distance * (trace.HitNormal.x*trace.HitNormal.x))
		--origin.y = trace.HitPos.y - (distance * (trace.HitNormal.y*trace.HitNormal.y))
		origin.z = trace.HitPos.z + distance

		self:SetVelocity( slide_vel )
		self:SetOrigin( origin )
		return
	elseif RampSlide.canSlide(ply, trace.HitNormal, slide_vel, slide_vel.z)  then
		ply:SetGroundEntity( NULL )
		ply:Surfing(false)
		ply:Sliding(true)
		slide_vel = slide_vel + ply:GetBaseVelocity()

		origin.z = trace.HitPos.z + distance
		self:SetVelocity( slide_vel )
		self:SetOrigin( origin )

	end

end

function RampSlide.RampSlide_DamageFix(ply)
	local vel = ply:GetVelocity()
	local pos = ply:GetPos()
	local slide_vel = Vector()
	local slide_trace
			slide_trace = RampSlide.TraceHull( pos, pos + Vector(
				vel.x * FrameTime(),
				vel.y * FrameTime(),
				(-distance) + (math.min(vel.z * FrameTime(), 0))
			), ply:OBBMins(), ply:OBBMaxs() )

	RampSlide.PhysicsClipVelocity( vel, slide_trace.HitNormal, slide_vel, 1 )

	if RampSlide.canSurf(ply, slide_trace.HitNormal, vel) or RampSlide.canSlide(ply, slide_trace.HitNormal, vel, slide_vel.z) then

		ply:SetGroundEntity( NULL )

	end
end
hook.Add("OnPlayerHitGround", "RampSlide.RampSlide_DamageFix", RampSlide.RampSlide_DamageFix)


function RampSlide.Slide(ply, mv, cmd)

	local vel = mv:GetVelocity()
	local pred_vel = vel * FrameTime()
	local origin = mv:GetOrigin()
	local slide_vel = Vector()
	local trace_predicted = false
	local mins, maxs = ply:OBBMins(), ply:OBBMaxs()
	local slide_trace
	local pred_trace

	 if !ply.rs_sync then
    ply.rs_sync = load.Module( "modules/sync.lua" )
    ply.rs_sync.Insert(false, CurTime())
  end
	if !ply:Sliding() && !ply:Surfing() then

		if vel.z < 0 and !ply:OnGround() then

			trace_predicted = true
			slide_trace = RampSlide.TraceHull( origin, origin + Vector(
				0,
				0,
				(-distance) + (math.min(pred_vel.z, 0))
			), mins, maxs )
			if !slide_trace.HitWorld then
				pred_trace = RampSlide.TraceHull( origin, origin + Vector(
					pred_vel.x,
					pred_vel.y,
					(-distance) + (math.min(pred_vel.z, 0))
				), mins, maxs )
				if pred_trace.HitWorld then
					slide_trace = pred_trace
				end
			end


		else
			if ply:OnGround() then
				slide_trace = RampSlide.TraceHull( origin, origin + Vector(
				0,
				0,
				-distance
				), mins, maxs )
			else
				slide_trace = RampSlide.TraceHull( origin, origin + Vector(
				pred_vel.x,
				pred_vel.y,
				-distance
				), mins, maxs )
			end
		end
	else

		slide_trace = RampSlide.TraceHull(origin, origin + Vector(
			0,
			0,
			(-distance) + (math.min(pred_vel.z, 0))
		), mins, maxs )

		if !slide_trace.HitWorld then
			pred_trace = RampSlide.TraceHull( origin, origin + Vector(
				pred_vel.x,
				pred_vel.y,
				(-distance) + (math.min(pred_vel.z, 0)) - 0.1
			), mins, maxs )
			if pred_trace.HitWorld then
				slide_trace = pred_trace
			end
		end


	end


	local fix = RampSlide.SlideRideFix(mv, cmd, slide_trace.HitNormal)
	RampSlide.PhysicsClipVelocity( vel, slide_trace.HitNormal, slide_vel, 1 )

	if slide_trace.HitNormal.z < 1 && !(slide_trace.StartSolid) then

		if
			RampSlide.canSlide(ply, slide_trace.HitNormal, vel, slide_vel.z) ||
			RampSlide.canSurf(ply, slide_trace.HitNormal, vel)
		then


			mv:resolveFlyCollisionSlide( slide_trace, slide_vel, ply )

			if fix then
				mv:SetVelocity(vel)
				mv:SetOrigin(origin)
			end
		end


		mv:SlopeFix( slide_trace, vel, ply )
	elseif slide_trace.StartSolid then
		--mv:SetOrigin(origin-Vector(0,0,-distance))
	end

	if !RampSlide.canSlide(ply, slide_trace.HitNormal, vel, slide_vel.z) then

		ply:Sliding(false)
	end
	if !RampSlide.canSurf(ply, slide_trace.HitNormal, vel) then
		ply:Surfing(false)
	end

	ply.rs_sync.Insert(ply:Sliding(), engine.TickCount())

end



/*
function rampSlide(ply, mv)
	local frame_time = FrameTime()
	local origin = mv:GetOrigin()
  local Mins = ply:OBBMins()
  local Maxs = ply:OBBMaxs()
  local traceEnd = origin * 1
  local primal_velocity = mv:GetVelocity()
	local frame_velocity = primal_velocity * frame_time
	// Predicted next frame movement if going quickly downwards
	traceEnd.z = ( traceEnd.z - distance ) + math.min( frame_velocity.z, 0 )  // trace a bit further than feet
	local tL = traceHull(origin, traceEnd, Mins, Maxs)
		traceEnd.x = (traceEnd.x) + frame_velocity.x
		traceEnd.y = (traceEnd.y) + frame_velocity.y
	local tLBkup = traceHull(origin, traceEnd, Mins, Maxs)

		if (tL.HitWorld and tL.HitNormal.z < 1 and tL.HitNormal.z > 0) then

			mv:resolveFlyCollisionSlide( tL, primal_velocity, ply )
			mv:SRSlideTest( tL, primal_velocity, ply )
			ply:GroundSlanted(true)
			traceEnd = mv:GetOrigin() * 1
			traceEnd.z = ( (traceEnd.z - distance) + math.min( mv:GetVelocity().z*frame_time, 0 ))
			traceEnd.x = (traceEnd.x) + mv:GetVelocity().x*frame_time
			traceEnd.y = (traceEnd.y) + mv:GetVelocity().y*frame_time
			local tlGrav = traceHull(origin, traceEnd, Mins, Maxs)
			if (tlGrav.HitWorld and tlGrav.HitNormal.z < 1 and tlGrav.HitNormal.z > 0) then
				mv:resolveFlyCollisionSlide( tlGrav, mv:GetVelocity(), ply )
			end
		elseif (tLBkup.HitWorld and tLBkup.HitNormal.z < 1 and tLBkup.HitNormal.z > 0) then
			mv:resolveFlyCollisionSlide( tLBkup, primal_velocity, ply )
			mv:SRSlideTest( tLBkup, primal_velocity, ply )
			ply:GroundSlanted(true)
		else
			ply.TestSlide = false
			ply:Sliding(false)
			ply:GroundSlanted(false)

		end

end*/
