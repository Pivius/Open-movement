keyEnum = {}
// Relevant keys
keyEnum.keys = {
  ["W"] = IN_FORWARD,
  ["A"] = IN_MOVELEFT,
  ["S"] = IN_BACK,
  ["D"] = IN_MOVERIGHT,
  ["J"] = IN_JUMP,
  ["DUCK"] = IN_DUCK,
  ["M1"] = IN_ATTACK,
  ["M2"] = IN_ATTACK2,
  ["JUMP"] = IN_JUMP
}

hookAdd("Init_Player_Vars", "Init_keyenum", function(ply)
  local t = {
    ["W"] = false,
    ["A"] = false,
    ["S"] = false,
    ["D"] = false,
    ["J"] = false,
    ["DUCK"] = false,
    ["M1"] = false,
    ["M2"] = false,
    ["JUMP"] = false
  }
  ply:AddSettings("key_down", false)
end)

if SERVER then
  util.AddNetworkString( "KeyEnum_Net" )
  util.AddNetworkString( "KeyEnum_KeyDown" )
end

// Normal KeyDown
function keyEnum:KeyDown(ply, enum)
  if CLIENT then
    if ply == LocalPlayer() then
      return ply:KeyDown(enum)
    else
      return GetGlobalBool( (ply:UserID()).."_KeyDown_".. ut_tbl.GetByValue(keyEnum.keys, enum), false )
    end
  else
    return ply:KeyDown(enum)
  end
end
/*
-- Broken
function keyEnum:KeyWasDown(ply, enum)
  if CLIENT then
    if ply == LocalPlayer() then

      return ply:key_was_down()[enum]
    else
      return GetGlobalBool( tostring(ply).."_KeyWasDown_"..enum, false )
    end
  else
    return ply:key_was_down()[enum]
  end
end

function keyEnum:KeyPressed(ply, enum)
  if CLIENT then
    if ply == LocalPlayer() then

      return ply:key_pressed()[enum]
    else
      return GetGlobalBool( tostring(ply).."_KeyPressed_"..enum, false )
    end
  else
    return ply:key_pressed()[enum]
  end
end

function keyEnum:KeyReleased(ply, enum)
  if CLIENT then
    if ply == LocalPlayer() then
      return ply:key_released()[enum]
    else
      return GetGlobalBool( tostring(ply).."_KeyReleased_"..enum, false )
    end
  else
    return ply:key_released()[enum]
  end
end
*/
function keyEnum.KD(ply, key)
  if ply:IsValid() then
    if table.HasValue(keyEnum.keys, key) then
      SetGlobalBool( (ply:UserID()) .."_KeyDown_".. ut_tbl.GetByValue(keyEnum.keys, key), true )

    end
  end
end
hook.Add("KeyPress", "KeyDown", keyEnum.KD)

function keyEnum.KU(ply, key)
  if ply:IsValid() then
    if table.HasValue(keyEnum.keys, key) then
      SetGlobalBool( (ply:UserID()) .."_KeyDown_".. ut_tbl.GetByValue(keyEnum.keys, key), false )
    end
  end
end
hook.Add("KeyRelease", "KeyUp", keyEnum.KU)

function keyEnum.PlayerUpdate(ply, mv)
  if ply:IsValid() then
    for k, v in pairs(keyEnum.keys) do
      if mv:KeyDown(v) != GetGlobalBool( (ply:UserID()).."_KeyDown_".. v, false )   then
        SetGlobalBool( (ply:UserID()) .."_KeyDown_".. v, mv:KeyDown(v) )
      end
    end
  end
end
hook.Add("Move", "KeyDown", keyEnum.PlayerUpdate)
