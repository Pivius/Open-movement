font = {}
font.fonts = {}
font.clientList = {

}
font.list = {

}
font.setFont = "Trebuchet24"

-- Use to init fonts.
function InitalizeFonts()
  /*
  SetFont("HUD General", {
    font = "halflife2",
    size = 25,
    antialias = true})

  surface.CreateFont("HUD General2", {
    font = "halflife2",
    size = 25,
    antialias = true})
    */
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

-- Creates fonts based on size
function SetFont(unique, tbl)
  if !tbl then
    if font.fonts[unique] then
      local font_name = unique .. "_" .. font.fonts[unique].last_size
      if font.setFont != font_name then
        surface.SetFont(font_name)
        font.setFont = font_name
        return
      end
    end
  else
    if font.fonts[unique] && font.fonts[unique][tbl.size] then
      font.fonts[unique].last_size = tbl.size
      local font_name = unique .. "_" .. tbl.size
      font.setFont = font_name
      surface.SetFont(font_name)
    else
      if !font.fonts[unique] then
        font.fonts[unique] = {}
      end
      font.fonts[unique][tbl.size] = tbl
      font.fonts[unique].last_size = tbl.size
      local font_name = unique .. "_" .. font.fonts[unique].last_size
      font.setFont = font_name
      surface.CreateFont(font_name, tbl)
      surface.SetFont(font_name)
    end
  end
end

function GetFont(unique)
  if font.fonts[unique][font.fonts[unique].last_size] then
    return unique .. "_" .. font.fonts[unique].last_size
  end
  return "Trebuchet24"
end
InitalizeFonts()
-- TODO
-- text sizer cache
