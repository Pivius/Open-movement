/*
  Creator     - Pivius/Moose
  Preset      - health_chevron_1
  Description -
     Chevron styled HUD made by Moose and coded by Pivius.
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

local border = Material("openmove/UI/Bars/Chevron_bar_1/Metallic/border.png", "noclamp")
local border_edge = Material("openmove/UI/Bars/Chevron_bar_1/Metallic/border_edge.png", "noclamp")
local big_chevron = Material("openmove/UI/Bars/Chevron_bar_1/Metallic/big_chevron.png", "noclamp")
local chevron = Material("openmove/UI/Bars/Chevron_bar_1/Metallic/chevron.png", "noclamp")
local chevrons = {}
local function AddChevron(big)
  table.insert(chevrons, ease_module.new(1, {alpha = 255, color = {255, 255, 255, 0}}, {alpha = 255, color = {255, 255, 255}}, "linear"))
end
AddChevron()
AddChevron()
AddChevron()
AddChevron()
AddChevron()
AddChevron()
AddChevron()
AddChevron()
local main_chevron = ease_module.new(1, {alpha = 255, color = {255, 255, 255, 0}}, {alpha = 255, color = {255, 255, 255}}, "linear")
local function HealthDisplay(ply, scrw, scrh)

  local localPly = Spectate.IsSpectating(ply) or ply
  local x, y     = -scrw + 600, scrh - 400      // X and Y position
  local w, h     = 314, 80                      // Width and Height
  local hp       = math.Clamp(localPly:Health(), 0, 100)
  local alpha    = HP_ease:get().a
  local color    = ColorAlpha(health_color, alpha)
  local shade    = Color(base_color.r/1.5, base_color.g/1.5, base_color.b/1.5)
  local shadow    = Color(shade.r/1.5, shade.g/1.5, shade.b/1.5)
  local hp_width = hp*(w/100)
  local gap = 3
  local testcolor = util.Color.Copy(ut_col_pal.LIGHT_GREY)
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
  surface.SetDrawColor(base_color)
  surface.SetMaterial(border)
  surface.DrawTexturedRect( x, y , w, h )

  surface.SetMaterial(border_edge)
  surface.DrawTexturedRect( x -64/2, y , 64, h )

  surface.SetMaterial(border_edge)
  surface.DrawTexturedRectUV( x + w -64/2, y, 64, h, 0, 0, -1, 1 )

  local num_chevrons = #chevrons+1
  if (hp >= 0 && hp <= (100/num_chevrons)) then
    main_chevron:Duration(1)
    main_chevron:Target({alpha = math.max((100/num_chevrons)*255, 0)}, true)
  elseif (hp > 0 && hp > (100/num_chevrons)) && !(hp >= 0 && hp <= (100/num_chevrons)) then
    main_chevron:Duration((0.75/num_chevrons))
    main_chevron:Target({alpha = 255}, true)
  end
  main_chevron:update(1)
  surface.SetMaterial(big_chevron)
  surface.SetDrawColor(ColorAlpha(util.Color.TableToCol(main_chevron:get().color), main_chevron:get().alpha))
  surface.DrawTexturedRect( x - 64/2 - 15, y + (gap / 2), 128, h - gap )
  surface.SetMaterial(chevron)
  for i = 1, #chevrons do
    local min = (100/num_chevrons) * (i)
    local max = (100/num_chevrons) * (i+1)
    local dif = max - min
    local hp_min = (hp/num_chevrons) * (i)
    local hp_max = (hp/num_chevrons) * (i+1)
    local hp_dif = hp_max - hp_min
    if !util.Color.Equals(util.Color.TableToCol(chevrons[i]:get().color), util.Color.Lerp((1 / (num_chevrons + 1))*i, ut_col_pal.WHITE, health_color), 0) then
      local col = util.Color.Lerp((1 / (num_chevrons + 1))*i, ut_col_pal.WHITE, health_color):ToTable()
      chevrons[i]:Target({color = col}, true)
    end
    if (hp > min && hp <= max) then
      chevrons[i]:Duration(1)
      chevrons[i]:Target({alpha = math.max((hp_dif/dif)*255, 0)}, true)
      --print((hp_dif/dif))
    elseif (hp > max) && !(hp >= min && hp <= max) then
      chevrons[i]:Duration((0.75/num_chevrons) * i)
      chevrons[i]:Target({alpha = 255}, true)
    elseif hp < min && !(hp >= min && hp <= max) then
      chevrons[i]:Duration((0.75/i) )
      chevrons[i]:Target({alpha = 0}, true)
    end
    chevrons[i]:update(1)
    surface.SetDrawColor(ColorAlpha(util.Color.TableToCol(chevrons[i]:get().color), chevrons[i]:get().alpha))
    surface.DrawTexturedRect( (x + (64*i)/2 - 2)  + (gap*i), y + ((gap) / 2), 64, h - gap-1 )
  end

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

presets.create("health_chevron_1", HealthDisplay)
