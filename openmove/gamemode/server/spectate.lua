Spectate = {}
Spectate.Players = {}

Spectate.keys = {
  ["W"] = IN_FORWARD,
  ["A"] = IN_MOVELEFT,
  ["S"] = IN_BACK,
  ["D"] = IN_MOVERIGHT,
  ["J"] = IN_JUMP,
  ["DUCK"] = IN_DUCK,
  ["M1"] = IN_ATTACK,
  ["M2"] = IN_ATTACK2
}

util.AddNetworkString( "Spectate" )
// Lua refresh
for k, v in pairs(player.GetAll()) do
  if !Spectate.Players[v] then continue end
  Spectate.EndSpec(v)
end

function Spectate.AddPlayer(ply)
  if !Spectate.Players[ply] then
    if ply:IsValid() then
      local t = {
        [ply] = {
          ["Spectators"] = {},
          ["Spectating"] = false,
          ["AllowSpec"] = true,
          ["Incognito"] = false,
          ["Storage"] = {
            ["Pos"] = Vector(),
            ["Angle"] = Angle()
          }
        }
      }
      table.Merge(Spectate.Players, t)
    end
  end
end

function Spectate.RemovePlayer(ply)
  if Spectate.Players[ply] then
    Spectate.Players[ply] = nil
  end
  net.Start( "Spectate" )
  	net.WriteString( "Sync" )
    net.WriteTable(Spectate.Players)
  net.Broadcast()
end

function Spectate.CanSpec(ply)
  if Spectate.Players[ply]["Spectating"] or !Spectate.Players[ply]["AllowSpec"] or Spectate.Players[ply]["Incognito"] or !ply:Alive() then
    return false
  end
  return true
end

function Spectate.StartSpec(ply, target)
  //Make sure there is a table for target and caller
  Spectate.AddPlayer(target)
  Spectate.AddPlayer(ply)
  if Spectate.Players[target]["Spectating"] and !Spectate.Players[target]["Incognito"] then
    chat.Text(ply, Color(255,255,255), target:Nick() .. " is spectating someone!")
    return
  end
  if Spectate.CanSpec(target) then

    if !Spectate.Players[ply]["Spectating"] then
      Spectate.Players[ply]["Storage"]["Pos"] = ply:GetPos()
      Spectate.Players[ply]["Storage"]["Angle"] = ply:EyeAngles()
    else
      table.RemoveByValue(Spectate.Players[ply:GetObserverTarget()]["Spectators"], ply)
    end
    if !Spectate.Players[ply]["Incognito"] then
      table.insert(Spectate.Players[target]["Spectators"], ply)
    end
    ply:SetMoveType( 0 )
    ply:Spectate(OBS_MODE_IN_EYE)
    ply:SpectateEntity( target )
    Spectate.Players[ply]["Spectating"] = target
    net.Start( "Spectate" )
      net.WriteString( "Sync" )
      net.WriteTable(Spectate.Players)
    net.Broadcast()
    chat.Text(ply, Color(50,50,255), "Spectating " .. target:Nick())
  elseif !Spectate.Players[target]["AllowSpec"] or Spectate.Players[target]["Incognito"] then
    chat.Text(ply, Color(255,50,50), "You can't spectate " .. target:Nick() .. "!")
  end
end

function Spectate.Browse(ply, prev, nxt, index)

  Spectate.AddPlayer(ply)
  if ply:IsValid() and Spectate.Players[ply]["Spectating"] then
    local prevTarget = ply:GetObserverTarget()
    if !index then
      index = prevTarget:EntIndex()
    end
    local nextIndex = index

    if prev then
      nextIndex = index-1
      if nextIndex < 1 then
        nextIndex = player.GetCount()
      end
    elseif nxt then
      nextIndex = index+1
      if nextIndex > player.GetCount() then
        nextIndex = 1
      end
    else
      return
    end

    for k, v in pairs(player.GetAll()) do
      if nextIndex == k then
        if Spectate.CanSpec(v) and k != ply:EntIndex() then
            Spectate.AddPlayer(v)
            if !Spectate.Players[ply]["Incognito"] then
              table.RemoveByValue(Spectate.Players[prevTarget]["Spectators"], ply)
              table.insert(Spectate.Players[v]["Spectators"], ply)
            end
            ply:SetMoveType( 0 )
            ply:Spectate(OBS_MODE_IN_EYE)
            ply:SpectateEntity( v )

            net.Start( "Spectate" )
            	net.WriteString( "Sync" )
              net.WriteTable(Spectate.Players)
            net.Broadcast()
            chat.Text(ply, Color(50,50,255), "Spectating " .. v:Nick())
          else
            Spectate.Browse(ply, prev, nxt, nextIndex)
          end
        end
      end
  end
end

local function BrowseSpectate(ply, key)
  Spectate.AddPlayer(ply)
  if !Spectate.Players[ply]["Spectating"] then
    return
  end
  Spectate.Browse(ply, key == IN_ATTACK2, key == IN_ATTACK)
end

hook.Add("KeyPress", "BrowseSpectate", BrowseSpectate)

function Spectate.EndSpec(ply)
  local target = ply:GetObserverTarget()
  Spectate.AddPlayer(target)
  Spectate.AddPlayer(ply)
  if !Spectate.Players[ply]["Incognito"] then
    table.RemoveByValue(Spectate.Players[target]["Spectators"], ply)
  end
  Spectate.Players[ply]["Spectating"] = false

  ply:Spectate(0)
  ply:UnSpectate()
  ply:SetMoveType(2)
  ply:Spawn()
  ply:SetEyeAngles(Spectate.Players[ply]["Storage"]["Angle"])

  ply:SetPos(Spectate.Players[ply]["Storage"]["Pos"])
  net.Start( "Spectate" )
    net.WriteString( "Sync" )
    net.WriteTable(Spectate.Players)
  net.Broadcast()
end

local function EndSpectate(ply, mv, cmd)
  Spectate.AddPlayer(ply)
  if !Spectate.Players[ply]["Spectating"] then
    return
  end

	mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_ATTACK ) ) )
  mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_ATTACK2 ) ) )
  for k, v in pairs(Spectate.keys) do
    if mv:KeyDown(v) || !IsValid(Spectate.Players[ply]["Spectating"]) then
      Spectate.EndSpec(ply)
      mv:SetVelocity(Vector(0,0,0))
      mv:SetOrigin(Spectate.Players[ply]["Storage"]["Pos"])
    end
  end
end

hook.Add("Move", "EndSpectate", EndSpectate)

net.Receive("Spectate", function()
  local ply = net.ReadEntity()
  local target = net.ReadEntity()
  Spectate.StartSpec(ply, target)
end)
