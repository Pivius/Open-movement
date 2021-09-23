// Ported from:
// https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/game/shared/gamemovement.cpp#L1612
// Set friction to 0 in console
/*
  NAME      - Friction
  FUNCTION  - Applies friction to the player.
  ARGS 			-
    ply      - Player
		mv       - CMoveData
	  cmd      - CUserCmd
    friction - Friction
*/
function Friction(ply, mv, cmd, friction)
  local vel        = mv:GetVelocity()
  local	speed      = vel:Length()
  local	drop       = 0
  local newspeed, control

  // If too slow, return
  if (speed < 0.1) then
    return
  end
  // On an entity that is the ground
  // Bleed off some speed, but if we have less than the bleed
  //  threshold, bleed the threshold amount.
  if (speed < GetConVar( "sv_stopspeed" ):GetFloat()) then
    control = GetConVar( "sv_stopspeed" ):GetFloat()
  else
    control = speed
  end
  // Add the amount to the drop amount.
  drop = drop + ( control*friction*FrameTime() )

  // Scale the velocity
  newspeed = speed - drop
  if ( newspeed < 0 ) then
  	newspeed = 0
  end

  if newspeed != speed then
  	// Determine proportion of old speed we are using.
  	newspeed = newspeed / speed

    // Adjust velocity according to proportion.
    vel = vel * newspeed
  end
  // Set the velocity
  mv:SetVelocity(vel)
end

/*
  NAME      - StartGravity
  FUNCTION  - Handles gravity
  ARGS      -
		ply        - Player
		mv          - CMoveData
		accelerate  - Water accelerate
    friction    - Water friction
*/
function WaterMove(ply, mv, accelerate, friction)
  local i, wishvel, wishspeed, wishdir, start, dest, temp, pm, speed, newspeed
  local addspeed, accelspeed, forward, right, up, fmove, smove, umove, outwishvel
  local m_surfaceFriction = 1
  local velocity = mv:GetVelocity()
  local maxspeed = ply:GetMaxSpeed()
  fmove, smove, umove = mv:GetForwardSpeed(), mv:GetSideSpeed(), mv:GetUpSpeed()
  forward, right, up = mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right(), mv:GetMoveAngles():Up()

  wishvel = (forward*fmove) + (right*smove)
  // if we have the jump key down, move us up as well
  if mv:KeyDown(IN_JUMP) then
    wishvel.z = wishvel.z + maxspeed
  elseif (fmove == 0 && smove == 0 && umove == 0) then
    wishvel.z = wishvel.z - 60 // drift towards bottom
  else
    // exaggerate upward movement along forward as well
    local up_movement = fmove * forward.z * 2
    up_movement = math.Clamp(up_movement, 0, maxspeed)
    wishvel.z = wishvel.z + umove + up_movement
  end
  wishspeed = wishvel:Length()

  if (wishspeed > maxspeed) then
    wishvel = wishvel * (maxspeed/wishspeed)
    wishspeed = maxspeed
  end
  wishspeed = wishspeed * 0.8

  wishvel:Normalize()
  wishdir = wishvel

  speed = velocity:Length()

  if speed > 0 then
    newspeed = speed - FrameTime() * speed * friction * m_surfaceFriction
    if newspeed < 0.1 then
      newspeed = 0
    end
    velocity = velocity * (newspeed/speed)
  else
    newspeed = 0
  end


  if wishspeed >= 0.1 then
    addspeed = wishspeed - newspeed
    if addspeed > 0 then
      accelspeed = accelerate * wishspeed * FrameTime() * m_surfaceFriction
      if accelspeed > addspeed then
        accelspeed = addspeed
      end
      local delta_speed = accelspeed * wishvel
      velocity = velocity + delta_speed
    end
  end
  mv:SetVelocity(velocity)

end
