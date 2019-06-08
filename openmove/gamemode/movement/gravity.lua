/*
	NAME      - StartGravity
	FUNCTION  - Handles gravity
	ARGS      -
		ply  - Player
		mv   - CMoveData
		grav - Gravity
		axis - Normal to represent the direction to apply gravity towards
*/
function StartGravity(ply, mv, grav, axis)
	if !axis then axis = Vector(0,0,-1) end
	if ply:WaterLevel() > 1 then
		return
	end
	
	if !grav then grav = 1 end
	-- Note that sv_gravity affects other entities, while this does not.
	-- This fixes the issue with this adding gravity to the old gravity.
	
	local velocity = mv:GetVelocity()
	
	local player_gravity = 1
	local new_grav = (player_gravity * grav * FrameTime())
	new_grav = Vector(new_grav, new_grav, new_grav)
	axis = new_grav * axis * ply:velocity_scale()
	
	mv:SetVelocity(velocity + axis)
	
end

hook.Add("SetupMove", "Gravity_Nullify", function(ply, mv)
	if GetConVar( "sv_gravity" ):GetFloat() != 0 then
		ply:SetGravity( 0.01 )
		mv:SetVelocity(mv:GetVelocity() + Vector(0, 0, GetConVar( "sv_gravity" ):GetFloat() * 0.01 * FrameTime()))
	end
end)
