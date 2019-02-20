util = util or {}

util.Player = {}

local PLAYER_META = FindMetaTable("Player")

/*
  NAME - GetByNick
  FUNCTION - Gets player entity by nick
*/
function util.Player.GetByNick(nick)
  assert(isstring(nick), "Nick has to be a string.")
	for k, v in ipairs( player.GetAll() ) do

		if ( string.find(string.lower( v:Nick() ), string.lower(nick)) ) then
			return v
		end
	end
	return NULL
end

util.p = util.Player
ut_ply = util.Player
