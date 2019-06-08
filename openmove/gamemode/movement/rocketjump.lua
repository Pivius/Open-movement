hookAdd("Init_Player_Vars", "Init_Rockets", function(ply)
  ply:AddSettings("CanFire", true)
  ply:AddSettings("Rockets", {})
  ply:AddSettings("RocketDelay", 0)
  ply:AddSettings("FiredRockets", 0)
  ply:AddSettings("RocketSpeed", 1000)
  ply:AddSettings("BlastRadius", 120)
  ply:AddSettings("Rocket_Effects", 0)
  ply:AddSettings("Rocket_Sound", 0)
end)

local meta = FindMetaTable( "Player" )
local function AngleVectors( angles, forward, right, up)
	local		angle
	local		sr, sp, sy, cr, cp, cy
	// static to help MS compiler fp bugs

	angle = angles.y * (math.pi*2 / 360)
	sy = math.sin(angle)
	cy = math.cos(angle)
	angle = angles.pr * (math.pi*2 / 360)
	sp = math.sin(angle)
	cp = math.cos(angle)
	angle = angles.r * (math.pi*2 / 360)
	sr = math.sin(angle)
	cr = math.cos(angle)

	if (forward) then

		forward.x = cp*cy
		forward.y = cp*sy
		forward.z = -sp
	end
	if (right) then

		right.x = (-1*sr*sp*cy+-1*cr*-sy)
		right.y = (-1*sr*sp*sy+-1*cr*cy)
		right.z = -1*sr*cp
	end
	if (up) then

		up.x = (cr*sp*cy+-sr*-sy)
		up.y = (cr*sp*sy+-sr*cy)
		up.z = cr*cp
	end
end

function AAS_WeaponJumpZVelocity(ply, viewangles, radiusdamage, hit)
	local kvel, v, start, dir, endPos
  local forward = Vector()
  local right = Vector()
	local	mass, knockback, points;
  local rocketoffset = Vector(8, 8, 8)
	local mins = ply:OBBMins()
	local maxs = ply:OBBMaxs()
	local bsptrace;
  local pos = ply:GetPos()
  local ePos = ply:EyePos()
  local vA = (hit-ePos):GetNormalized():Angle()
  local origin = pos

  start   = origin
  start.z = start.z+8

  AngleVectors(vA, forward, right, NULL);
	start.x = start.x + (forward.x * rocketoffset.x + right.x * rocketoffset.y)
	start.y = start.y + (forward.y * rocketoffset.x + right.y * rocketoffset.y)
	start.z = start.z + (forward.z * rocketoffset.x + right.z * rocketoffset.y + rocketoffset.z)
  endPos  = start   + 10000 * forward
	//trace a line to get the impact point
  bsptrace 	      = {}
  bsptrace.start 	 = start
  bsptrace.endpos 	 = endPos
  bsptrace.filter = player.GetAll()

  local tracedata = util.TraceLine(bsptrace)
  if tracedata.StartSolid then
    print("ada")
    --tracedata.HitPos = start + 500 * forward
  end
	//calculate the damage the bot will get from the rocket impact
  v = mins+maxs

  v = pos + (0.5*v)
  v = tracedata.HitPos-v

	points = radiusdamage - 0.5 * v:Length();

	if (points < 0) or v:Length() > radiusdamage then
    points = 0;
  end
	//the owner of the rocket gets half the damage
	--points = points* 0.5;
	//mass of the bot (p_client.c: PutClientInServer)
	mass = 200;
	//knockback is the same as the damage points
	knockback = points;
	//direction of the damage (from trace.endpos to bot origin)
  dir = origin-tracedata.HitPos
	dir:Normalize()
	//damage velocity
  kvel = dir * (1000 * knockback / mass); //the rocket jump hack...

	//rocket impact velocity
	return kvel
end

local function OnHit(key, td, ply, rf, tick, aimVec)
  if IsFirstTimePredicted() or CLIENT then
    ply.rocketSpeeds[tick] = {aimVec:Angle(), td.HitPos}
    local dupe = {}
    table.CopyFromTo( ply:Rockets(), dupe )
    table.remove(dupe, key)
    ply:Rockets(dupe)
    ply:FiredRockets(ply:FiredRockets()-1)
    if (ply:Rocket_Effects() <= 1 and CLIENT) or (ply:Rocket_Effects() == 1 and SERVER) then
      local hitEffect = EffectData()
      hitEffect:SetOrigin( td.HitPos )
      hitEffect:SetEntity( ply )
      util.Effect( "explode", hitEffect, true, rf )
    end
    if SERVER then
      if (ply:Rocket_Sound() <= 1) then
        sound.Play("weapons/mortar/mortar_explode1.wav", td.HitPos, 75, 200, 1)
        sound.Play("weapons/mortar/mortar_explode1.wav", td.HitPos, 75, 200, 1)
        sound.Play("weapons/mortar/mortar_explode1.wav", td.HitPos, 75, 200, 1)
        sound.Play("weapons/mortar/mortar_explode1.wav", td.HitPos, 75, 200, 1)
      end
    end
  end

end

local function RocketCheck(ply, mv, tick)
  if SERVER then
    local rf = RecipientFilter()
    rf:AddAllPlayers()
    for _, v in pairs(player.GetAll()) do
      if (v:Rocket_Effects() >= 1) and v != ply then
        rf:RemovePlayer(v)
      end
    end
    rf:RemovePlayer(ply)
  end

  for k, v in pairs(ply:Rockets()) do
    local aimVec = v["Angle"]
    if IsFirstTimePredicted() then
      v["Pos"] = v["Pos"]+(aimVec*(ply:RocketSpeed()*FrameTime()))
    end
    local trace 	 = {}
  	trace.start 	 = v["FirePos"]
  	trace.endpos 	 = v["Pos"]
    trace.filter  = player.GetAll()
    local tracedata = util.TraceLine(trace)

    if IsFirstTimePredicted() and (ply:Rocket_Effects() <= 1 and CLIENT) then
      local rocketEffect = EffectData()
      rocketEffect:SetOrigin( v["Pos"] )
      rocketEffect:SetEntity( ply )
      util.Effect( "rocket", rocketEffect, true, rf )
      if trace.start:Distance(trace.endpos) > 10000 then -- Limit length
        OnHit(k, tracedata, ply, rf, tick, aimVec)
      end
    end

    if tracedata.Hit then

      OnHit(k, tracedata, ply, rf, tick, aimVec)
    end
  end
end

function FireRocket(ply, mv, cmd)
  if !ply:can_rocketjump() then return end
  local maxRockets = 3

  --ply:CanFire(true)

  if !ply.rocketSpeeds then
    ply.rocketSpeeds  = {}
  end

  if IsFirstTimePredicted() then
    for k, v in pairs(ply.rocketSpeeds) do
      if k+100 < cmd:TickCount() then
        ut_tbl.RemoveByKey(ply.rocketSpeeds, k)
      end
    end
  end

  if mv:KeyPressed(IN_ATTACK) && IsFirstTimePredicted() && ply:FiredRockets() < maxRockets && ply:CanFire() && ply:RocketDelay() <= CurTime() and ply:Alive() then
    local aimVec = ply:GetAimVector()
    local dupe = {}
    table.CopyFromTo( ply:Rockets(), dupe )
    local t = {
      ["Angle"] = aimVec,
      ["Pos"] = ply:EyePos()+(aimVec),
      ["FirePos"] = ply:EyePos(),
      ["Hit"] = false,
      ["Tick"] = 0
    }

    table.insert(dupe, t)
    ply:Rockets(dupe)
    /*
    ply:FireAngles(aimVec)
    ply:FirePos(ply:EyePos())
    ply:RocketPos(ply:FirePos()+(aimVec))
    */

    if SERVER then
      if (ply:Rocket_Sound() <= 1) then
        ply:EmitSound( "weapons/gauss/fire1.wav", 75, 200, 0.5, CHAN_WEAPON )
      end
    end
    ply:FiredRockets(ply:FiredRockets()+1)
    ply:RocketDelay(CurTime()+0.8)
  end

  if ply:FiredRockets() >= maxRockets then
    --ply:CanFire(false)
  end
  RocketCheck(ply, mv, cmd:TickCount())
  local vel = mv:GetVelocity()
  local doit = false
  if ply.rocketSpeeds[cmd:TickCount()] then
  	doit = true
  end
  if doit then
    local rj = AAS_WeaponJumpZVelocity(ply, ply.rocketSpeeds[cmd:TickCount()][1], 120, ply.rocketSpeeds[cmd:TickCount()][2])

		if rj:Length() > 5 then
			--ply.pm_time.Insert(false, 0)
		end
    if IsFirstTimePredicted() then
      mv:SetVelocity(vel+rj)
    elseif !IsFirstTimePredicted()  then

      mv:SetVelocity(vel+rj)
    end
  end
end
hook.Add("SetupMove", "Fire Rocket", FireRocket)
