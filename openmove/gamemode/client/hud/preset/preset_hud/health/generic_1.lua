/*
  Creator     - Pivius/Moose
  Preset      - health_generic_1
  Description -
     A HUD style by moose.
     Goes in style with keyboard_echoes preset.
  Benchmark in 1000 calls   -
    Doing nothing -
    Healing       -
*/

local global_vars = {}
local health_color = Color(179, 27, 27)

local base_color = ut_col_pal.LIGHT_GREY
local dark = false
if dark then
  base_color = ut_col_pal.DARK_GREY
end
local ease_module = load.Module( "modules/ease.lua" )
local easing = {a = 0, w = 0, h = 0, x = 0, y = 0, hp_w = 0}

local HP_ease = ease_module.new(1, table.Copy(easing), table.Copy(easing), "linear")
local HP_fade_ease = ease_module.new(2, {hp_w = 0}, {hp_w = 0}, "inOutExpo")

local HP_bar = Material("openmove/UI/Bars/Standard_1/Bar.png", "noclamp")
local HP_bar_drain = Material("openmove/UI/Bars/Standard_1/Bar_inside.png", "noclamp")

local function HealthDisplay(ply, scrw, scrh)

  local localPly = Spectate.IsSpectating(ply) or ply
  local x, y     = -scrw + 600, scrh - 400      // X and Y position
  local w, h     = 300, 60                      // Width and Height
  local hp       = math.Clamp(localPly:Health(), 0, 100)
  local alpha    = HP_ease:get().a
  local color    = ColorAlpha(health_color, alpha)
  local shade    = Color(base_color.r/1.5, base_color.g/1.5, base_color.b/1.5)
  local shadow    = Color(shade.r/1.5, shade.g/1.5, shade.b/1.5)
  local hp_width = hp*(w/100)
  local gap = 2
  //Easing
  HP_ease:update(1)
  HP_ease:Target({["a"] = 255, ["w"] = w, ["h"] = h, ["x"] = x, ["y"] = y, ["hp_w"] = hp_width}, true)

  if HP_fade_ease:get().hp_w <= HP_ease:get().hp_w then
    HP_fade_ease:Target({["hp_w"] = hp_width}, true)
    HP_fade_ease:update(1)
  else
    HP_fade_ease:update(1)
    HP_fade_ease:Target({["hp_w"] = hp_width}, false)
  end

  // Draws the boxes
  surface.SetMaterial(HP_bar)
  surface.SetDrawColor(base_color)
  surface.DrawTexturedRectRotated( x, y + (h / 2), w, h, 0 )


  surface.SetMaterial(HP_bar_drain)
  surface.SetDrawColor(ColorAlpha(Color(179,120,27), math.Clamp(color.a , 0 ,255)))
  surface.DrawTexturedRectUV(x - w / 2, y,  math.Clamp(HP_fade_ease:get().hp_w, 0, w), h, 0, 0, HP_fade_ease:get().hp_w/w, 1 )
  surface.SetDrawColor(color)
  surface.DrawTexturedRectUV(x - w / 2, y,  math.Clamp(HP_ease:get().hp_w, 0, w), h, 0, 0, HP_ease:get().hp_w/w, 1 )
  draw.DrawBox(-scrw + 309, -scrh + 210, 2, 2, Color(255,255,255, 100))

  /*
  draw.DrawRoundedBox(x, y + (h / 2), w, h, ColorAlpha(base_color, math.max(alpha-10, 0)), 10, true, false, false, true)
  draw.DrawRoundedBox(x + gap, y + (h / 2) + gap, w - (gap * 2), h - (gap * 2), ColorAlpha(shadow, math.max(alpha-10, 0)), 10, true, false, false, true)
  draw.DrawRoundedBox(x + gap, y + (h / 2) + gap, math.Clamp(HP_fade_ease:get().hp_w - (gap * 2), -w + (gap * 2), w + (gap * 2)), h - (gap * 2), ColorAlpha(color, math.Clamp(color.a - 200, 0 ,255)), 10, true, false, false, true)
  draw.DrawRoundedBox(x + gap, y + (h / 2) + gap, math.Clamp(HP_ease:get().hp_w - (gap * 2), -w + (gap * 2), w + (gap * 2)), h - (gap * 2), color, 10, true, false, false, true)
  */
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

presets.create("health_generic_1", HealthDisplay)
