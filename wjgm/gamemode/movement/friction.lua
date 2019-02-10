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
