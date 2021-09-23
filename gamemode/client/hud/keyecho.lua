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
  presets.load("keyboard_echoes", ply, scrw, scrh, self, cx, cy)
end
