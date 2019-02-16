/*
  NAME      - StartGravity
  FUNCTION  - Handles gravity
  ARGS      -
		ply  - Player
		mv   - CMoveData
		grav - Gravity
*/
function StartGravity(ply, mv, grav)
  if ply:WaterLevel() > 1 then
    return
  end
  if !grav then grav = 1 end
  if GetConVar( "sv_gravity" ):GetFloat() != 0 then
    grav = grav - GetConVar( "sv_gravity" ):GetFloat() -- Note that sv_gravity affects other entities, while this does not.
  end
  local velocity = mv:GetVelocity()
  local player_gravity = 1
  velocity.z = velocity.z - (player_gravity * grav * 0.5 * FrameTime())*2
  velocity.z = velocity.z + (ply:GetBaseVelocity().z * FrameTime())
  mv:SetVelocity(velocity)
end
