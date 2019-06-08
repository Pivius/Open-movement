/*
  Creator     - Pivius
  Preset      - circle_1
  Description -
     Just a simple key echo display that shows the keys only when it's necessary.
     You can still see the letters turned slightly invisible, but when you hold down a key you'll see a bubble pop up.
  Benchmark in 1000 calls   -
    Doing nothing     - 0.14ms
    Holding 1 key     - 0.29ms
    Holding 5 keys    - 0.64ms
    Spamming all keys - 1ms
*/

local global_vars = {}
local key_color = ut_col_pal.WHITE
local dark = false
if dark then
  key_color = ut_col_pal.DARK_GREY
end
local ease_module = load.Module( "modules/ease.lua" )
local easing = {x = 0, y = 0, w = 0, h = 0, alpha = 0, r = key_color.r, g = key_color.g, b = key_color.b}
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
local circle_tex = Material("openmove/shapes/circles/circle_128.png", "noclamp")
local function KeyDown(ply, key, enum, x, y, w, h, t, col, txtcol)
  local key_input = key.key
  SetFont("HUD Key_echoes", { font = "Gidole", weight = 2, size = 40 })
  if keyEnum:KeyDown(ply, enum) && !key.down then
    key.ease:Target({["w"] = (math.max(w,h)), alpha = 225, r = col.r, g = col.g, b = col.b}, true)
    key.down = true
    key.times_pressed = key.times_pressed +1
  elseif !keyEnum:KeyDown(ply, enum) && key.down then
    key.ease:Target({["w"] = 0, alpha = 0, r = key_color.r, g = key_color.g, b = key_color.b}, true)
    key.down = false
  end

  surface.SetDrawColor(0,0,0,1)
  key.ease:update(2)

  if !ut_ease.Approx(key.ease:get().alpha, 0, 2) then
    local color = ColorAlpha(ut_col.Pack(key.ease:get().r, key.ease:get().g, key.ease:get().b),  math.max(key.ease:get().alpha, 0))
    surface.SetDrawColor(color)
    surface.SetMaterial( circle_tex )
    surface.DrawTexturedRect(x + (math.max(w,h)/2) - (key.ease:get().w/2), y + (math.max(w,h)/2) - (key.ease:get().w/2), key.ease:get().w, key.ease:get().w)
  end
  surface.SetTextColor( ColorAlpha(txtcol,  math.max(key.ease:get().alpha, 20) ))

  draw_lib.Text(key_input, x + w / 2, y + (h / 2), 2, 1, 0.5)
  --render.SetStencilEnable( false )
end

local function keyEchoes(ply, scrw, scrh, keyecho, cx, cy)
  global_vars        = keyecho
  local localPly     = Spectate.IsSpectating(ply) or ply
  local w, h         = 100, 100         // Width and Height
  local def_x, def_y = -50, scrh/2       // X and Y position
  local x, y         = def_x, def_y
  local alpha        = 200
  local color        = ColorAlpha(ut_col_pal.WHITE, alpha)
  local echo_col     = ColorAlpha(ut_col_pal.AZURE, 100)
  local gap          = 2
  local t            = 5
  //Easing
  --

  // Draws the boxes
    //M1
    y = y - h - gap
    x = x - w - gap
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[7], keys[7].enum, x, y, w, h, t, echo_col, color)

    //M2
    x, y = def_x, def_y -- Clearing
    w, h = 100, 100 -- Clearing
    y = y - h - gap -- Move up
    x = x + w + gap -- Move right
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[8], keys[8].enum, x, y, w, h, t, echo_col, color)

    // W
    x, y = def_x, def_y -- Clearing
    w, h = 100, 100 -- Clearing
    y = y - h - gap -- Move up
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[1], keys[1].enum, x, y, w, h, t, echo_col, color)

    //A
    x, y = def_x, def_y -- Clearing
    w, h = 100, 100 -- Clearing

    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[3], keys[3].enum, x, y, w, h, t, echo_col, color)

    //S
    x, y = def_x, def_y -- Clearing
    w, h = 100, 100 -- Clearing
    x = x - w - gap -- Move left
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[2], keys[2].enum, x, y, w, h, t, echo_col, color)

    //D
    x, y = def_x, def_y -- Clearing
    w, h = 100, 100 -- Clearing
    x = x + w + gap -- Move right
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[4], keys[4].enum, x, y, w, h, t, echo_col, color)

    //JUMP
    x, y = def_x, def_y -- Clearing
    w, h = 100, 100 -- Clearing
    x = x - (w/2) - gap -- Move left
    y = y + h + gap -- Move down
    --w = w * 2+ gap
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[5], keys[5].enum, x, y, w, h, t, echo_col, color)

    //DUCK
    x, y = def_x, def_y -- Clearing
    w, h = 100, 100 -- Clearing
    x = x + w + gap -- Move Right
    y = y + h + gap -- Move down
    --draw.DrawBox(x, y, w, h, Color(0,0,0,alpha))
    KeyDown(localPly, keys[6], keys[6].enum, x, y, w, h, t, echo_col, color)
end

presets.create("circle_1", keyEchoes)
