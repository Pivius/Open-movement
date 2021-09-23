include( "player_class/player_sandbox.lua" )
load = include( "file.lua" )
if SERVER then
	AddCSLuaFile( "file.lua" )
end
GM.Name			= "Parkour"
GM.Author		= "Pivius"
GM.Email		= ""
GM.Website		= ""
GM.TeamBased	= false


load.AddSV( "resource.lua" )
load.AddSH( "settings.lua" )
load.AddModule( "modules/sync.lua" )
load.AddModule( "modules/ease.lua" )
-- Libraries
load.AddSH( "libraries/bench.lua" )
load.AddCL( "libraries/font.lua" )
load.AddCL( "libraries/draw.lua" )
load.AddCL( "libraries/vgui" )
load.AddSH( "utils" )
load.AddSH( "shared" )
load.AddSH( "movement" )
load.AddSV( "server" )

load.AddCL( "client/hud/preset/preset.lua" )
load.Ignore( "client/hud/preset/preset_hud")
load.Ignore( "client/hud/hudmod.lua" )
load.Ignore( "client/hud/hud.lua" )
load.Ignore( "client/hud/keyecho.lua" )

load.AddCL( "client" )
load.UnIgnore( "client/hud/preset/preset_hud")
load.UnIgnore( "client/hud/hudmod.lua" )
load.UnIgnore( "client/hud/hud.lua" )
load.UnIgnore( "client/hud/keyecho.lua" )
if CLIENT then
	load.AddCL( "client/hud/preset/preset_hud" )
end
load.AddCL( "client/hud/hudmod.lua" )
load.AddCL( "client/hud/hud.lua" )
load.AddCL( "client/hud/keyecho.lua" )

hook.Add("OnEntityCreated","Core_InitPlayerSpawn",function(ply)
  local plMeta = getmetatable(ply)
	if plMeta!=FindMetaTable("Player") then
    return
  end
  // Player variables

  hookCall("Init_Player_Vars", ply)

end)

--[[---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, attacker )
	return true
end

--[[---------------------------------------------------------
   Name: gamemode:ShouldCollide( Ent1, Ent2 )
   Desc: This should always return true unless you have
		  a good reason for it not to.
-----------------------------------------------------------]]
function GM:ShouldCollide( Ent1, Ent2 )

	return false

end
lua_refresh = true
