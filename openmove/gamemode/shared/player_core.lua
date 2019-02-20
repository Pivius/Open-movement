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


hook.Add('PlayerSpawn', 'Core_Player_Spawn', function( ply )

end)

hook.Add('PlayerDeath', 'Core_Player_Death', function ( ply )

end)

hook.Add('PlayerDisconnected', 'Core_Player_Disc', function( ply )

end)

hook.Add('OnPlayerHitGround', 'TouchedGround', function( ply, water, floater, speed )
--ply:SetMaterial( "models/Health_model/Health_model_texture" )

  ply:LeftGround(false)
end)

hook.Add('PlayerLeftGround', 'LeftGround', function( ply )
  ply:LeftGround(true)
  ply:SlopeFix_InAir(true)
  --  print("a")
end)

--Player Regeneration
function Regen(ply)
    local delay = 1
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

-- For lua refreshing
for _, player in pairs(player.GetAll()) do
  hookCall("Init_Player_Vars", player)
end
