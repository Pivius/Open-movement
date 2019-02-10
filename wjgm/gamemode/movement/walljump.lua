local PLAYER = FindMetaTable( "Player" )
local moveKeys = {
	[1] = IN_FORWARD,
	[2] = IN_BACK,
	[3] = IN_MOVERIGHT,
	[4] = IN_MOVELEFT
}

hook.Add("OnEntityCreated","WallJump_InitPlayer",function(ply)
  local plMeta = getmetatable(ply)
	if plMeta!=FindMetaTable("Player") then
    return
  end
  // Player variables
	ply.vDir = Vector(0,0,0)
	ply.wj_cooldown = 0
	ply.rebound_power = 260
	ply.vertical_power = 200
	ply.can_walljump = true
	ply.sync_samples_walljump = {}
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
			self.vDir = dirs[bit.band( v, bit.bor( validKeys ) )]
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

	if !ply.can_walljump || ply.is_sliding || table.HasValue(ply.sync_samples_wallslide, tick_count) || !ply:Alive() then return end
	local cur_time		= CurTime()
	local vVelocity = Vector(0,0,0) -- Kick velocity
	local vel = mv:GetVelocity()		-- Velocity
	if #ply.sync_samples_walljump > 0 then
		if #ply.sync_samples_walljump >= 10 then
			table.remove(ply.sync_samples_walljump, #ply.sync_samples_walljump)
		end
	end

	if table.HasValue(ply.sync_samples_walljump, tick_count) || cur_time >= ply.wj_cooldown then

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
  		vVelocity = (ply.vDir * ply.rebound_power)
  		vVelocity.z = ply.vertical_power
  		mv:SetVelocity(vVelocity+vel)
			if !table.HasValue(ply.sync_samples_walljump, tick_count) then
				table.insert(ply.sync_samples_walljump, 1, tick_count)
			end
      --ply.sync_samples_walljump[tick_count] = true
  		if IsFirstTimePredicted() then
  			if CLIENT then
  				ply:EmitSound("npc/footsteps/hardboot_generic"..math.random(1,6)..".wav") -- For varying kick sounds
  			end
  			hook.Call("WallKicked", nil, ply, CurTime(), vForward, vel, mv:GetVelocity(), bit.band( mv:GetButtons(), bit.bor( unpack(moveKeys) ) ), select(2, ply:checkWall(mv, ply.vDir)) )
				-- Set the walljump timer. 200ms
  			ply.wj_cooldown = cur_time + 0.2
  		end
  	end
  end
end
