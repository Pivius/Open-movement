include( 'shared.lua' )
AddCSLuaFile( 'shared.lua' )

DEFINE_BASECLASS( 'gamemode_base' )

function GM:Initialize()
	game.ConsoleCommand('sv_maxvelocity 9999\n')
	game.ConsoleCommand( 'sv_friction 8\n' )
	game.ConsoleCommand( 'sv_gravity 300\n' )
	game.ConsoleCommand('sv_sticktoground 0\n')
	game.ConsoleCommand('sv_airaccelerate 10\n')
	game.ConsoleCommand('sv_accelerate 10\n')
	game.ConsoleCommand('mp_falldamage 0\n')
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( pl )


	player_manager.SetPlayerClass( pl, 'player_sandbox' )

	BaseClass.PlayerSpawn( self, pl )

	pl:SetAvoidPlayers( false )
	pl:SetCollisionGroup( COLLISION_GROUP_WEAPON )

end

-- Set the ServerName every 30 seconds in case it changes..
-- This is for backwards compatibility only - client can now use GetHostName()
local function HostnameThink()

	SetGlobalString( "ServerName", GetHostName() )

end
timer.Create( "HostnameThink", 30, 0, HostnameThink )



function GM:GetFallDamage( ply, speed )
	 return ( speed / 50)
end
