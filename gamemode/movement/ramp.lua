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

function RampSlide.TraceHull(origin, traceEnd, ply)

	return util.TraceHull{
		start = origin,
		endpos = traceEnd,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
		mask = MASK_PLAYERSOLID_BRUSHONLY,
		filter = function(e1, e2)
			return not e1:IsPlayer()
		end
	}
end

function RampSlide.Trace(ply, vel, origin)
	local pred_vel = vel * FrameTime()
	local hover_height = distance
	local slide_trace
	
	if !ply:Sliding() and !ply:Surfing() then
		if 0 > vel.z  and not ply:OnGround() then
			slide_trace = RampSlide.TraceHull(origin, origin + Vector(0, 0, -hover_height + math.min(pred_vel.z, 0)), ply)
			
			if not slide_trace.HitWorld then
				slide_trace = RampSlide.TraceHull(origin, origin + Vector(pred_vel.x, pred_vel.y, -hover_height + math.min(pred_vel.z, 0)), ply)
			end
		else
			if ply:OnGround() then
				slide_trace = RampSlide.TraceHull(origin, origin + Vector(0, 0, -hover_height), ply)
			else
				slide_trace = RampSlide.TraceHull(origin, origin + Vector(pred_vel.x, pred_vel.y, -hover_height), ply)
			end
		end
	else
		slide_trace = RampSlide.TraceHull(origin, origin + Vector(0, 0, -hover_height + math.min(pred_vel.z, 0)), ply)
		
		if !slide_trace.HitWorld then
			slide_trace = RampSlide.TraceHull(origin, origin + Vector(pred_vel.x, pred_vel.y, -hover_height + math.min(pred_vel.z, 0) - 0.1), ply)
		end
	end
	
	if slide_trace.HitNormal == 0 or slide_trace.HitNormal == 1 then
		return false
	end
	return slide_trace
end

function RampSlide.canSlide(ply, normal, vel, z_slide_vel)
	local slideVelSqr = (30*30)  -- The speed required for sliding on ramps.
	local flSpeedSqr  = vel:Dot( vel )
	local minSlideVel = 150
	-- This checks which direction on the ramp the player is moving
	
	if
	(( 0 > Vector( normal.x, normal.y ):Dot( Vector( vel.x, vel.y ):GetNormalized() ) ) &&
	( 1 > normal.z ) &&
	( normal.z > ply:SlideNormal() ) &&
	( flSpeedSqr > slideVelSqr   ) &&
	((!ply:Sliding() and z_slide_vel > minSlideVel) or ply:Sliding())) ||
	(normal.z > 0.1 and normal.z <= ply:SlideNormal())
	then
		return true
	end
	return false
end

function RampSlide.SlideRideFix(mv, cmd, normal)
	local forward, right = mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right()
	local wish_vel, wish_speed, wish_dir
	local vel = mv:GetVelocity()
	
	forward.z, right.z = 0, 0
	forward:Normalize()
	right:Normalize()
	wish_vel = (forward * cmd:GetForwardMove()) + (right * cmd:GetSideMove())
	wish_vel.z = 0
	
	wish_speed = wish_vel
	wish_speed:Normalize()
	wish_speed = wish_speed:Length()
	wish_speed = wish_speed * mv:GetMaxSpeed()
	
	if wish_speed > mv:GetMaxSpeed() then
		wish_vel = wish_vel * (mv:GetMaxSpeed()/wish_speed)
	end
	
	wish_dir = wish_vel
	
	if normal:Dot(wish_dir) > 0 and vel:Dot(normal) > 0 then
		return true
	end
	return false
end

function Move:SlopeFix(trace, vecVelocity, ply)
	local origVel 			 = vecVelocity -- Original velocity.
	local origin				 = self:GetOrigin()
	local minSlideVel		 = 140
	
	
	if ( trace.HitNormal.z < 1 ) && (!self:KeyDown(IN_DUCK) or (vecVelocity.z >= -700 and self:KeyDown(IN_DUCK))) && ply:OnGround() && (ply:SlopeFix_InAir()) && vecVelocity.z <= 0  then
		local vLast = ply:last_vel()
		vLast.z = vLast.z - (GetConVar( "sv_gravity" ):GetFloat() * FrameTime() * 0.5)
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

function Move:SRSlideTest( trace, vecVelocity, ply )
	local origVel 			 = vecVelocity -- Original velocity.
	local origin				 = self:GetOrigin()
	local minSlideVel		 = 140
	local vecAbsVelocity = Vector()
	local change
	// A backoff of 1.0 is a slide.
	// Anything above 1 makes players bounce.
	local flBackOff = 1
	if trace.HitNormal.z <= ply:SlideNormal() // Dont apply the physics on surf ramps
	|| trace.HitNormal.z == 1	// Or when on flat ground
	|| !self:KeyDown(IN_DUCK) // Or when not holding duck
	|| Vector(trace.HitNormal.x, trace.HitNormal.y):Dot(Vector(vecVelocity.x, vecVelocity.y):GetNormalized()) < 0 then // Or when going up a slope
		ply.DoJump = false
		--print(ply.TestSlide)
		ply.TestSlide = false
		return
	end
	
	if !ply.TestSlide then
		ply.TestSlide = false
		
	else
		
	end
	
	//Gotta go down at 1000u/s to slide down them
	if (( trace.HitNormal.z < 1 ) and vecVelocity.z < -700) || ply.TestSlide 	 then
		RampSlide.PhysicsClipVelocity( vecVelocity, trace.HitNormal, vecAbsVelocity, flBackOff )
		if !ply.TestSlide then
			local moveDir = vecVelocity*Vector(1,1,0)
			moveDir = moveDir	:GetNormalized()
			// Changes from vertical to horizontal velocity
			local newVel = Vector((moveDir.x*vecVelocity:Length()), (moveDir.y*vecVelocity:Length()), 0)
			RampSlide.PhysicsClipVelocity( newVel, trace.HitNormal, vecAbsVelocity, flBackOff )
		end
		origin.z = trace.HitPos.z+distance
		ply:SetGroundEntity( NULL )
		
		vecVelocity    = vecAbsVelocity + ply:GetBaseVelocity()
		ply:Sliding(true)
		if vecVelocity.z*FrameTime()-origVel.z*FrameTime() < 0 then
			self:SetVelocity( origVel )
			self:SetOrigin(origin)
		else
			self:SetVelocity( vecVelocity )
			self:SetOrigin(origin)
		end
		ply.TestSlide = true
		ply.PredTest = CurTime()
	end
	if self:KeyPressed(IN_JUMP) or (ply.DoJump) then
		self:SetVelocity((self:GetVelocity()*Vector(1,1,0)) + Vector(0,0,ply:GetJumpPower()))
		ply.DoJump = true
	end
end

function Move:resolveFlyCollisionSlide( trace, slide_vel, ply )

	if (ply:Sliding() || ply:Surfing()) && 0 > (slide_vel.z - self:GetVelocity().z) then
		return
	end
	
	if RampSlide.canSlide(ply, trace.HitNormal, slide_vel, slide_vel.z) then
		
		if (trace.HitNormal.z > 0.1 and ply:SlideNormal() >= trace.HitNormal.z) then
			ply:Surfing(trace.HitPos)
			ply:Sliding(false)
		else
			ply:Sliding(trace.HitPos)
			ply:Surfing(false)
		end
		
		if slide_vel.z - self:GetVelocity().z > -100 then
			local origin = self:GetOrigin()
			
			slide_vel = slide_vel + ply:GetBaseVelocity()
			origin.z = trace.HitPos.z + distance
			ply:SetGroundEntity(NULL)
			self:SetVelocity(slide_vel)
			self:SetOrigin(origin)
		end
	end
end

function RampSlide.Slide(ply, mv, cmd)
	local vel = mv:GetVelocity()
	local origin = mv:GetOrigin()
	local slide_trace = RampSlide.Trace(ply, vel, origin)
	local fix
	local slide_vel = Vector(0, 0, 0)
	if !slide_trace then return end
	
	fix = RampSlide.SlideRideFix(mv, cmd, slide_trace.HitNormal)
	RampSlide.PhysicsClipVelocity( vel, slide_trace.HitNormal, slide_vel, 1 )
	if 
	(1 > slide_trace.HitNormal.z && !slide_trace.StartSolid) and
	RampSlide.canSlide(ply, slide_trace.HitNormal, vel, slide_vel.z)
	then
		mv:resolveFlyCollisionSlide(slide_trace, slide_vel, ply)
		
		if fix then
			mv:SetVelocity(vel)
			mv:SetOrigin(origin)
		end
		
	end
	if 1 > slide_trace.HitNormal.z && !slide_trace.StartSolid then
		--mv:SRSlideTest( slide_trace, vel, ply )
		mv:SlopeFix( slide_trace, vel, ply )
	end
	if not RampSlide.canSlide(ply, slide_trace.HitNormal, vel, slide_vel.z) then
		ply:Surfing(false)
		ply:Sliding(false)
	end
	
end
