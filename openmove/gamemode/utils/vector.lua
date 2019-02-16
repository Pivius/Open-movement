util = util or {}

util.Vector = {}

local VECTOR_META = FindMetaTable("Vector")


/*
  NAME - Clear
  FUNCTION - Clears vectors
*/

function util.Vector.Clear(a)
  a.x = 0
  a.y = 0
  a.z = 0
end

function VECTOR_META:Clear()
  util.Vector.Clear(self)
end

/*
  NAME - Clamp
  FUNCTION - Clamps a vector
*/

function util.Vector.Clamp(input, min, max)
  input.x = math.Clamp(input.x, min.x, max.x)
  input.y = math.Clamp(input.y, min.y, max.y)
  input.z = math.Clamp(input.z, min.z, maxzx)
  return input
end

function VECTOR_META:Clamp(min, max)
  util.Vector.Clamp(self, min, max)
  return self
end

/*
  NAME - GetMax
  FUNCTION - Returns the highest number in vector a
*/

function util.Vector.GetMax(a)
	return math.max(a.x, math.max(a.y, a.z))
end

function VECTOR_META:GetMax()
  return util.Vector.GetMax(self)
end

/*
  NAME - vectorMin
  FUNCTION - Returns the lowest number in vector a
*/

function util.Vector.GetMin(a)
	return math.min(a.x, math.min(a.y, a.z))
end

function VECTOR_META:GetMin()
  return util.Vector.GetMin(self)
end

/*
  NAME - vectorScale
  FUNCTION - Scales vector a with b and outputs to c
*/

function util.Vector.Scale(a, b ,c)
	c.x = a.x * b
	c.y = a.y * b
	c.z = a.z * b
	return c
end

function VECTOR_META:Scale(scale, out)
  if !out then
    out = Vector()
  end
  util.Vector.Scale(self, scale, out)
  self:Set(out)
  return out
end

/*
  NAME - Round
  FUNCTION - Rounds vector a with n decimals
*/

function util.Vector.Round(a, n)
	if !a then return end
	if !n then n = 0 end
	a.x = math.Round(a.x, n)
	a.y = math.Round(a.y, n)
	a.z = math.Round(a.z, n)
	return a
end

function VECTOR_META:Round(n)
  if !out then
    out = Vector()
  end
  util.Vector.Round(self, n)
  return self
end

/*
  NAME - Fill
  FUNCTION - Fills a vector a with b
*/

function util.Vector.Fill(a, b)
	a.x = b
	a.y = b
	a.z = b
	return a
end

function VECTOR_META:Fill(b)
  util.Vector.Fill(self, b)
  return self
end

/*
  NAME - Negate
  FUNCTION - Negates a table
*/

function util.Vector.Negate(a)
	a = a*-1
	return a
end

function VECTOR_META:Negate()
  util.Vector.Negate(self)
  return self
end

/*
  NAME - Normalize2
  FUNCTION -
*/
function util.Vector.Normalize2(inn, out)

	local	length, ilength

	length = math.sqrt(inn.x*inn.x + inn.y*inn.y + inn.z*inn.z);
	if (length == 0) then
    out:Clear()
		return 0;
	end

	ilength = 1.0/length;
  out:Scale(ilength)
	return length;
end

function VECTOR_META:Normalize2()
  if !out then
    out = Vector()
  end
  local length = util.Vector.Normalize2(self, out)
  self:Set(out)
  return length
end

/*
  NAME - MA
  FUNCTION - Scales a vector along chosen direction.
*/
function util.Vector.MA(a, scale, dir, b)
	b.x = a.x + dir.x * scale;
	b.y = a.y + dir.y * scale;
	b.z = a.z + dir.z * scale;
	return b
end

function VECTOR_META:MA(scale, dir, out)
  if !out then
    out = Vector()
  end
  util.Vector.MA(self, scale, dir, out)
  self:Set(out)
  return self
end

util.v = util.Vector
ut_vec = util.Vector
