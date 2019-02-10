include( "shared.lua" )

DEFINE_BASECLASS( 'gamemode_base' )

--[[---------------------------------------------------------
	Name: gamemode:Initialize()
	Desc: Called immediately after starting the gamemode
-----------------------------------------------------------]]
function GM:Initialize()
	BaseClass.Initialize( self )
end

--[[---------------------------------------------------------
	Name: gamemode:PlayerBindPress()
	Desc: A player pressed a bound key - return true to override action
-----------------------------------------------------------]]
function GM:PlayerBindPress( pl, bind, down )

	return false

end
