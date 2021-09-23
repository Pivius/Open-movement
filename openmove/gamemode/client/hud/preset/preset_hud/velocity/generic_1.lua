/*
  Creator     - Pivius/Moose
  Preset      - vel_generic_1
  Description -
     A HUD style by moose.
     Goes in style with keyboard_echoes preset.
  Benchmark in 1000 calls   -
    Doing nothing -
    Healing       -
*/

local global_vars = {}
local vel_color = ut_col_pal.CAPRI
local base_color = ut_col_pal.LIGHT_GREY
local dark = false
if dark then
  base_color = ut_col_pal.DARK_GREY
end
local ease_module = load.Module( "modules/ease.lua" )
local easing = {a = 0, w = 0, h = 0, x = 0, y = 0, vel_w = 0}
local VEL_ease = ease_module.new(1, table.Copy(easing), table.Copy(easing), "outCubic")
local VEL_fade_ease = ease_module.new(1, {vel_w = 0}, {vel_w = 0}, "outCubic")
local VEL_bar = Material("openmove/UI/HP/Health_Bar.png", "noclamp")
local VEL_bar_drain = Material("openmove/UI/HP/Health_Bar_drain.png", "noclamp")
local function SpeedDisplay(ply, scrw, scrh, self)

  local localPly = Spectate.IsSpectating(ply) or ply
  local w, h     = 300, 5                      // Width and Height
  local x, y     = scrw - 500, scrh - 300      // X and Y position
  local vel      = localPly:Speed2D()
  local alpha    = VEL_ease:get().a
  local color    = ColorAlpha(vel_color, alpha)
  local shade    = Color(base_color.r/1.5, base_color.g/1.5, base_color.b/1.5)
  local shadow    = Color(shade.r/1.5, shade.g/1.5, shade.b/1.5)
  local vel_width = vel*(w/math.max(localPly:top_speed()[ply:movement_mode()], 100))
  local gap = 2
  //Easing
  VEL_ease:update(2)
  VEL_ease:Target({["a"] = 255, ["w"] = w, ["h"] = h, ["x"] = x, ["y"] = y, ["vel_w"] = vel_width})
  if VEL_fade_ease:get().vel_w <= VEL_ease:get().vel_w then
    VEL_fade_ease:get().vel_w = VEL_ease:get().vel_w
    VEL_fade_ease:update(1)
  end
  VEL_fade_ease:Target({["vel_w"] = vel_width})
  // Draws the boxes
  draw.DrawRoundedBox(x, y + (h / 2), -w, 1, ColorAlpha(base_color, math.max(alpha-10, 0)), 0, true, false, false, true)
  --draw.DrawRoundedBox(x + gap, y + (h / 2) + gap, w - (gap * 2), h - (gap * 2), ColorAlpha(shadow, math.max(alpha-10, 0)), 10, true, false, false, true)
  --draw.DrawRoundedBox(x + gap, y + (h / 2) + gap, -math.Clamp(VEL_fade_ease:get().vel_w + (gap * 2), 0, w + (gap * 2)), h - (gap * 2), ColorAlpha(color, math.Clamp(color.a - 200, 0 ,255)), 10, true, false, false, true)
  --draw.DrawRoundedBox(x + gap, y + (h / 2) + gap, -math.Clamp(VEL_ease:get().vel_w + (gap * 2), 0, w + (gap * 2)), h - (gap * 2), color, 10, true, false, false, true)
  /*
  //Text
  SetFont("HUD Health", {
    font = "Trebuchet24",
    weight = 600,
    size = 50
  })
  surface.SetTextColor( color )
  local hpX, hpY = surface.GetTextSize( math.Round( hp ) )
  draw.Text(math.Round( hp ), math.Clamp(x + (w / 2), -9999, hpX), y - 10, 2, 1, 0.9)
  */
end

presets.create("vel_generic_1", SpeedDisplay)
