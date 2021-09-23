/*
  Makes it easier to include files.
*/
local load = {}
local GM_PATH = (GM.Folder:gsub("gamemodes/", "") .. "/gamemode/")
load.included = {}
load.CSLua = {}
load.ignore = {}
------------------------------------------------------------------------------------------------------------------
local function CLInclude(path)
  path = path:gsub(GM_PATH, "")
  if CLIENT && !table.HasValue(load.included, GM_PATH .. path) then
    include(path)
    table.insert(load.included, GM_PATH .. path)
    MsgC( Color(28, 255, 0), "[CLIENT] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
  elseif SERVER && !table.HasValue(load.CSLua, GM_PATH .. path) then
    AddCSLuaFile(path)
    table.insert(load.CSLua, GM_PATH .. path)
    MsgC( Color(28, 255, 0), "[SERVER] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
  end
end

local function SVInclude(path)
  path = path:gsub(GM_PATH, "")
  if SERVER && !table.HasValue(load.included, GM_PATH .. path) then
    include(path)
    table.insert(load.included, GM_PATH .. path)
    MsgC( Color(255, 15, 0), "[SERVER] Loaded server file '" .. GM_PATH .. path .. "'", "\n" )
  end
end

local function SHInclude(path)
  path = path:gsub(GM_PATH, "")
  if SERVER && (!table.HasValue(load.included, GM_PATH .. path) && !table.HasValue(load.CSLua, GM_PATH .. path)) then
    include(path)
    AddCSLuaFile(path)
    table.insert(load.included, GM_PATH .. path)
    table.insert(load.CSLua, GM_PATH .. path)
    MsgC( Color(250, 255, 0), "[SHARED] Loaded server file '" .. GM_PATH .. path .. "'", "\n" )
  elseif CLIENT && !table.HasValue(load.included, GM_PATH .. path) then
    include(path)
    table.insert(load.included, GM_PATH .. path)
    MsgC( Color(250, 255, 0), "[SHARED] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
  end
end
----------------------------------------------------------------------------------------------------------------

load.AddCL = function(path)
  local FILE_PATH = GM_PATH .. path

  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, dir in pairs(dirs) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. dir) then continue end
      load.AddCL(path .. "/" .. dir)
    end

    for _, v in pairs(files) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. v) then continue end
      CLInclude(path .. "/" .. v)
    end

  else
    if table.HasValue(load.ignore, FILE_PATH) then return end
    CLInclude(FILE_PATH)
  end
end

load.AddSV = function(path)
  local FILE_PATH = GM_PATH .. path

  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, dir in pairs(dirs) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. dir) then continue end
      load.AddSV(path .. "/" .. dir)
    end

    for _, v in pairs(files) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. v) then continue end
      SVInclude(path .. "/" .. v)
    end
  else
    if table.HasValue(load.ignore, FILE_PATH) then return end
    SVInclude(FILE_PATH)
  end
end

load.AddSH = function(path)
  local FILE_PATH = GM_PATH .. path
  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, dir in pairs(dirs) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. dir) then continue end
      load.AddSH(path .. "/" .. dir)
    end

    for _, v in pairs(files) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. v) then continue end
      SHInclude(path .. "/" .. v)
    end
  else
    if table.HasValue(load.ignore, FILE_PATH) then return end
    SHInclude(FILE_PATH)
  end
end

load.AddModule = function(path)
  local FILE_PATH = GM_PATH .. path
  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, dir in pairs(dirs) do
      load.AddModule(path .. "/" .. dir)
    end

    for _, v in pairs(files) do
      if SERVER && !table.HasValue(load.CSLua, GM_PATH .. path .. "/" .. v) then
        AddCSLuaFile(path .. "/" .. v)
        table.insert(load.CSLua, GM_PATH .. path .. "/" .. v)
        MsgC( Color(0, 255, 247), "[MODULE] Loaded module '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      end
    end
  else
    if SERVER && !table.HasValue(load.CSLua, FILE_PATH) then
      AddCSLuaFile(FILE_PATH)
      table.insert(load.CSLua, FILE_PATH)
      MsgC( Color(0, 255, 247), "[MODULE] Loaded module '" .. GM_PATH .. path .. "'", "\n" )
    end
  end
end

load.Module = function(path)
  local FILE_PATH = GM_PATH .. path

  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, dir in pairs(dirs) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. dir) then continue end
      load.Module(path .. "/" .. dir)
    end
    for _, v in pairs(files) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. v) then  continue end

      if SERVER then
        MsgC( Color(0, 56, 255), "[MODULE] Loaded server file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
        return include(path .. "/" .. v)
      else
        MsgC( Color(0, 56, 255), "[MODULE] Loaded client file '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
        return include(path .. "/" .. v)
      end
    end
  else
    if table.HasValue(load.ignore, FILE_PATH) then return end
    if SERVER then
      MsgC( Color(0, 56, 255), "[MODULE] Loaded server file '" .. GM_PATH .. path .. "'", "\n" )
      return include(FILE_PATH)
    else
      MsgC( Color(0, 56, 255), "[MODULE] Loaded client file '" .. GM_PATH .. path .. "'", "\n" )
      return include(FILE_PATH)
    end
  end
end

load.Ignore = function(path)
  local FILE_PATH = GM_PATH .. path

  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, dir in pairs(dirs) do
      table.insert(load.ignore, GM_PATH .. path .. "/" .. dir)
      load.Ignore(path .. "/" .. dir)
    end

    for _, v in pairs(files) do
      table.insert(load.ignore, GM_PATH .. path .. "/" .. v)
      if SERVER && !table.HasValue(load.CSLua, GM_PATH .. path .. "/" .. v) then
        AddCSLuaFile(path .. "/" .. v)
        table.insert(load.CSLua, GM_PATH .. path .. "/" .. v)
        MsgC( Color(13, 177, 177), "[IGNORE] Loaded client file serverside '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      end
    end

  else
    table.insert(load.ignore, FILE_PATH)
    if SERVER && !table.HasValue(load.CSLua, FILE_PATH) then
      AddCSLuaFile(FILE_PATH)
      table.insert(load.CSLua, FILE_PATH)
      MsgC( Color(13, 177, 177), "[IGNORE] Loaded client file serverside '" .. FILE_PATH .. "'", "\n" )
    end
  end

end
load.UnIgnore = function(path)
  local FILE_PATH = GM_PATH .. path

  if string.GetExtensionFromFilename(path) != "lua" then
    FILE_PATH = GM_PATH .. path .. "/*"
    local files, dirs = file.Find(FILE_PATH, "LUA")
    for _, dir in pairs(dirs) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. dir) then
        table.remove(load.ignore, ut_tbl.GetByValue(load.ignore, GM_PATH .. path .. "/" .. dir))
      end
      MsgC( Color(13, 177, 177), "[IGNORE] Removing '" .. GM_PATH .. path .. "/" .. dir .. "'", "\n" )
      load.UnIgnore(path .. "/" .. dir)
    end

    for _, v in pairs(files) do
      if table.HasValue(load.ignore, GM_PATH .. path .. "/" .. v) then
        table.remove(load.ignore, ut_tbl.GetByValue(load.ignore, GM_PATH .. path .. "/" .. v))
        MsgC( Color(13, 177, 177), "[IGNORE] Removing '" .. GM_PATH .. path .. "/" .. v .. "'", "\n" )
      end
    end
  else
    if table.HasValue(load.ignore, FILE_PATH) then
      table.remove(load.ignore, ut_tbl.GetByValue(load.ignore, FILE_PATH))
      MsgC( Color(13, 177, 177), "[IGNORE] Removing '" .. FILE_PATH .. "'", "\n" )
    end
  end

end

return load
