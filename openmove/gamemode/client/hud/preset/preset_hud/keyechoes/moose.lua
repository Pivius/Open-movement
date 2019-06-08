/*
  Creator - Pivius/Moose
  Preset - keyboard_echoes
  Description -
     This displays key echoes as actual keyboard keys, when pressed they'll push down and turn into a different color.
  Benchmark in 1000 calls   -
    Doing nothing     - 0.39ms
    Holding 1 key     - 0.456ms
    Holding 5 keys    - 0.456ms
    Spamming all keys - 0.47ms
*/

local global_vars = {}
local key_color = ut_col_pal.LIGHT_GREY
local key_map_color = ut_col_pal.GREY
local dark = true
if dark then
  key_color = ut_col_pal.DARK_GREY
end
local ease_module = load.Module( "modules/ease.lua" )
local easing = {x = 0, y = 0, w = 0, h = 0, alpha = 0, r = key_color.r, g = key_color.g, b = key_color.b, txt_r = key_map_color.r, txt_g = key_map_color.g, txt_b = key_map_color.b}
local keys = {
  [1] = {key = "W", times_pressed = 0, enum = IN_FORWARD, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
  [2] = {key = "A", times_pressed = 0, enum = IN_MOVELEFT, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
  [3] = {key = "S", times_pressed = 0, enum = IN_BACK, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
  [4] = {key = "D", times_pressed = 0, enum = IN_MOVERIGHT, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
  [5] = {key = "␣", times_pressed = 0, enum = IN_JUMP, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
  [6] = {key = "CTRL", times_pressed = 0, enum = IN_DUCK, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
  [7] = {key = "M1", times_pressed = 0, enum = IN_ATTACK, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
  [8] = {key = "M2", times_pressed = 0, enum = IN_ATTACK2, down = false, ease = ease_module.new(1, table.Copy(easing), {}, "outExpo")},
}

local from = ut_col_pal.AZURE
local to = ut_col_pal.CRIMSON

local long_key = Material("openmove/UI/Key_echoes/Keyboard/V2/key_long.png", "noclamp")
local short_key = Material("openmove/UI/Key_echoes/Keyboard/V2/key_normal.png", "noclamp")
local key_map = Material("openmove/UI/Key_echoes/Keyboard/V2/key_map.png", "noclamp")
--local corner_key = Material("openmove/UI/key_small_corner.png", "noclamp")

local function KeyEcho_map(key , x, y, w, h, enum, key_col, txt_col)
  surface.SetDrawColor( key_col )
  if enum == IN_JUMP then
    surface.SetMaterial(long_key)
    surface.DrawTexturedRect( x, y - key.ease:get().y, w, h )
    surface.SetMaterial(key_map)
    surface.SetDrawColor( txt_col )
    local kp_x, kp_y = 2, 3
    surface.DrawTexturedRectUV( x + (w*0.25), y - 10 - key.ease:get().y, 100, 90, (1/4)*(kp_x-1), (1/4)*(kp_y-1), (1/4)*kp_x, (1/4)*kp_y )
  else
    surface.SetMaterial(short_key)
    surface.DrawTexturedRect( x, y - key.ease:get().y, w, h )
    surface.SetMaterial(key_map)
    surface.SetDrawColor( txt_col )
    local kp_x, kp_y = 1, 1
    if enum == IN_FORWARD then
      kp_x = 2
    elseif enum == IN_ATTACK2 then
      kp_x = 3
    elseif enum == IN_MOVELEFT then
      kp_y = 2
    elseif enum == IN_BACK then
      kp_x, kp_y = 2, 2
    elseif enum == IN_MOVERIGHT then
      kp_x, kp_y = 3, 2
    elseif enum == IN_DUCK then
      kp_x, kp_y = 1, 3
    end
    surface.DrawTexturedRectUV( x, y - 10 - key.ease:get().y, 100, 90, (1/4)*(kp_x-1), (1/4)*(kp_y-1), (1/4)*kp_x, (1/4)*kp_y )
  end
end

local function KeyDown(ply, key, enum, x, y, w, h, t, col, txtcol)
  local key_input = key.key
  local press_distance = 10
  SetFont("HUD Key_echoes", { font = "Trebuchet24", weight = 2, size = 35 })
  if keyEnum:KeyDown(ply, enum) && !key.down then
    key.ease:Target({["y"] = -press_distance, r = col.r, g = col.g, b = col.b, txt_r = txtcol.r, txt_g = txtcol.g, txt_b = txtcol.b}, true)
    key.down = true
    --key.times_pressed = key.times_pressed +1
  elseif !keyEnum:KeyDown(ply, enum) && key.down then
    key.ease:Target({["y"] = 0, r = key_color.r, g = key_color.g, b = key_color.b, txt_r = key_map_color.r, txt_g = key_map_color.g, txt_b = key_map_color.b}, true)
    key.down = false

  end

  key.ease:update(2)
  col = Color(key.ease:get().r, key.ease:get().g, key.ease:get().b, 255)
  txtcol = Color(key.ease:get().txt_r, key.ease:get().txt_g, key.ease:get().txt_b, 255)
  KeyEcho_map(key, x, y, w, h, enum, col, txtcol)


end

local function keyEchoes(ply, scrw, scrh, keyecho)
  global_vars = keyecho
  local localPly = Spectate.IsSpectating(ply) or ply
  local w_def, h_def     = 100, 90         // Width and Height
  local x_def, y_def     = -50, scrh/2      // X and Y position
  local alpha    = 200
  local color    = ColorAlpha(ut_col_pal.AZURE, alpha):Sub(Color(40,40,40))
  local echo_col = ColorAlpha(ut_col_pal.AZURE, alpha)
  local gap      = 1
  local dist     = 5
  //Easing
  local c

  // Draws the boxes

    local y = y_def - h_def - gap
    local x = x_def - w_def - gap
    local w = w_def
    local h = h_def
    y = y + (dist * 2)
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[7], keys[7].enum, x, y, w, h, t, echo_col, color)

    x, y = x_def, y_def
    w, h = w_def, h_def
    y = y - h - gap -- Move up
    x = x + w + gap -- Move right
    y = y + (dist * 2)
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[8], keys[8].enum, x, y, w, h, t, echo_col, color)

    x, y = x_def, y_def
    w, h = w_def, h_def
    y = y - h - gap -- Move up
    y = y + (dist * 2)
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[1], keys[1].enum, x, y, w, h, t, echo_col, color)

    x, y = x_def, y_def
    w, h = w_def, h_def
    y = y + dist
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[3], keys[3].enum, x, y, w, h, t, echo_col, color)

    x, y = x_def, y_def
    w, h = w_def, h_def
    x = x - w - gap -- Move left
    y = y + dist
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[2], keys[2].enum, x, y, w, h, t, echo_col, color)

    x, y = x_def, y_def
    w, h = w_def, h_def
    x = x + w + gap -- Move right
    y = y + dist
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[4], keys[4].enum, x, y, w, h, t, echo_col, color)


    x, y = x_def, y_def
    w, h = w_def, h_def
    x = x - w - gap -- Move left
    y = y + h + gap -- Move down
    w = w * 2+ gap
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[5], keys[5].enum, x, y, w, h, t, echo_col, color)

    x, y = x_def, y_def
    w, h = w_def, h_def
    x = x + w + gap -- Move Right
    y = y + h + gap -- Move down
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[6], keys[6].enum, x, y, w, h, t, echo_col, color)
end

presets.create("keyboard_echoes", keyEchoes)
