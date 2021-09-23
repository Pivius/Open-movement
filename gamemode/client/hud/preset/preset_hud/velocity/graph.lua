/*
  Creator     - Pivius
  Preset      - velocity_default
  Description -
     Graph styled velocity HUD.
     Can choose to have outline, fill it and fade it.
     Sadly it's performance heavy beyond 500 samples.
  Benchmark in 1000 calls   -
    1000 Samples -
      Doing nothing - 3.78ms
      Moving        - 5.5ms
      Outline       - 3.67ms
      Fill          - 2.2ms
    500 Samples -
      Doing nothing - 1.76ms
      Moving        - 2.98ms
      Outline       - 2ms
      Fill          - 1.5ms
*/
local table = table
local table_insert = table.insert
local math = math
local min = math.min
local max = math.max
local global_vars = {}
local topspeed = 0
local vel_cache = {}

local vel_color = ut_col_pal.CAPRI
local vel_graph = {}
local vel_graph_samples = 300

-- Fill the table
for i=1, vel_graph_samples do
  table_insert(vel_graph, {vel = 0, length = 0})
end
local vel_graph_sample_length = 900
local graph_max = 1
local graph_min = 1

-- Changeable
local graph_outline = true
local graph_outline_color = ut_col_pal.CAPRI
local graph_outline_thickness = 2
local graph_fill = true
local graph_fill_color = ColorAlpha(ut_col_pal.CAPRI, 25)
local graph_fade = true
local graph_fade_rate = 100
--

local function GetHighest(tbl)
  local highest = 0
  local key = 1
  for _, v in ipairs(tbl) do
    if v.vel >= highest then
      highest = v.vel
      key = _
    end
  end
  return key
end

local function GetLowest(tbl)
  local lowest = math.huge
  local key = 1
  for _, v in ipairs(tbl) do
    if v.vel <= lowest then
      lowest = v.vel
      key = _
    end
  end
  return key
end

local function UpdateValues(vel, tbl)
  --if graph_max == graph_min and vel == 0 then return end
  if #tbl > 0 then
    /*
    if vel >= tbl[graph_max]["vel"] then
      graph_max = #tbl+1
    end
    if vel <= tbl[graph_min]["vel"] then
      graph_min = #tbl+1
    end
    */
    table_insert(tbl, {["vel"] = vel, length = CurTime()+vel_graph_sample_length})

    if #tbl > vel_graph_samples then
      table.remove(tbl, 1)
      /*
      if graph_max == 1 then
        graph_max = GetHighest(tbl)
      else
        graph_max = graph_max-1
      end

      if graph_min == 1 then
        graph_min = GetLowest(tbl)
      else
        graph_min = graph_min-1
      end*/
    end
  else

      table_insert(tbl, {["vel"] = vel, length = CurTime()+vel_graph_sample_length})

  end
end
local x, y, w, h = nil, nil, nil, nil
local function SpeedDisplay(ply, scrw, scrh, hud, cx, cy)
  if !x or !y or !w or !h then
    w, h     = 300, 120                      // Width and Height
    x, y     = scrw - 500, scrh - 300-120      // X and Y position
  end
  local localPly     = Spectate.IsSpectating(ply) or ply
  local vel          = localPly:Speed2D()
  local color        = ColorAlpha(vel_color, 255)
  local sample_width = w/vel_graph_samples
  local t            = table.Copy(vel_graph)
  local top          = localPly:top_speed()[ply:movement_mode()]
  if topspeed == 0 and top > 0 then
    topspeed = top
  end
  --draw_lib.DrawBox(x, y + (h / 2) - (h / 2), -w, h, Color(0, 0, 0, math.Clamp(color.a, 0, 100)))
  -- Border

  draw_lib.DrawBox(x, y-2, -w, 2, Color(0, 0, 0, math.Clamp(color.a, 0, 100)))
  draw_lib.DrawBox(x, y + (h) , -w, 2, Color(0, 0, 0, math.Clamp(color.a, 0, 100)))
  if #t > 1 then
    vel = ut_ease.Constant(0.25, vel_graph[#t]["vel"], vel)
  end
  UpdateValues(vel, t)
  vel_graph = t
  if !ut_ease.Approx(topspeed, top, 0.5) then
    topspeed = ut_ease.Constant(0.5, topspeed, top)

  end
  for i = 1, vel_graph_samples do
    local vel_height, last_vel_height, lowest_height = 0, 0, 0
    if vel_graph[i] then
      vel_height = min( vel_graph[i]["vel"], topspeed)*(h/max(topspeed, 100))
      --lowest_height = min(vel_graph[graph_min]["vel"], topspeed)*(h/max(topspeed, 100))
    end
    local new_x = x + (i * sample_width) - sample_width - w
    if graph_fill then
      local fade = graph_fill_color.a

      if graph_fade and (i <= graph_fade_rate || i >= vel_graph_samples - graph_fade_rate) then
        if i <= graph_fade_rate then
          fade = 0 + (((fade / graph_fade_rate)) * i)
        elseif i >= vel_graph_samples - graph_fade_rate then
          fade = fade - (((fade / graph_fade_rate)) * math.abs((vel_graph_samples - i) - graph_fade_rate))
        end
      end
      if vel_height != 0 then
        --if lowest_height <= vel_height then
          draw_lib.DrawBox(new_x, y - vel_height + h, max(w/vel_graph_samples, 1), vel_height , ColorAlpha(graph_fill_color, fade))
      end

    end
    -- Outline
    if graph_outline then
      if vel_graph[i-1] then
        last_vel_height = max(min(vel_graph[i-1]["vel"], topspeed)*(h/max(topspeed, 100)), 1)
      end
      vel_height = max(vel_height,1)
      local fade = graph_outline_color.a

      if graph_fade and (i <= graph_fade_rate || i >= vel_graph_samples - graph_fade_rate) then
        if i <= graph_fade_rate then
          fade = 0 + (((fade / graph_fade_rate)) * i)
        elseif i >= vel_graph_samples - graph_fade_rate then
          fade = fade - (((fade / graph_fade_rate)) * math.abs((vel_graph_samples - i) - graph_fade_rate))
        end
      end

      draw_lib.DrawBox(new_x, (y - (vel_height+ math.abs(last_vel_height - vel_height)) + h) - graph_outline_thickness, max(w/vel_graph_samples, 1), (graph_outline_thickness + math.abs(last_vel_height - vel_height)) , ColorAlpha(graph_outline_color, fade))
    end
  end


  //Text
  /*
  print(vel_graph[graph_max]["vel"])
  if math.Round(vel_graph[graph_max]["vel"]) == math.Round(top) then
    SetFont("HUD Vel", {
      font = "Trebuchet24",
      weight = 600,
      size = 30
    })
    surface.SetTextColor( ut_col_pal.WHITE )
    local velX, velY = surface.GetTextSize( math.Round( top ) )
    surface.Text(math.Round( top ), x + (graph_max * sample_width) - sample_width - w, y - (vel_graph[graph_max]["vel"]*(h/math.max(topspeed, 100))) + h, 2, 1, 0.9)
  end
  */
  SetFont("HUD Vel", {
    font = "Gidole",
    size = 30
  })
  surface.SetTextColor( color )
  local velX, velY = surface.GetTextSize( math.Round( localPly:Speed2D() ) )
  draw_lib.Text(math.Round( localPly:Speed2D() ), x , y - (vel_graph[#vel_graph]["vel"]*(h/math.max(topspeed, 100))) + h, 2, 1, 0.9)
end

presets.create("velocity_graph", SpeedDisplay)
