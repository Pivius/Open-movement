/*
  Creator     - Pivius
  Preset      - velocity_default
  Description -
     Default HUD for speed display.
     Style is similar to that of EMM or AOP
  Benchmark in 1500 calls   -
    Doing nothing - 0.0961ms
    Moving        - 0.108ms
*/

local global_vars = {}
local vel_color = ut_col_pal.CAPRI

local ease_module = load.Module( "modules/ease.lua" )
local easing = {a = 0, w = 0, h = 0, x = 0, y = 0, vel_w = 0}
local VEL_ease = ease_module.new(1, table.Copy(easing), table.Copy(easing), "outCubic")
local VEL_fade_ease = ease_module.new(1, {vel_w = 0}, {vel_w = 0}, "outCubic")

local function SpeedDisplay(ply, scrw, scrh)
  local localPly = Spectate.IsSpectating(ply) or ply
  local w, h     = 300, 5                      // Width and Height
  local x, y     = scrw - 500, scrh - 300      // X and Y position
  local vel      = localPly:Speed2D()
  local alpha    = VEL_ease:get().a
  local color    = ColorAlpha(vel_color, alpha)
  local vel_width = vel*(w/math.max(localPly:top_speed()[ply:movement_mode()], 100))
  //Easing
  VEL_ease:update(2)
  VEL_ease:Target({["a"] = 255, ["w"] = w, ["h"] = h, ["x"] = x, ["y"] = y, ["vel_w"] = vel_width})
  if VEL_fade_ease:get().vel_w <= VEL_ease:get().vel_w then
    VEL_fade_ease:get().vel_w = VEL_ease:get().vel_w
  else
    VEL_fade_ease:update(1)
  end
  VEL_fade_ease:Target({["vel_w"] = vel_width})
  // Draws the boxes
  draw.DrawBox(x, y + (h / 2) - (h / 2), -w, h, Color(0, 0, 0, math.Clamp(alpha, 0, 100)))
  draw.DrawBox(x, y + (h / 2) - (h / 2), -math.Clamp(VEL_fade_ease:get().vel_w, -w, w), h, ColorAlpha(color, math.Clamp(color.a-200, 0 ,255)))
  draw.DrawBox(x, y + (h / 2) - (h / 2), -math.Clamp(VEL_ease:get().vel_w, -w, w), h, color)

  //Text
  SetFont("HUD Vel", {
    font = "Trebuchet24",
    weight = 600,
    size = 50
  })
  surface.SetTextColor( color )
  local velX, velY = surface.GetTextSize( math.Round( vel ) )
  draw.Text(math.Round( vel ), x + (-w / 2), y - 10, 2, 1, 0.9)
end

presets.create("velocity_default", SpeedDisplay)
