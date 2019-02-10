font = {}
font.fonts = {}
font.clientList = {

}
font.list = {

}
font.setFont = "Trebuchet24"

function InitalizeFonts()
  surface.CreateFont("HUD General", {
    font = "halflife2",
    size = 25,
    antialias = true})

end

/*
  NAME - TblCompare
  FUNCTION - Compares two tables
*/

local function TblCompare(tbl1,tbl2)
	for k, v in pairs( tbl1 ) do
		if ( type(v) == "table" and type(tbl2[k]) == "table" ) then
			if ( !UT:TblCompare( v, tbl2[k] ) ) then return false end
		else
			if ( v != tbl2[k] ) then return false end
		end
	end
	for k, v in pairs( tbl2 ) do
		if ( type(v) == "table" and type(tbl1[k]) == "table" ) then
			if ( !UT:TblCompare( v, tbl1[k] ) ) then return false end
		else
			if ( v != tbl1[k] ) then return false end
		end
	end
	return true
end

function SetFont(unique, tbl)
  if !tbl then
    if font.fonts[unique] then
      if font.setFont != unique then
        surface.SetFont(unique)
        font.setFont = unique
        return
      end
    end
  else
    if font.fonts[unique] && TblCompare(font.fonts[unique],tbl) then
      font.setFont = unique
      surface.SetFont(unique)
    else
      font.fonts[unique] = tbl
      font.setFont = unique
      surface.CreateFont(unique, tbl)
      surface.SetFont(unique)
    end
  end
end

function GetFont(unique)
  if font.fonts[unique] then
    return unique
  end
  return "Trebuchet24"
end
InitalizeFonts()
