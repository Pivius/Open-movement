/*
  NAME      - AirAccelerate
  FUNCTION  - Air accelerate port from hl2, lets you strafe while airborne.
  ARGS 			-
    ply   - Player
		mv    - CMoveData
	  cmd   - CUserCmd
    accel - Airaccelerate (Higher value lets you strafe faster)
    gain  - How much you can max gain from strafing
*/
function AirAccelerate( ply, mv, cmd, accel, gain )

  if !ply:Alive() or ply:OnGround() then return end

	local addSpeed, accelSpeed, wishDir, wishVel, wishSpd, wishSpeed
  local curSpeed = mv:GetVelocity()
  local fmove, smove = mv:GetForwardSpeed(), mv:GetSideSpeed()
  local forward, right = mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right()
  forward.z, right.z = 0
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

  mv:SetVelocity(mv:GetVelocity() + (accelSpeed * wishDir))
end
