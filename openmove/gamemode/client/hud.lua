/*
  Ugly hud with only the essentials.
*/

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

local function DrawText(text, x, y, align, xstep, ystep)
  local tx_original, ty_original = surface.GetTextSize( text )
  if !xstep then xstep = 1 end
  if !ystep then ystep = 1 end
  local tx = tx_original*xstep
  local ty = ty_original*ystep
  if !align or align == 1 then -- Left
    if ystep != 0 then
      y = y - ty
    end
    if xstep != 0 then
      x = x - ty
    end
    surface.SetTextPos( x, y )
  elseif align == 2 then -- cemter
    tx = math.max( tx, tx_original)
    if ystep != 1 then
      surface.SetTextPos( x - tx / 2, y - ty )
    else
      surface.SetTextPos( x - tx / 2, y )
    end
  else -- Right
    surface.SetTextPos( x - tx, y - ty)
  end
  surface.DrawText( text )
end

function TopTitle()
  SetFont("HUD 1", {
    font = "Trebuchet24",
    size = 25
  })
  surface.SetTextColor( Color(255,255,255) )

  DrawText(LocalPlayer():Name(), ScrW()  - 25, 0, 3, 1, -1)
end
hook.Add("HUDPaint", "TopTitle", TopTitle)

function Speed()
  SetFont("HUD 1", {
    font = "Trebuchet24",
    size = 25
  })
  surface.SetTextColor( Color(255,255,255) )
  local vel = math.Round(LocalPlayer():GetVelocity():Length2D()/10)
  local tx, ty = surface.GetTextSize( "Vel: " .. vel )

  DrawText("Vel: " .. vel, 10, (ScrH()/2), 1, 0, 1)
end
hook.Add("HUDPaint", "Speed", Speed)

function CrosshairSpeed()
  SetFont("HUD 2", {
    font = "Trebuchet24",
    size = 15,
    weight = 700
  })
  surface.SetTextColor( Color(255,255,255) )
  local vel = math.Round((LocalPlayer():GetVelocity():Length2D()/100))*10

  DrawText(vel, ScrW()/2 + 4, (ScrH()/2), 2, 0, -1)
end
hook.Add("HUDPaint", "CrosshairSpeed", CrosshairSpeed)

function HP()
  SetFont("HUD 1", {
    font = "Trebuchet24",
    size = 25
  })
  surface.SetTextColor( Color(255,255,255) )
  local hp = LocalPlayer():Health()
  DrawText("HP: " .. hp, 10, (ScrH()/2), 1, 0, 2)
end

hook.Add("HUDPaint", "HP", HP)

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
  local ply = LocalPlayer()
  local tx, ty
  SetFont("HUD Info", {
    font = "Trebuchet24",
    size = 15
  })
  DrawText("Info:", ScrW()-20, 0, 3, 2, -4)

  surface.SetTextColor( Color(255,255,255) )
  local rate = math.Round(1 / engine.TickInterval())
  DrawText("Mode: " .. MOVEMENT_MODES[ply:movement_mode()], ScrW()-20, 0, 3, 1, -5)
  DrawText("Tickrate: " .. rate, ScrW()-20, 0, 3, 1, -6)
  DrawText("ZVel: " .. math.Round(ply:SpeedZ()), ScrW()-20, 0, 3, 1, -7)
  DrawText("OnGround: " .. tostring(ply:OnGround()), ScrW()-20, 0, 3, 1, -8)
  DrawText("Air accel gain: " .. math.Round(ply:air_accel_speed()/10, 1), ScrW()-20, 0, 3, 1, -9)
  DrawText("Air accel gain avg: " .. math.Round(air_accel_tot/air_accel_samples,1), ScrW()-20, 0, 3, 1, -10)
  DrawText("WJ avg Interval ms: " .. math.Round(interval_tot/interval_samples,3)*1000, ScrW()-20, 0, 3, 1, -11)
  DrawText("Topspeed: " .. math.Round(ply:top_speed()), ScrW()-20, 0, 3, 1, -12)
  if air_accel_tot != air_accel_tot+(ply:air_accel_speed()/10) then
    air_accel_samples = air_accel_samples+1
    air_accel_tot = air_accel_tot+(ply:air_accel_speed()/10)
  end
  DrawText("Press C to hide.", ScrW()-20, 0, 3, 1, -13)
end
hook.Add("HUDPaint", "Informational", Various)

function GM:OnContextMenuOpen()
  showinfo = !showinfo
end
