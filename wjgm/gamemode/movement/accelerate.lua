
/*
  NAME      - Accelerate
  FUNCTION  - Accelerate port from hl2, lets you strafe while on ground.
  ARGS 			-
    ply - Player
		mv  - CMoveData
	  cmd - CUserCmd
    accelerate - Accelerate (Higher value lets you strafe faster)
*/
function Accelerate( ply, mv, cmd, accelerate )

  if !ply:Alive() or !ply:OnGround() or ply:WaterLevel() > 0 then return end

	local addSpeed, accelSpeed, wishDir, wishVel, wishSpeed
  local curSpeed = mv:GetVelocity()
  local fmove, smove = (mv:GetForwardSpeed()), (mv:GetSideSpeed())
  local forward, right = mv:GetAngles():Forward(), mv:GetAngles():Right()

  if forward.z != 0 then
    forward.z = 0
		forward:Normalize()
  end
  if right.z != 0 then
    right.z = 0
    right:Normalize()
  end
  wishVel = (forward*fmove) + (right*smove)
  wishVel.z = 0
  wishSpeed = wishVel:Length()

  if (wishSpeed > mv:GetMaxSpeed()) then
    wishVel = wishVel * (mv:GetMaxSpeed()/wishSpeed)
    wishSpeed = mv:GetMaxSpeed()
  end

  wishVel:Normalize()

  wishDir = wishVel
	// Determine veer amount
	curSpeed = mv:GetVelocity():Dot(wishDir)

	// See how much to add
  addSpeed = wishSpeed-curSpeed
	// If not adding any, done.
	if (addSpeed <= 0) then
		return
  end
  local surfaceFriction = 1
	--// Determine acceleration speed after acceleration
	accelSpeed = accelerate * wishSpeed * FrameTime() * surfaceFriction
	// Cap it
	if (accelSpeed > addSpeed) then
		accelSpeed = addSpeed
  end
  mv:SetVelocity((mv:GetVelocity() + (accelSpeed * wishDir)))
end
