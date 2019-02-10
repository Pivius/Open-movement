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

function TopTitle()
  SetFont("HUD 1", {
    font = "Trebuchet24",
    size = 25
  })
  surface.SetTextColor( Color(255,255,255) )
  local tx, ty = surface.GetTextSize( "Walljump gamemode 23.641623% done!" )
  surface.SetTextPos( ScrW() - tx - 25, ty)
  surface.DrawText( "Walljump gamemode 23.641623% done!" )
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
  surface.SetTextPos( 10, (ScrH()/2) - ty)
  surface.DrawText( "Vel: " .. vel )
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
  local tx, ty = surface.GetTextSize( vel )
  surface.SetTextPos( ScrW()/2, (ScrH()/2) + ty)
  surface.DrawText( vel )
end
hook.Add("HUDPaint", "CrosshairSpeed", CrosshairSpeed)

function HP()
  SetFont("HUD 1", {
    font = "Trebuchet24",
    size = 25
  })
  surface.SetTextColor( Color(255,255,255) )
  local hp = LocalPlayer():Health()
  local tx, ty = surface.GetTextSize( "HP: " .. hp )
  surface.SetTextPos( 10, (ScrH()/2) - ty*2)
  surface.DrawText( "HP: " .. hp )
end
hook.Add("HUDPaint", "HP", HP)
