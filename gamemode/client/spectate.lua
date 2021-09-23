Spectate = {}
Spectate.Players = {}
hookAdd("Init_Player_Vars", "Init_Spectate", function(ply)
  ply:AddSettings("CanSpec", true)
end)


/*--------------------------------------------------------------------------
 NAME - autoCompleteConVar
 FUNCTION - AutoCompletes ConVar
--------------------------------------------------------------------------*/
local function autoCompleteConVar( cmd, args )
	local tbl = {}
	for _, ply in pairs( player.GetAll() ) do
    if string.find( string.lower( " " .. ply:Nick() ), string.lower(args) ) then
  	  table.insert( tbl, "spectate " .. ply:Nick() )
    end
	end

	return tbl
end

// Conditions
function Spectate.CanSpec(ply)
  if ply:OnGround() and ply:CanSpec() and ply:Alive() then
    return true
  end
  return false
end

// Conditions
function Spectate.IsSpectating(ply)
  if ply:GetObserverTarget() != NULL then
    return ply:GetObserverTarget()
	else
  end
  return false
end

function Spectate.Command(ply, cmd, args)
  local varargs = args
  local target = table.remove(varargs, 1)
  if !target then
    chat.AddText( Color(255,50,50), "Couldn't find a target!" )
    return
  end
  target = ut_ply.GetByNick(target)
  if target == LocalPlayer() then
    chat.AddText( Color(255,50,50), "You cannot spectate yourself!" )
    return
  elseif target == NULL then
    chat.AddText( Color(255,50,50), "Couldn't find a target!" )
    return
  elseif !Spectate.CanSpec(ply) then
    chat.AddText( Color(255,50,50), "Can't spectate right now!" )
    return
  end
  net.Start("Spectate")
    net.WriteEntity(ply)
    net.WriteEntity(target)
  net.SendToServer()
  --chat.AddText( Color(50,50,255), "Spectating " .. target:Nick() )
end

concommand.Add("spectate", Spectate.Command, autoCompleteConVar, nil, FCVAR_USERINFO)

net.Receive("Spectate", function()
    local Type = net.ReadString( )

		if Type == "Sync" then
    	local table = net.ReadTable()
			Spectate.Players = table
		end
end)

function Spectate.KillRestrict(ply, bind, pressed)
	if Spectate.IsSpectating(ply) then
		if ( string.find( bind, "kill" ) ) then return true end
	end
end
hook.Add("PlayerBindPress", "Restrict kill command", Spectate.KillRestrict)
