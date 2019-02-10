local PLAYER = FindMetaTable( "Player" )

function GetDate()
  local Timestamp = os.time()
  local TimeString = os.date( "%d/%m/%Y" , Timestamp )
  return TimeString
end


function PLAYER:Speed()
  local vel = self:GetVelocity()
  return vel:Length()/10
end

function PLAYER:Speed2D()
  local vel = self:GetVelocity()
  return vel:Length2D()/10
end

function PLAYER:SpeedZ()
  local vel = self:GetVelocity()
  return math.abs(vel.z/10)
end


//
//  Hooks
//


hook.Add('PlayerDeathThink', 'Player_Death_Think', function(ply)
  if ( ply.NextSpawnTime && ply.NextSpawnTime > CurTime() ) then return end
  if ( ply:IsBot() || ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_ATTACK2 ) || ply:KeyPressed( IN_JUMP ) ) then

  	ply:Spawn()

  end
end)

hook.Add("OnEntityCreated","Core_InitPlayerSpawn",function(ply)
  local plMeta = getmetatable(ply)
	if plMeta!=FindMetaTable("Player") then
    return
  end
  // Player variables
  ply.LastVel = Vector(0,0,0) // Velocity last tick
  ply.Topspeed = 0 // Highest velocity reached

end)

hook.Add('PlayerSpawn', 'Core_Player_Spawn', function( ply )

end)

hook.Add('PlayerDeath', 'Core_Player_Death', function ( ply )

end)

hook.Add('PlayerDisconnected', 'Core_Player_Disc', function( ply )

end)

hook.Add("SetupMove", "Core_Movement", function(ply, mv, cmd)
  if ply:GetMoveType() == MOVETYPE_NOCLIP then return end

  if ply:GetGroundEntity() != NULL then
    if !(mv:KeyPressed(IN_JUMP) and !mv:KeyWasDown( IN_JUMP )) then -- Allow bhop

      Friction( ply, mv, cmd, 8 )
      Accelerate( ply, mv, cmd, 10 )
    end
  else

    AirAccelerate( ply, mv, cmd, 10, 30 )
    if ply:WaterLevel() > 0 then
      Friction( ply, mv, cmd, 1 )
    end
  end
  WallJump(ply, mv, cmd)
  WallSlide(ply, mv, cmd)
  local fLateralStoppingAmount = ply.LastVel:Length2D() - mv:GetVelocity():Length2D()
  ply.LastVel = mv:GetVelocity()
end)
/*
hook.Add("SetupMove", "Movement", function(ply, mv, cmd)
  if ply:Noclip() || ply:GetMoveType() == MOVETYPE_NOCLIP then return end
  if !ply:OnGround() and !ply:LeftGround() then
		hook.Call("PlayerLeftGround", nil, ply, cmd:TickCount())
  end

  if SERVER then
    --ply:TrailColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
    ply:TrailMat("trails/laser.vmt")--trick/test.vmt
    --ply:TrailSize(10, 2)
  end


  if ply:GetGroundEntity() != NULL then
    if !(mv:KeyPressed(IN_JUMP) and !mv:KeyWasDown( IN_JUMP )) then -- Allow bhop
      Friction( ply, mv, cmd, ply:Friction() )
      Accelerate( ply, mv, cmd, ply:Accel() )
      --PM_StepSlideMove( ply, mv, cmd, false )
    elseif mv:KeyPressed(IN_JUMP) and ply:OnGround() then


    end
  else
    AirAccelerate( ply, mv, cm, ply:AirAccel(), ply:Gain() )
    --PM_StepSlideMove( ply, mv, cmd, GetConVar( "sv_gravity" ):GetFloat()/800 ) // Divide by 800 due to that being default
    --if ply:WaterLevel() > 0 then
      --Friction( ply, mv, cmd, 1 )
    --end
  end
  Step(ply)
  WallJump(ply, mv, cmd)
  WallSlide(ply, mv)
  RampSlide.Slide(ply, mv, cmd)
	if (!ply:OnGround() and ply:AutoHop()) then
	  mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_JUMP ) ) )
	end
  local fLateralStoppingAmount = ply:LastVel():Length2D() - mv:GetVelocity():Length2D()
  if fLateralStoppingAmount > 1 and !ply:OnGround() and IsFirstTimePredicted() and ply:LastVel():Length2D() > 1000 and (ply:LastVel():Length2D()-fLateralStoppingAmount) <= 450 and (CurTime()-ply.wj_sync_module.GetLastTime() <= 0.5) then
		Combo:AddTo(ply, "Wallcheck")
  end

  ply:LastVel(mv:GetVelocity())

end)*/

--Player Regeneration
function Regen(ply)
    local delay = 0.5
    if CurTime() > ((ply.LastHeal or 0) + delay) then
      if ply:Health() < 100 then
        ply.LastHeal = CurTime()
        if ply:Alive() then
          ply:SetHealth(ply:Health()+1)

        end
      end
      if ply:Health() < 0 then
        ply:SetHealth(0)
      end
    end
end
hook.Add("PlayerTick", "Regeneration", Regen)
