local PLAYER = FindMetaTable( "Player" )
local moveKeys = {
	[1] = IN_FORWARD,
	[2] = IN_BACK,
	[3] = IN_MOVERIGHT,
	[4] = IN_MOVELEFT
}
hookAdd("Init_Player_Vars", "Init_Walljump", function(ply)
  ply:AddSettings("vDir", Vector(0,0,0))
  ply:AddSettings("wj_cooldown", 0)
  ply:AddSettings("rebound_power", 260)
  ply:AddSettings("vertical_power", 200)
  ply:AddSettings("can_walljump", true)
  ply.wj_sync_module = load.Module( "modules/sync.lua" )
	ply.wj_sync_module.Insert(false, CurTime())

end)
/*
  NAME      - Player:checkWall
  FUNCTION  - Trace check to see if there our trace collides with anything in a direction(Argument: dir).
  ARGS 			-
		mv  - CMoveData
	  dir - Direction to trace
*/
function PLAYER:checkWall(mv, dir)
	local td = {}
	td.start = mv:GetOrigin()
	td.endpos = mv:GetOrigin()-(dir*30)
	td.filter = self
	tr = util.TraceLine(td)
	if (tr.Fraction < 1) and not tr.HitSky then
		return true, tr.HitNormal
	end

	return false
end

/*
  NAME      - Player:GetKey
  FUNCTION  - A check to see if the player is holding the right keys and is able to walljump.
  ARGS 			-
		mv   - CMoveData
	  dirs - Directions to trace.
*/
function PLAYER:GetKey(mv, dirs)
	-- Move keys
	local validKeys = bit.band( mv:GetButtons(), bit.bor( unpack(moveKeys) ) )
	-- Check if IN_ keys are being pressed and jump is down. Also check if any Valid keys are being held or pressed.
	if mv:KeyDown(IN_JUMP) and (mv:KeyPressed( bit.band( mv:GetButtons(), bit.bnot( mv:GetOldButtons(),IN_JUMP ) ) ) and ( mv:KeyDown( validKeys ) or mv:KeyPressed( validKeys ) ) or mv:KeyPressed(validKeys)) then

		local LandR = bit.band(validKeys,bit.bor(IN_MOVERIGHT,IN_MOVELEFT))
		local FandB = bit.band(validKeys,bit.bor(IN_BACK,IN_FORWARD))

		for k, v in pairs(moveKeys) do

			if !self:checkWall(mv, dirs[bit.band( v, bit.bor( validKeys ) )]) then
				continue
			end
			self:vDir( dirs[bit.band( v, bit.bor( validKeys ) )] )
			return true
		end
	end
	return false
end

/*
  NAME      - WallJump
  FUNCTION  - Gives the player the ability to walljump when a movement key is held and jump is pressed.
  ARGS 			-
		ply - Player
		mv  - CMoveData
	  cmd - CUserCmd
*/
function WallJump(ply, mv, cmd)
	local tick_count = cmd:TickCount()
	local cur_time		= CurTime()

	if !ply.ws_sync_module then return end
	if !ply:can_walljump() || !ply:Alive() then return end
	ply.wj_sync_module.history_length  = 30
	local vVelocity = Vector(0,0,0) -- Kick velocity
	local vel = mv:GetVelocity()		-- Velocity

	if ply.wj_sync_module.GetByTime(tick_count) || cur_time >= ply:wj_cooldown() then

		local vForward = mv:GetAngles()
		vForward:RotateAroundAxis( Vector(0,0,1),90 )
		vForward = vForward:Right():GetNormalized()
		vForward.z = 0
		local vRight = mv:GetAngles():Right():GetNormalized()
		vRight.z = 0
		--Directions
		dirs = {
			[0] = Vector(0,0,0),
			[IN_FORWARD] = vForward,
			[IN_BACK] = -vForward,
			[IN_MOVERIGHT] = vRight,
			[IN_MOVELEFT] = -vRight
		}
		--Register key inputs
		if ply:GetKey(mv, dirs) then
			if ply.ws_sync_module.GetByTime(tick_count) then
				ply.ws_sync_module.RemoveByTime(tick_count)
			end
  		vVelocity = (ply:vDir() * ply:rebound_power())
  		vVelocity.z = ply:vertical_power()
  		mv:SetVelocity(vVelocity+vel)
			ply.wj_sync_module.Insert(true, tick_count, true)
      --ply.sync_samples_walljump[tick_count] = true
  		if IsFirstTimePredicted() then
  			if CLIENT then
  				ply:EmitSound("npc/footsteps/hardboot_generic"..math.random(1,6)..".wav") -- For varying kick sounds
  			end
  			hook.Call("WallKicked", nil, ply, cur_time, tick_count, vForward, vel, mv:GetVelocity(), bit.band( mv:GetButtons(), bit.bor( unpack(moveKeys) ) ), select(2, ply:checkWall(mv, ply:vDir())) )
				-- Set the walljump timer. 200ms
  			ply:wj_cooldown(cur_time + 0.2)
  		end
  	end
  end
end
