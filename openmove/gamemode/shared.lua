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



load.AddSH( "settings.lua" )
load.AddModule( "modules/sync.lua" )

load.AddSH( "utils" )
load.AddSH( "shared" )
load.AddSH( "movement" )
load.AddCL( "client" )

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
