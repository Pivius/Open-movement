res = res or {}

res.resources = {}
local GAME_PATH = (GM.Folder:gsub("gamemodes/", "") .. "/content")
-- Grab resources from /content folder and add the file for fastdl.
function res.AddFile(path, folder)
  if !string.GetExtensionFromFilename(path) then
    local files, dirs = file.Find(path .. "/*", "LUA")

    for _, dir in pairs(dirs) do

      res.AddFile(path .. "/" .. dir, folder)
    end

    for _, v in pairs(files) do
      path = path:gsub(GAME_PATH, "")
      if path:sub(1, 1) == "/" then
        path = path:sub(2, #path)
      end
      resource.AddFile( path .. "/" .. v )

    end
  else
    path = path:gsub(GAME_PATH, "")
    resource.AddFile( path )
  end


end

res.AddFile(GAME_PATH)
