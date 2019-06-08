local keyecho = {}
keyecho.HUD_CACHE = {}


function keyecho.Init()
  local ls = math.Clamp(GetConVar( "hud_lag_sensitivity" ):GetFloat(),1,30)
  --Speedometer

  if keyecho.HUD_CACHE["HUD_KE"] then
    HUD_KE:Remove()
    keyecho.HUD_CACHE["HUD_KE"] = nil
  end
  HUD_KE = hudmod.CreatePanel( nil, ls / 4, 40 / ( ( ls / 4 ) / 2 ) )

  keyecho.HUD_CACHE["HUD_KE"] = HUD_KE
end
keyecho.Init()



local a = 0 //avg
local s = 0 //samples
local calls = 1000 //calls
local benchmark = false
function HUD_KE:Draw3D(ply, scrw, scrh, cx, cy)
  if s <= calls && benchmark then
    bench.Push()
  end
  presets.load("circle_1", ply, scrw, scrh, keyecho, cx, cy)
  if s <= calls && benchmark then
    a = a + bench.Pop()
    s = s+1
    print(s)
  end
  if s >= calls && benchmark then
    print(a/s)
  end
end
