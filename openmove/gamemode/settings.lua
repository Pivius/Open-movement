local PLAYER = FindMetaTable( "Player" )

if SERVER then
  util.AddNetworkString( "Settings_Grab" )
end

if CLIENT then
  function grabVar(string, ply)

    net.Start("Settings_Grab")
      net.WriteString(string)
      net.WriteEntity(ply)
      net.WriteEntity(LocalPlayer())
    net.SendToServer()
  end
  net.Receive("Settings_Grab", function()
    local func = net.ReadString()
    local result = net.ReadType()
    local target = net.ReadEntity()
    getmetatable(target)[func](target, result)
    --getmetatable(target)[func](result)
  end)
else
  function sendVar(string, ply)
    net.Start("Settings_Grab")
      net.WriteString(string)
      net.WriteType(ply.settings[string])
      net.WriteEntity(ply)
    net.Send(ply)
  end
  net.Receive("Settings_Grab", function()
    local str = net.ReadString()
    local target = net.ReadEntity()
    local ply = net.ReadEntity()
    if IsValid(ply) and IsValid(target) then
      net.Start("Settings_Grab")
        net.WriteString(str)
        net.WriteType( target.settings[str] )
        net.WriteEntity(target)
      net.Send(ply)
    end
  end)
end
/*
  NAME - AddSettings
  FUNCTION - Get or set values
    GET: player:name()
    SET: player:name(var)
*/
function PLAYER:AddSettings(name, default)

  if !self:IsValid() then return end
  if !self.settings then
    self.settings = {default}
  end
  if !self.default then
    self.default = {default}
  end
  if ut_tbl.GetByKey(self.settings, name) then
  else

    self.settings[name] = default
    self.default[name] = default

    local copy = getmetatable(name)
    local createFunc = {}
    createFunc  = {
    	[name] = function( player, var )

        if !var and !isbool(var) then

          return player.settings[name]
        elseif var or isbool(var) then

          player.settings[name] = var
        end
    	end
    }
    table.Merge(copy, createFunc)

  	createFunc.__index = copy

    setmetatable( getmetatable(self), createFunc )
  end
end
