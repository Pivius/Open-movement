local PLAYER = FindMetaTable( "Player" )
grappleSound = "weapons/crossbow/hit1.wav"
  //Grapple

hookAdd("Init_Player_Vars", "Init_Grapple", function(ply)
  ply:AddSettings("GrapplePos", Vector(0,0,0)) -- The Position of the grappling hook
  ply:AddSettings("TracePos", Vector(0,0,0))   -- The grapple trace. Mostly required for my syncing
  ply:AddSettings("AllowGrapple", true)        -- Decides if the player can grapple
  ply:AddSettings("Grappling", false)          -- Is the player grappling or not
  ply:AddSettings("Retracting", false)         -- Is the player retracting or not
  ply:AddSettings("RetractSpeed", 50)         -- The speed the player retracts at
  ply:AddSettings("RopeTension", 0)            -- Rope tension
  ply:AddSettings("RopeLength", 0)             -- Rope length
  ply:AddSettings("GrappleSync", {})           -- Sync table
  ply:AddSettings("Intersections", {})        -- Intersecting rope
  if !ply.rope and SERVER then
    ply.rope = ents.Create("rope")
    ply.rope:SetParent(ply)
    ply.rope:SetPos(ply:GetPos())
    ply.rope:Spawn()
  end
end)
// Returns true if the player can grapple
function PLAYER:CanGrapple()
  local tracedata = {}
  tracedata.start = self:EyePos()
  tracedata.endpos = self:TracePos()
  tracedata.filter = player.GetAll()
  local trace = util.TraceLine(tracedata)

  if !trace.HitSky && trace.HitWorld && !self:Grappling() && self:AllowGrapple() then
    return true
  elseif self:Grappling() then
    return true
  else
    return false
  end
end

//Release the hook
function PLAYER:Release()

    self:Retracting(false)
    self:Grappling(false)
    self:Intersections({})
    --self.Intersect = {}
end

// Deploy the hook
function PLAYER:Deploy(origin, trace)
  if self:CanGrapple() && IsFirstTimePredicted() then //Dont hit the sky
    self:Grappling(true)
    table.insert(self:Intersections(), trace.HitPos)
    self:GrapplePos(trace.HitPos+trace.HitNormal:Angle():Forward()*3)
    self:RopeLength(self:GrapplePos():Distance(origin))
    if SERVER then
    --  ply.CurTrail:SetDashed(true)
      sound.Play( grappleSound, self:GrapplePos(), 90 )
    end
  end
end

//Retract the hook
function PLAYER:Retract(mv, distToHook, tension, dirToHook)
  local retTension = math.abs(math.Clamp(tension, tension, 0))
  // New rope length
  self:RopeLength(self:GrapplePos():Distance(mv:GetOrigin()) -((self:RetractSpeed() * FrameTime())))
  distToHook = self:RopeLength()  //It's the same
  if ( tension < self:RetractSpeed() && (distToHook >= self:RopeLength() ) ) then
    if self:OnGround() && tension < 50 then
      self:SetGroundEntity( NULL )
      mv:SetVelocity(mv:GetVelocity()+Vector(0,0,50))
    end
    local newvel = (mv:GetVelocity()) - (tension*dirToHook) + ((self:RetractSpeed())*dirToHook)
    --print(((tension*dirToHook) + (self:RetractSpeed()*dirToHook)):Length())
    mv:SetVelocity(newvel)
    --tension = mv:GetVelocity():Dot(dirToHook)
  end
end


// My attempt to sync Grappling
// Actually pretty smooth at 250 ping
function PLAYER:queueGrapple(value, action)
	if IsFirstTimePredicted() then
		if !self:GrappleSync() then
			self:GrappleSync({})
		end
		if !self:GrappleSync()[value] then
			self:GrappleSync()[value] = action
		end
	end
end

function Hook(ply, mv, cmd)
  //Init
  local cTime = CurTime()
  local cTick = cmd:TickCount()
  local aimVec = ply:GetAimVector()
  if !ply:AllowGrapple() then
    return
  end

  --if !ply.Intersect then
    --ply.Intersect = {}
  --end


  if ply:GrappleSync() == {} then
    ply:queueGrapple(cmd:TickCount(), false)
  end

  if !ply:Grappling() then
    ply:TracePos(ply:EyePos() + ( aimVec * 2000 ))
    --ply.endpos = ply:EyePos() + ( aimVec * 2000 )
  end
  //Trace
  local tracedata = {}
  tracedata.start = ply:EyePos()
  tracedata.endpos = ply:TracePos()
  tracedata.filter = player.GetAll()
  local trace = util.TraceLine(tracedata)
  if SERVER then
    if !ply:IsBot() then
      --ply.CurTrail:SetDashed(mv:KeyDown(IN_SPEED))
    end
  end
  //Release
  if IsFirstTimePredicted() then
  /* -- Quick Grapple Later release
    if mv:KeyDown(IN_ATTACK2) && mv:KeyReleased( IN_ATTACK ) && ply:Grappling() then
      ply:queueGrapple(cmd:TickCount(), false)
    end
  */

  //Grapple
    if !ply:Grappling() && mv:KeyPressed(IN_ATTACK) && ply:Alive() then
      ply:queueGrapple(cTime, true)
    end

    // Release
    if mv:KeyPressed(IN_ATTACK2) || !ply:Alive() then

      ply:queueGrapple(cTime, false)
    end

  if (ply:GrappleSync()[cTime] == true ) then
    ply:Deploy(mv:GetOrigin(), trace)
  elseif (ply:GrappleSync()[cTime] == false) then

    ply:Release()
  end

  end

  //Retract
  ply:Retracting(ply:Grappling() && (mv:KeyDown(IN_ATTACK)))

  //TODO make it better shared
  if ply:Grappling() || (CLIENT && (ply.plyTick == cmd:TickCount())) then
    //Trace
    local Intersect = {}
    Intersect.start = ply:EyePos()-Vector(0,0,7) //So it doesn't look really weird with jumping rope
    Intersect.endpos = ply:GrapplePos()
    Intersect.filter = function(e1, e2)
      return !e1:IsPlayer()
    end
    local trace = util.TraceLine(Intersect)

    if trace.HitWorld then
      table.insert(ply:Intersections(), trace.HitPos+trace.HitNormal:Angle():Forward()*3)
      ply:GrapplePos(trace.HitPos+trace.HitNormal:Angle():Forward()*3)
      ply:RopeLength(ply:GrapplePos():Distance(mv:GetOrigin()))
    end

  end

  //TODO make it better shared
  //TODO Fix issue with direction doesnt matter
  for k, intersect in pairs(ply:Intersections()) do
    if k >= 2 then
      local Intersect = {}
      Intersect.start = ply:Intersections()[k-1]
      Intersect.endpos = ply:EyePos()-Vector(0,0,7) //So it doesn't look really weird with jumping rope
      Intersect.filter = function(e1, e2)
        return !e1:IsPlayer()
      end
      local trace = util.TraceLine(Intersect)
      if k == #ply:Intersections() then

        if !trace.HitWorld then

          ply:GrapplePos(ply:Intersections()[k-1])
          ply:RopeLength(ply:GrapplePos():Distance(mv:GetOrigin()))
          table.remove(ply:Intersections(), k)
        end
      end
    end
  end

  // Nerfing S formations
  if mv:GetOrigin().z > ply:GrapplePos().z then
    ply:RetractSpeed(25)
  else
    ply:RetractSpeed(ply.default["RetractSpeed"])
  end
  //Hook Rendering
  if ents.FindByClassAndParent( "rope", ply )[1]:IsValid() then
    ents.FindByClassAndParent( "rope", ply )[1]:Hook(ply:Grappling(), ply:GrapplePos())
  end
  --
  // Syncing up with client
  if CLIENT && (ply.plyTick == cmd:TickCount()) then
    // Issue with rope spazzing out
    local vector =  ply.oldHPos- ply.oldOrigin
    local distToHook = vector:  Length()
    local dirToHook = vector / distToHook
    local tension = ply.oldVel:Dot(dirToHook)
    if ply:Retracting() then
      ply:Retract(mv, distToHook, tension, dirToHook)
    end
    mv:SetOrigin(ply.oldOrigin) // Avoids teleporting
    mv:SetVelocity(ply.oldVel) // Avoids teleporting
    if (tension < 0 && distToHook >= ply.oldRopeLength) && !ply:Retracting()  then
      if ply:OnGround() && tension < 50 then

        mv:SetVelocity(mv:GetVelocity()+Vector(0,0,10))
      end
      ply:RopeTension(dirToHook * tension * -1)
  		mv:SetVelocity(mv:GetVelocity() + ply:RopeTension())
    end
  end

  //CanGrapple
  if (ply:Alive() && ply:Grappling()) then

    local vector =  ply:GrapplePos()- mv:GetOrigin()
    local distToHook = vector:Length()
    local dirToHook = vector / distToHook
    local tension = mv:GetVelocity():Dot(dirToHook)
    --ply:Friction(3)
    --ply:Accel(20)

    if ply:Retracting() then

      ply:Retract(mv, distToHook, tension, dirToHook)
    end

    if (tension < 0 && (distToHook >= ply:RopeLength() ) && !ply:Retracting() ) then
      if ply:OnGround() && tension < 50 then

        mv:SetVelocity(mv:GetVelocity()+Vector(0,0,10))
      end
  		ply:RopeTension(dirToHook * tension * -1)

  		mv:SetVelocity(mv:GetVelocity() + ply:RopeTension())
    end

      ply.plyTick = cmd:TickCount()
      ply.oldHPos = ply:GrapplePos()
      ply.oldVel = mv:GetVelocity()
      ply.oldRopeLength = ply:RopeLength()
      ply.oldOrigin = mv:GetOrigin()
      ply.oldDist = distToHook
  end
end
