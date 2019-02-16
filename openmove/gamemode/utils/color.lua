util = util or {}

util.Color = {}
local COLOR_META = FindMetaTable("Color")

/*
  NAME - Alpha
  FUNCTION - Sets the alpha of a color table.
*/
function util.Color.Alpha(col, alpha)
  col.a = alpha
	return col

end

function COLOR_META:Alpha(a)
  return util.Color.Alpha(self, a)
end

/*
  NAME - Explode
  FUNCTION - Returns a color structure
*/
function util.Color.Explode(color)
	return color.r, color.g, color.b, color.a
end

function COLOR_META:Explode()
  return util.Color.Explode(self)
end

/*
  NAME - Lerp
  FUNCTION - Lerps a color
*/

function util.Color.Lerp(frac, a, b)
  local aR, aG, aB, aA = UT:ExplodeColor(a)
  local bR, bG, bB, bA = UT:ExplodeColor(b)
  return Color(UT:Lerp(frac, aR, bR), UT:Lerp(frac, aG, bG), UT:Lerp(frac, aB, bB), UT:Lerp(frac, aA, bA))
end

function COLOR_META:Lerp(frac, to)
  return util.Color.Lerp(frac, self, to)
end

util.c = util.Color
ut_col = util.Color
/*
function test()
  local test = Color(1,1,1,1)
  test:Alpha(5)
  print(test)
end
test()
*/
