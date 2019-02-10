/*
  Makes it easier to include files.
*/
local load = {}
local GM_PATH = GM.Folder:gsub("gamemodes/", "") .. "/gamemode/"

load.AddCL = function(path)
  local FILE_PATH = GM_PATH .. path

  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")

    for _, v in pairs(files) do
      if SERVER then
        AddCSLuaFile(path .. "/" .. v)
        MsgC( Color(28, 255, 0), "[SERVER] Loaded client file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      else
        include(path .. "/" .. v)
        MsgC( Color(28, 255, 0), "[CLIENT] Loaded client file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      end
    end
  else
    if SERVER then
      AddCSLuaFile(FILE_PATH)
      MsgC( Color(28, 255, 0), "[SERVER] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
    else
      include(FILE_PATH)
      MsgC( Color(28, 255, 0), "[CLIENT] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
    end
  end
end

load.AddSV = function(path)
  local FILE_PATH = GM_PATH .. path
  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "GAME")
    for _, v in pairs(files) do
      if SERVER then
        include(path .. "/" .. v)
        MsgC( Color(28, 255, 0), "[SERVER] Loaded server file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      end
    end
  else
    if SERVER then
      include(FILE_PATH)
      MsgC( Color(28, 255, 0), "[SERVER] Loaded server file '" .. GM_PATH .. path .. "'", "\n" )
    end
  end
end
/*
local function ExecuteOnFolder(dir, recursive, func)
  local path = GM.Folder:gsub("gamemodes/","") .. "/gamemode/"
  local fpath = table.concat({path,dir,"/*"})
    local files, directories = file.Find(fpath,"LUA")
    for k,v inpairs(files) do
      if string.GetExtensionFromFilename(v) ~= "lua" then
        continue
      end
      local callpath = table.concat({path,dir,"/",v})
      func(callpath)
    end
    if recursive then
      for k,v inpairs(directories) do
        local npath = table.concat({dir,"/",v})
            ExecuteOnFolder(npath,true,func)
      end
    end
  end
*/
load.AddSH = function(path)
  local FILE_PATH = GM_PATH .. path
  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, v in pairs(files) do

      if SERVER then
        include(path .. "/" .. v)
        AddCSLuaFile(path .. "/" .. v)
        MsgC( Color(250, 255, 0), "[SHARED] Loaded server file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      else

        include(path .. "/" .. v)
        MsgC( Color(250, 255, 0), "[SHARED] Loaded client file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      end
    end
  else
    if SERVER then
      include(FILE_PATH)
      AddCSLuaFile(FILE_PATH)
      MsgC( Color(250, 255, 0), "[SHARED] Loaded server file '" .. GM_PATH .. path .. "'", "\n" )
    else
      include(FILE_PATH)
      MsgC( Color(250, 255, 0), "[SHARED] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
    end
  end
end

load.AddModule = function(path)
  local FILE_PATH = GM_PATH .. path
  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, v in pairs(files) do
      if SERVER then
        AddCSLuaFile(path .. "/" .. v)
        MsgC( Color(250, 255, 0), "[MODULE] Loaded module '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      end
    end
  else
    if SERVER then
      AddCSLuaFile(FILE_PATH)
      MsgC( Color(250, 255, 0), "[MODULE] Loaded module '" .. GM_PATH .. path .. "'", "\n" )
    end
  end
end

load.Module = function(path)
  local FILE_PATH = GM_PATH .. path

  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, v in pairs(files) do

      if SERVER then
        MsgC( Color(0, 56, 255), "[MODULE] Loaded server file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
        return include(path .. "/" .. v)
      else
        MsgC( Color(0, 56, 255), "[MODULE] Loaded client file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
        return include(path .. "/" .. v)
      end
    end
  else
    if SERVER then
      MsgC( Color(0, 56, 255), "[MODULE] Loaded server file '" .. GM_PATH .. path .. "'", "\n" )
      return include(FILE_PATH)
    else
      MsgC( Color(0, 56, 255), "[MODULE] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
      return include(FILE_PATH)
    end
  end
end

return load
