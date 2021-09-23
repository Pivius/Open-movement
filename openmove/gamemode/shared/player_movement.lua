MOVEMENT_MODES = {
  "Parkour",
  "Grapple",
  "RadioSkate",
  "VQ3",
  "CPMA",
  "Bhop",
  "Momentum"

}
if CLIENT then
  CreateClientConVar( "mm_mode", "1", false,true, "Switches between modes. 1-Parkour, 2-Grapple, 3-Radioskate, 4-VQ3, 5-CPMA, 6-Bhop, 7-Momentum")
  cvars.AddChangeCallback( "mm_mode", function( convar_name, value_old, value_new )
    LocalPlayer():movement_mode(math.max(math.min(value_new, #MOVEMENT_MODES), 1))
    net.Start("Mode_Networking")
      net.WriteInt(LocalPlayer():movement_mode(), 6)
      net.WriteEntity(LocalPlayer())
    net.SendToServer()
    LocalPlayer():friction(8)
    LocalPlayer():accel(10)
    LocalPlayer():air_accel(10)
    LocalPlayer():gravity(300)
  end )
else
  util.AddNetworkString( "Mode_Networking" )

  net.Receive("Mode_Networking", function()
    local int = net.ReadInt(6)
    local ply = net.ReadEntity()
    ply:movement_mode(int)
    ply:friction(8)
    ply:accel(10)
    ply:air_accel(10)
    ply:gravity(300)
  end)


end

//
// Player Vars
//
hookAdd("Init_Player_Vars", "Init_Movement", function(ply)
  ply:AddSettings("last_vel", Vector(0,0,0))
  ply:AddSettings("top_speed", {})
  ply:AddSettings("air_accel", 10)
  ply:AddSettings("accel", 10)
  ply:AddSettings("friction", 8)
  ply:AddSettings("gravity", 300)
  ply:AddSettings("air_accel_speed", 0)
  ply:AddSettings("water_friction", 1)
  ply:AddSettings("water_accel", 10)
  ply:AddSettings("LeftGround", false)
  ply:AddSettings("step_size", ply:GetStepSize())
  ply:SetStepSize(32)
  ply:AddSettings("movement_mode", 1)

  for _, modes in ipairs(MOVEMENT_MODES) do
    table.insert(ply:top_speed(), 0)
  end

end)

local function Movement_Parkour(ply, mv, cmd)
  if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Parkour") then
    WallJump(ply, mv, cmd)
    WallSlide(ply, mv, cmd)
  end
end

local function Movement_Grapple(ply, mv, cmd)
  if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Grapple") then
    ply:gravity(600)
    Hook(ply, mv, cmd)
  end
end

local function Movement_Bhop(ply, mv, cmd)
  if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Bhop") then
    ply:friction(8)
    ply:accel(10)
    ply:air_accel(500)
    ply:gravity(500)

    AutoHop(ply, mv, true)
  end
end

local function Movement_RadioSkate(ply, mv, cmd)
  if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "RadioSkate") then
    ply:friction(0)
    --ply:accel(10)
    ply:air_accel(50)
  end
end

local function Movement_Momentum(ply, mv, cmd)
  if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Momentum") then
    PM_AirMove( ply, mv, cmd, 1, 0, 150, 1, 320 )
    AutoHop(ply, mv, true)
  end
end

local function Movement_VQ3(ply, mv, cmd)
  if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "VQ3") then
    ply:gravity(300)

    PM_AirMove( ply, mv, cmd, 1, 1, 0, 1, 400 )
    AutoHop(ply, mv, true)
  end
end

local function Movement_CPMA(ply, mv, cmd)
  if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "CPMA") then
    ply:gravity(300)
    ply:accel(15)
    PM_AirMove( ply, mv, cmd, 1, 2.5, 150, 70, 30 )
    AutoHop(ply, mv, true)
  end
end

hook.Add("SetupMove", "Core_Movement", function(ply, mv, cmd)
  if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
  if !ply:OnGround() and !ply:LeftGround() then
		hook.Call("PlayerLeftGround", nil, ply, cmd:TickCount())
  end
  if ply:WaterLevel() > 1 and !ply:OnGround() then
    WaterMove(ply, mv, ply:accel(), 1)
  end
  ply:air_accel_speed(0)
  StartGravity(ply, mv, ply:gravity())
  --print(mv:GetVelocity())
  Movement_Parkour(ply, mv, cmd)
  Movement_Bhop(ply, mv, cmd)
  Movement_RadioSkate(ply, mv, cmd)
  Movement_Grapple(ply, mv, cmd)

  if ply:GetGroundEntity() != NULL then
    if !(mv:KeyPressed(IN_JUMP) and !mv:KeyWasDown( IN_JUMP )) then -- Allow bhop

      Friction( ply, mv, cmd, ply:friction() )
      Accelerate( ply, mv, cmd, ply:accel() )
    end
  else
    -- 30 gain is normal.
    if ply:movement_mode() != util.Table.GetByValue(MOVEMENT_MODES, "CPMA") && ply:movement_mode() != util.Table.GetByValue(MOVEMENT_MODES, "VQ3") then
      AirAccelerate( ply, mv, cmd, ply:air_accel(), 30 )
    end
    Movement_Momentum(ply, mv, cmd)
    Movement_VQ3(ply, mv, cmd)
    Movement_CPMA(ply, mv, cmd)
  end

  RampSlide.Slide(ply, mv, cmd)
  if ply:top_speed()[ply:movement_mode()] < ply:Speed2D() then
    ply:top_speed()[ply:movement_mode()] = ply:Speed2D()
  end

  local fLateralStoppingAmount = ply:last_vel():Length2D() - mv:GetVelocity():Length2D()
  ply:last_vel(mv:GetVelocity())

end)
