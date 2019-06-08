/*
  Creator     - Pivius
  Preset      - health_default
  Description -
     Default HUD for health display.
     Style is similar to that of EMM or AOP
  Benchmark in 1000 calls   -
    Doing nothing - 0.119ms
    Healing       - 0.132ms
*/

local global_vars = {}
local health_color = ut_col_pal.CADMIUM_RED

local ease_module = load.Module( "modules/ease.lua" )
local easing = {a = 0, w = 0, h = 0, x = 0, y = 0, hp_w = 0}

local HP_ease = ease_module.new(1, table.Copy(easing), table.Copy(easing), "outCubic")
local HP_fade_ease = ease_module.new(1, {hp_w = 0}, {hp_w = 0}, "outCubic")

local function HealthDisplay(ply, scrw, scrh)

  local localPly = Spectate.IsSpectating(ply) or ply
  local x, y     = -scrw + 500, scrh - 300      // X and Y position
  local w, h     = 300, 5                      // Width and Height
  local hp       = math.Clamp(localPly:Health(), 0, 100)
  local alpha    = HP_ease:get().a
  local color    = ColorAlpha(health_color, alpha)
  local hp_width = hp*(w/100)
  //Easing
  HP_ease:update(1)
  HP_ease:Target({["a"] = 255, ["w"] = w, ["h"] = h, ["x"] = x, ["y"] = y, ["hp_w"] = hp_width}, true)
  if HP_fade_ease:get().hp_w <= HP_ease:get().hp_w then
    HP_fade_ease:get().hp_w = HP_ease:get().hp_w
  else
    HP_fade_ease:update(0.25)
  end
  HP_fade_ease:Target({["hp_w"] = hp_width}, true)
  // Draws the boxes
  draw_lib.DrawBox(x, y + (h / 2) - (h / 2), w, h, Color(0, 0, 0, math.Clamp(alpha, 0, 100)))
  draw_lib.DrawBox(x, y + (h / 2) - (h / 2), math.Clamp(HP_fade_ease:get().hp_w, -w, w), h, ColorAlpha(color, math.Clamp(color.a - 200, 0 ,255)))
  draw_lib.DrawBox(x, y + (h / 2) - (h / 2), math.Clamp(HP_ease:get().hp_w, -w, w), h, color)

  //Text
  SetFont("HUD Health", {
    font = "Gidole",

    size = 50
  })
  surface.SetTextColor( color )
  local hpX, hpY = surface.GetTextSize( math.Round( hp ) )
  draw_lib.Text(math.Round( hp ), math.Clamp(x + (w / 2), -9999, hpX), y - 10, 2, 1, 0.9)
end

presets.create("health_default", HealthDisplay)
