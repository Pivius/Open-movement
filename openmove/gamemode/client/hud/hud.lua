local hud = {}
hud.HUD_CACHE = hud.HUD_CACHE or {}

-------------------------------------
-- CVars.
-------------------------------------
local LagSens = CreateClientConVar( "hud_lag_sensitivity", "10", true, true, "Hud lag sensitivity. Default: 10")

cvars.AddChangeCallback( "hud_lag_sensitivity", function( convar_name, value_old, value_new )
  if tonumber(value_new) > 30 then
    LagSens:SetInt(30)
    return
  elseif tonumber(value_new) < 1 then
    LagSens:SetInt(1)
    return
  end
  local ls = math.Clamp(LagSens:GetInt(),1,30)
  for k, v in pairs(hud.HUD_CACHE) do
    v.tiltRate = math.Clamp(ls,1,30)/4
    v.resetRate = 40/((ls/4)/2)
  end
end )

-------------------------------------
-- INIT UI.
-------------------------------------
function hud.Init()
  local ls = math.Clamp(LagSens:GetFloat(),1,30)
  --Speedometer

  if hud.HUD_CACHE["HUD_HP"] then
    HUD_HP:Remove()
    hud.HUD_CACHE["HUD_HP"] = nil
  end
  HUD_HP = hudmod.CreatePanel( nil, ls / 4, 40 / ( ( ls / 4 ) / 2 ), 20 )
  hud.HUD_CACHE["HUD_HP"] = HUD_HP

  if hud.HUD_CACHE["HUD_VEL"] then
    HUD_VEL:Remove()
    hud.HUD_CACHE["HUD_VEL"] = nil
  end
  HUD_VEL = hudmod.CreatePanel( nil, ls / 4, 40 / ( ( ls / 4 ) / 2 ), -20 )
  hud.HUD_CACHE["HUD_VEL"] = HUD_VEL
  HUD_VEL.moveUpdate = true
end
hud.Init()

-------------------------------------
-- Removes standard UI.
-------------------------------------
function GM:HUDDrawTargetID()
end
function GM:HUDShouldDraw(name)
    local draw = true
    if(name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" --[[or name == "CHudCrosshair"]] ) then
    draw = false;
    end
return draw;
end

local a = 0 //avg
local s = 0 //samples
local calls = 1000 //calls
local benchmark = false
function HUD_HP:Draw3D(ply, scrw, scrh)
  if s <= calls && benchmark == "hp" then
    bench.Push()
  end
  presets.load("health_default", ply, scrw, scrh)
  if s <= calls && benchmark == "hp" then
    a = a + bench.Pop()
    s = s+1
    print(s)
  end
  if s >= calls && benchmark == "hp" then
    print(a/s)
  end
end



function HUD_VEL:Draw3D(ply, scrw, scrh, cx, cy)
  if s <= calls && benchmark == "vel" then
    bench.Push()
  end
  presets.load("velocity_graph", ply, scrw, scrh, self, cx, cy)
  if s <= calls && benchmark == "vel" then
    a = a + bench.Pop()
    s = s+1
    print(a/s)
  end
  if s >= calls && benchmark == "vel" then
    print(a/s)
  end
end



hookAdd("AirStrafe", "UpdateAir", function(ply, cur, wish, accel)
  ply:air_accel_speed(accel)
end)

local air_accel_tot = 0
local air_accel_samples = 0
local interval_tot = 0
local interval_samples = 0
local interval_lastkick = 0
local showinfo = true
hook.Add("WallKicked", "WJ_Interval", function(ply, time)

  interval_tot = interval_tot + (time - interval_lastkick)
  interval_samples = interval_samples + 1
  if interval_samples == 1 then
    interval_tot = 0
  end
  interval_lastkick = time
end)

function Various()
  if !showinfo then return end
  local ply = Spectate.IsSpectating(LocalPlayer()) or LocalPlayer()

  local tx, ty
  SetFont("HUD Info", {
    font = "Gidole",
    size = 15
  })
  draw_lib.Text("Info:", ScrW()-20, 0, 3, 2, -4)

  surface.SetTextColor( Color(255,255,255) )
  local rate = math.Round(1 / engine.TickInterval())
  draw_lib.Text("Mode: " .. MOVEMENT_MODES[ply:movement_mode()], ScrW()-20, 0, 3, 1, -5)
  draw_lib.Text("Tickrate: " .. rate, ScrW()-20, 0, 3, 1, -6)
  draw_lib.Text("ZVel: " .. math.Round(ply:SpeedZ()), ScrW()-20, 0, 3, 1, -7)
  draw_lib.Text("OnGround: " .. tostring(ply:OnGround()), ScrW()-20, 0, 3, 1, -8)
  draw_lib.Text("Air accel gain: " .. math.Round(ply:air_accel_speed()/10, 1), ScrW()-20, 0, 3, 1, -9)
  draw_lib.Text("Air accel gain avg: " .. math.Round(air_accel_tot/air_accel_samples,1), ScrW()-20, 0, 3, 1, -10)
  draw_lib.Text("WJ avg Interval ms: " .. math.Round(interval_tot/interval_samples,3)*1000, ScrW()-20, 0, 3, 1, -11)
  draw_lib.Text("Topspeed: " .. math.Round(ply:top_speed()[ply:movement_mode()]), ScrW()-20, 0, 3, 1, -12)
  if air_accel_tot != air_accel_tot+(ply:air_accel_speed()/10) then
    air_accel_samples = air_accel_samples+1
    air_accel_tot = air_accel_tot+(ply:air_accel_speed()/10)
  end
  draw_lib.Text("Gravity: " .. ply:gravity(), ScrW()-20, 0, 3, 1, -13)
  draw_lib.Text("Press C to hide.", ScrW()-20, 0, 3, 1, -14)
end
hook.Add("HUDPaint", "Informational", Various)



function GM:OnContextMenuOpen()
  showinfo = !showinfo
end



/*
-- Just for fun
local title = Material("openmove/UI/Special set/Sketch/emm.png", "noclamp")
local hp = Material("openmove/UI/Special set/Sketch/HPee.png", "noclamp")
local hp_bar = Material("openmove/UI/Special set/Sketch/HPee_bar.png", "noclamp")
local fast = Material("openmove/UI/Special set/Sketch/Fast.png", "noclamp")
local fast_bar = Material("openmove/UI/Special set/Sketch/Fast_bar.png", "noclamp")
local W = Material("openmove/UI/Special set/Sketch/Key_W.png", "noclamp")
local A = Material("openmove/UI/Special set/Sketch/Key_A.png", "noclamp")
local S = Material("openmove/UI/Special set/Sketch/Key_S.png", "noclamp")
local D = Material("openmove/UI/Special set/Sketch/Key_D.png", "noclamp")
local J = Material("openmove/UI/Special set/Sketch/Key_JUMP.png", "noclamp")
local DUCK = Material("openmove/UI/Special set/Sketch/Key_DUCK.png", "noclamp")
local M1 = Material("openmove/UI/Special set/Sketch/Key_M1.png", "noclamp")
local M2 = Material("openmove/UI/Special set/Sketch/Key_M2.png", "noclamp")
local W_pressed = Material("openmove/UI/Special set/Sketch/Key_W_pressed.png", "noclamp")
local A_pressed = Material("openmove/UI/Special set/Sketch/Key_A_pressed.png", "noclamp")
local S_pressed = Material("openmove/UI/Special set/Sketch/Key_S_pressed.png", "noclamp")
local D_pressed = Material("openmove/UI/Special set/Sketch/Key_D_pressed.png", "noclamp")
local J_pressed = Material("openmove/UI/Special set/Sketch/Key_JUMP_pressed.png", "noclamp")
local DUCK_pressed = Material("openmove/UI/Special set/Sketch/Key_DUCK_pressed.png", "noclamp")
local M1_pressed = Material("openmove/UI/Special set/Sketch/Key_M1_pressed.png", "noclamp")
local M2_pressed = Material("openmove/UI/Special set/Sketch/Key_M2_pressed.png", "noclamp")
function Meem()
  draw.NoTexture()
  surface.SetDrawColor(255,255,255)
  surface.SetMaterial( title )
  surface.DrawTexturedRect(0, 0, 256,128)

  surface.SetMaterial( hp )
  surface.DrawTexturedRect(25, ScrH()-128, 256,128)
  surface.SetMaterial( hp_bar )
  surface.DrawTexturedRectUV(25, ScrH()-128, LocalPlayer():Health()*(256/100),128, 0, 0, 1, 1)

  surface.SetMaterial( fast )
  surface.DrawTexturedRect(ScrW()-256-25, ScrH()-128, 256,128)
  surface.SetMaterial( fast_bar )
  surface.DrawTexturedRectUV(ScrW()-256-25, ScrH()-128, LocalPlayer():Speed()*(256/256),128, 0, 0, 1, 1)
  local size = 64
  if LocalPlayer():KeyDown(IN_ATTACK) then
    size = 128
    surface.SetMaterial( M1_pressed )
  else
    surface.SetMaterial( M1 )
    size = 64
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2 - 64, ScrH()-64 - 128, size,size)

  if LocalPlayer():KeyDown(IN_FORWARD) then
    size = 128
    surface.SetMaterial( W_pressed )
  else
    surface.SetMaterial( W )
    size = 64
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2, ScrH()-64 - 128, size,size)

  if LocalPlayer():KeyDown(IN_ATTACK2) then
    size = 128
    surface.SetMaterial( M2_pressed )
  else
    surface.SetMaterial( M2 )
    size = 64
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2 + 64, ScrH()-64 - 128, size,size)

  if LocalPlayer():KeyDown(IN_MOVELEFT) then
    size = 128
    surface.SetMaterial(A_pressed )
  else
    surface.SetMaterial( A )
    size = 64
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2 - 64, ScrH() - 128, size,size)

  if LocalPlayer():KeyDown(IN_BACK) then
    size = 128
    surface.SetMaterial( S_pressed )
  else
    surface.SetMaterial( S )
    size = 64
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2, ScrH() - 128, size,size)

  if LocalPlayer():KeyDown(IN_MOVERIGHT) then
    size = 128
    surface.SetMaterial( D_pressed )
  else
    surface.SetMaterial( D )
    size = 64
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2 + 64, ScrH() - 128, size,size)

  if LocalPlayer():KeyDown(IN_JUMP) then
    size = 128
    surface.SetMaterial( J_pressed )
  else
    surface.SetMaterial( J )
    size = 64
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2 - 64, ScrH() - 64, 64*2,size)

  if LocalPlayer():KeyDown(IN_DUCK) then
    surface.SetMaterial( DUCK_pressed )
  else
    surface.SetMaterial( DUCK )
  end
  surface.DrawTexturedRect(ScrW()/2 - 64/2 + 64, ScrH() - 64, size,size)
end
hook.Add("HUDPaint", "Meme", Meem)
*/
