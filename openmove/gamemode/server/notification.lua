Notifications = {}
util.AddNetworkString( "Network msg" )
util.AddNetworkString( "Notify" )
Notifications = {
  ["Unidentified ID"] = "[Notifications] Could not find |1|\n",
  ["Created Item"] = "[Notifications] Created Item |1|\n",

  ["Admin Success Command"] = "You have successfully executed |1|\n",
  ["Admin Error Command"] = "Failed to execute |1|\n",
  ["Admin In Perm"] = "Insufficient permissions\n"
}

function Notifications:Get( id, args )
	if !Notifications[id] then
		args = { id }
		id = "Unidentified ID"
	end
	if !args || !type( args ) == "table" then
		args = {}
	end
	local Text = Notifications[id]
	for ID, arg in pairs( args ) do

		Text = string.gsub( Text, "|" .. ID .. "|", arg )
	end
	return Text
end

chat = {}
function chat.Text(...)
  local args = { ... }
  local ply = table.remove( args, 1 )
  local rf = RecipientFilter()
  if ply == "root" then
    MsgC( unpack(args) )
    MsgC( "\n" )
    return
  end
  if ply then

    if type(ply) == "Player" then
      rf:AddPlayer(ply)
    elseif type(ply) == "table" then
      for k, v in pairs(ply) do
        if v then
          rf:AddPlayer(v)
        end
      end
    end
  else
      rf:AddAllPlayers()
  end
  net.Start("Network msg")
    net.WriteDouble(#args)
    for k, v in pairs(args) do
      net.WriteType(v)
    end
  net.Send(rf)
  hook.Call( "OnMsgSent", nil, rf, args )
end

function notifyPly(who, msg, Type, time, col)
  local rf = RecipientFilter()
  if who then
    if istable(who) then
      for k, v in pairs(who) do
        if type(k) == "Player" then
          rf:AddPlayer(k)
        elseif type(v) == "Player" then
          rf:AddPlayer(v)
        end
      end
    else
      rf:AddPlayer(who)
    end
  else
      rf:AddAllPlayers()
  end
  net.Start("Notify")
    net.WriteString(msg)
    net.WriteString(Type)
    net.WriteFloat(time)
    net.WriteTable(col)
  net.Send(rf)
end

function Notifications:Send(who, id, args, col, ply)
	if !id || !args then
		id = "Unidentified ID"
		args = {}
		col = Color(235,25,25)
	end
	local msg = Notifications:Get( id, args )
	if who == "server" then
		MsgC(col, msg )
	elseif who == "client" then
    if string.StartWith( msg, "[Notifications]") then
      local txt = string.Replace( msg, "[Notifications]", "" )
  		chat.Text(ply, Color(0,75,255, 255), "[Notifications]", Color(255,255,255, 255), txt)
    else
      chat.Text(ply, col, msg)
    end
	end


end
