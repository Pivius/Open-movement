function AirAccelerate( ply, mv, cmd, accel, gain )

	if !ply:Alive() or ply:OnGround() then return end

	local addSpeed, accelSpeed, wishDir, wishVel, wishSpd, wishSpeed
	local curSpeed = mv:GetVelocity()
	local fmove, smove = mv:GetForwardSpeed(), mv:GetSideSpeed()
	local forward, right = mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right()
	forward.z, right.z = 0, 0
	forward:Normalize()
	right:Normalize()
	wishVel = (forward*fmove) + (right*smove)
	wishVel.z = 0
	wishSpeed = wishVel:Length()

	if (wishSpeed > (gain*10)) then
	wishVel = wishVel * ((gain*10)/wishSpeed)
		wishSpeed = (gain*10)
	end
	wishSpd = wishSpeed
	wishVel:Normalize()
	if (wishSpd > gain) then
		wishSpd = gain
	end

	wishDir = wishVel
	// Determine veer amount
	curSpeed = (mv:GetVelocity()):Dot(wishDir)

	// See how much to add
	addSpeed = wishSpd-curSpeed

	// If not adding any, done.

	if (addSpeed <= 0) then
		return
	end
	local surfaceFriction = 1
	--// Determine acceleration speed after acceleration
	accelSpeed = accel * wishSpeed * FrameTime() * surfaceFriction
	// Cap it
	if (accelSpeed > addSpeed) then
		accelSpeed = addSpeed
	end
	if curSpeed then
	hookCall("AirStrafe", ply, curSpeed, wishSpd, accelSpeed)
	end
	mv:SetVelocity(mv:GetVelocity() + (accelSpeed * wishDir))
end

function ThreeDAirAccelerate( ply, mv, cmd, accel, gain )

	if !ply:Alive() or ply:OnGround() then return end

	local addSpeed, accelSpeed, wishDir, wishVel, wishSpd, wishSpeed
	local curSpeed = mv:GetVelocity()
	local fmove, smove = mv:GetForwardSpeed(), mv:GetSideSpeed()
	local forward, right = mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right()

	right.z = 0
	forward:Normalize()
	right:Normalize()
	wishVel = (forward*fmove) + (right*smove) + Vector(0, 0, math.max(forward.z, 0)*math.abs(smove)) + Vector(0, 0, math.max(forward.z, 0)*math.abs(fmove))
	wishSpeed = wishVel:Length()

	if (wishSpeed > (gain*10)) then
	wishVel = wishVel * ((gain*10)/wishSpeed)
		wishSpeed = (gain*10)
	end
	wishSpd = wishSpeed
	wishVel:Normalize()
	if (wishSpd > gain) then
		wishSpd = gain
	end

	wishDir = wishVel
	// Determine veer amount
	curSpeed = (mv:GetVelocity()):Dot(wishDir)

	// See how much to add
	addSpeed = wishSpd-curSpeed

	// If not adding any, done.

	if (addSpeed <= 0) then
		return
	end
	local surfaceFriction = 1
	--// Determine acceleration speed after acceleration
	accelSpeed = accel * wishSpeed * FrameTime() * surfaceFriction
	// Cap it
	if (accelSpeed > addSpeed) then
		accelSpeed = addSpeed
	end
	if curSpeed then
	hookCall("AirStrafe", ply, curSpeed, wishSpd, accelSpeed)
	end
	mv:SetVelocity(mv:GetVelocity() + (accelSpeed * wishDir))
end


// VQ3 / CPM Port
hookAdd("Init_Player_Vars", "Init_VQMovement", function(ply)
	ply:AddSettings("movement_dir", 0)

end)
/*
	NAME			- PM_SetMovementDir
	FUNCTION	- Sets the player move direction based on key inputs
	ARGS 			-
	ply	 - Player
		cmd	 - CUserCmd
*/
function PM_SetMovementDir( ply, cmd )
	local fmove = cmd:GetForwardMove()
	local smove = cmd:GetSideMove()
	if ( fmove || smove ) then
		if ( smove == 0 && fmove > 0 ) then
			ply:movement_dir(0)
		elseif ( smove < 0 && fmove > 0 ) then
			ply:movement_dir(1)
		elseif ( smove < 0 && fmove == 0 ) then
			ply:movement_dir(2)
		elseif ( smove < 0 && fmove < 0 ) then
			ply:movement_dir(3)
		elseif ( smove == 0 && fmove < 0 ) then
			ply:movement_dir(4)
		elseif ( smove > 0 && fmove < 0 ) then
			ply:movement_dir(5)
		elseif ( smove > 0 && fmove == 0 ) then
			ply:movement_dir(6)
		elseif ( smove > 0 && fmove > 0 ) then
			ply:movement_dir(7)
		end
	else
		// if they aren't actively going directly sideways,
		// change the animation to the diagonal so they
		// don't stop too crooked
		if ( ply:movement_dir() == 2 ) then
			--ply:movement_dir(1)
		elseif ( ply:movement_dir() == 6 ) then
			--ply:movement_dir(7)
		end
	end
	/*
	if ( cmd:GetUpMove() > 0 && !(ply:movement_dir > 7) ) then
		ply:movement_dir = ply:movement_dir()+8
	end
	if ( cmd:GetUpMove() <= 0 && ply:movement_dir() > 7 ) then
		ply:movement_dir(ply:movement_dir()-8)
	end*/
end

local function IsMoveInDirection(mv, ang)
	if mv:GetForwardSpeed() == 0 and mv:GetSideSpeed() == 0 then
	return 0
	end
	ang = math.deg(ang)- math.atan2(mv:GetSideSpeed(), mv:GetForwardSpeed())

	ang = (ang - 360 * math.Round(ang / 360))/45
	if ang > 1 then
	return 0
	elseif ang <-1 then
	return 0
	else
	return 1 - math.abs(ang)
	end
end

local function VectorNormalize( v )
	local	length, ilength;

	length = v:Length()
	if ( length ) then
		ilength = 1/length
		v:Mul(ilength)
	end

	return length
end

function PM_CmdScale( vel, cmd )
	local max, total, scale
	local fmove = cmd:GetForwardMove() --math.Clamp(cmd:GetForwardMove(),-450,450)
	local smove = cmd:GetSideMove() --math.Clamp(cmd:GetSideMove(),-450,450)
	local umove = cmd:GetUpMove() --math.Clamp(cmd:GetUpMove(),-450,450)

	max = math.abs( fmove )

	if ( math.abs( smove ) > max ) then
		max = math.abs( smove );
	end
	if ( math.abs( umove ) > max ) then
		max = math.abs( umove );
	end
	if ( !max ) or max == 0 then
		return 0
	end

	total = math.sqrt( fmove * fmove
		+ smove * smove + umove * umove )

	scale = vel * max / ( 127 * total );

	return scale;
end

function PM_Accelerate( ply, wishdir, wishspeed, accel, mv )
	if true then
		// q2 style
		local		addspeed, accelspeed, currentspeed;

		currentspeed = mv:GetVelocity():Dot(wishdir)

		addspeed = wishspeed - currentspeed


		if (addspeed <= 0) then
			return;
		end

		accelspeed = accel*FrameTime()*wishspeed;
		if (accelspeed > addspeed) then
			accelspeed = addspeed;
		end
	if CLIENT then
		LocalPlayer().accelTest = accelspeed
		LocalPlayer().SpeedTest = mv:GetVelocity()
	end

	if currentspeed then
		hookCall("AirStrafe", ply, currentspeed, wishspeed)
	end
		mv:SetVelocity(mv:GetVelocity() + (accelspeed*wishdir))

	else
	local		wishVelocity;
		local		pushDir;
		local		pushLen = Vector()
		local		canPush;
	wishVelocity = wishdir*wishspeed
	pushDir = wishVelocity-mv:GetVelocity()
	pushLen=pushDir
	pushLen:Normalize()
		pushLen = pushLen:Length()
		canPush = accel*FrameTime()*wishspeed;

		if (canPush > pushLen) then
			canPush = pushLen;
		end

	mv:SetVelocity(mv:GetVelocity() + (canPush*pushDir))

	end
end

function CPM_PM_Aircontrol(ply, mv, wishdir, wishspeed, aircontrol )
	local cpm_pm_aircontrol = aircontrol
	local	zspeed, speed, dot, k;

	if ( (ply:movement_dir() != 0) || wishspeed == 0) then
		return; -- can't control movement if not moveing forward or backward
	end

	zspeed = mv:GetVelocity().z
	mv:SetVelocity(Vector(mv:GetVelocity().x,mv:GetVelocity().y,0))
	local vel = mv:GetVelocity()
	speed = VectorNormalize( vel )

	dot = vel:Dot(wishdir)
	k = 32;
	k = k * (cpm_pm_aircontrol*dot*dot*FrameTime())
	if (dot > 0) then	-- we can't change direction while slowing down
	vel=((vel*speed) + (wishdir*k))
	VectorNormalize( vel )

	end
	if ut_math.IsNan(vel:Length()) then
	vel = mv:GetVelocity()
	end

	mv:SetVelocity(vel*speed)
	mv:SetVelocity(mv:GetVelocity()+Vector(0,0,zspeed))
end

function PM_AirMove( ply, mv, cmd, airaccel, airstop, aircontrol, strafeaccel, wishspd )
	local	wishvel
	local	fmove, smove
	local	scale
	local accel // CPM
	local	wishspeed2 // CPM
	local wishdir									 = Vector()
	local	wishspeed								 = Vector()
	local pm_airaccelerate					= airaccel
	local cpm_pm_airstopaccelerate	= airstop
	local cpm_pm_aircontrol				 = aircontrol
	local cpm_pm_strafeaccelerate	 = strafeaccel
	local cpm_pm_wishspeed					= wishspd
	local fmove, smove							= cmd:GetForwardMove(), cmd:GetSideMove()
	local forward, right						= mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right()
	local vel											 = mv:GetVelocity()

	// project moves down to flat plane
	forward.z, right.z = 0, 0
	forward:Normalize()
	right:Normalize()
	wishvel = (forward*fmove) + (right*smove)
	wishvel.z = 0
	// set the movementDir so clients can rotate the legs for strafing
	PM_SetMovementDir(ply, cmd);

	wishspeed=wishvel

	--print(PM_CmdScale( 450, cmd))
	wishspeed:Normalize()
	wishspeed = wishspeed:Length()

	wishspeed = wishspeed * 300 --mv:GetMaxSpeed()
	wishdir = wishvel

	// CPM: Air Control
	wishspeed2 = wishspeed;

	if (mv:GetVelocity():Dot(wishdir) < 0) then

		accel = cpm_pm_airstopaccelerate;
	else
		accel = pm_airaccelerate;
	end

	if (ply:movement_dir() == 2 || ply:movement_dir() == 6) then

		if (wishspeed > cpm_pm_wishspeed) then
			wishspeed = cpm_pm_wishspeed;

	end
		accel = cpm_pm_strafeaccelerate
	elseif ply:movement_dir() == 0 || ply:movement_dir() == 4 then
	accel = cpm_pm_airstopaccelerate
	end

	ply.wishspeedTest = wishspeed
	// not on ground, so little effect on velocity
	--PM_Accelerate (wishdir, wishspeed, pm_airaccelerate, mv);
	// CPM: Air control

	PM_Accelerate (ply, wishdir, wishspeed, accel, mv);
	--AirAccelerate( ply, mv, cmd, 10, 10 )
	if (cpm_pm_aircontrol>0 ) then

	CPM_PM_Aircontrol(ply, mv, wishdir, wishspeed2, cpm_pm_aircontrol);
	end
end
