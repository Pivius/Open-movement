util = util or {}
local math = math
local clamp = math.Clamp

util.Color = {}
util.Color.Palette = {
  ABSOLUTE_ZERO = Color(0, 72, 186),
  WHITE = Color(255, 255, 255),
  AMBER = Color(255, 191, 0),
  AUBURN = Color(164, 42, 42),
  AZURE = Color(0, 127, 255),
  BARN_RED = Color(124, 10, 2),
  BATTLESHIP_GREY = Color(133, 133, 131),
  BDAZZLED_BLUE = Color(46, 88, 148),
  BLACK = Color(0,0,0),
  BITTERSWEET_SHIMMER = Color(191, 79, 81),
  BLEU_DE_FRANCE = Color(48, 140, 231),
  BLOOD_RED = Color(102, 0, 0),
  CADMIUM_RED = Color(227, 0, 34),
  CARMINE = Color(150, 0, 24),
  CRIMSON = Color(221, 20, 60),
  BLUE = Color(0, 0, 255),
  PANTONE = Color(0, 24, 168),
  CAPRI = Color(0, 191, 255),
  GREY = Color(130, 130, 130),
  LIGHT_GREY = Color(208, 208, 208),
  DARK_GREY = Color(50, 50, 50),
}


local COLOR_META = FindMetaTable("Color")

/*
  NAME     - RGBtoHSL
  FUNCTION - Turns RGB to HSL
  ARGS     -
  r - Red or color table
  g - Green
  b - Blue
  a - Alpha
*/
function util.Color.RGBtoHSL(r, g, b, a)
  if IsColor(r) then
    r, g, b, a = r.r, r.g, r.b, r.a
  end

  local min = math.min(r,g,b)
  local max = math.max(r,g,b)
  local delta_max = max-min
  local h,s,l
  l = (max + min) / 2
  if (delta_max == 0) then
    h, s = 0, 0
  else
    if l < 0.5 then
      s = delta_max / (max + min)
    else
      s = delta_max / (2 - max - min)
    end

    local delta_r = (((max - r) / 6) + (delta_max / 2)) / delta_max
    local delta_g = (((max - g) / 6) + (delta_max / 2)) / delta_max
    local delta_b = (((max - b) / 6) + (delta_max / 2)) / delta_max

    if r == max then
      h = delta_b - delta_g
    elseif g == max then
      h = (1 / 3) + delta_r - delta_b
    elseif b == max then
      h = (2 / 3) + delta_b - delta_r
    end

    if h < 0 then h = h + 1 end
    if h > 1 then h = h - 1 end
  end

  return h, s, l, a
end

function COLOR_META:toHSL()
  return util.Color.RGBtoHSL(self.r, self.g, self.b, self.a)
end

/*
  NAME     - RGBtoHSV
  FUNCTION - Turns RGB to HSV
  ARGS     -
  r - Red or color table
  g - Green
  b - Blue
  a - Alpha
*/
function util.Color.RGBtoHSV(r, g, b, a)
  if IsColor(r) then
    r, g, b, a = r.r, r.g, r.b, r.a
  end

  local min = math.min(r,g,b)
  local max = math.max(r,g,b)
  local delta_max = max-min
  local h,s,v
  v = max
  if (delta_max == 0) then
    h, s = 0, 0
  else
    s = delta_max / max

    local delta_r = (((max - r) / 6) + (delta_max / 2)) / delta_max
    local delta_g = (((max - g) / 6) + (delta_max / 2)) / delta_max
    local delta_b = (((max - b) / 6) + (delta_max / 2)) / delta_max

    if r == max then
      h = delta_b - delta_g
    elseif g == max then
      h = (1 / 3) + delta_r - delta_b
    elseif b == max then
      h = (2 / 3) + delta_b - delta_r
    end

    if h < 0 then h = h + 1 end
    if h > 1 then h = h - 1 end
  end

  return h, s, v, a
end

function COLOR_META:toHSV()
  return util.Color.RGBtoHSV(self.r, self.g, self.b, self.a)
end

/*
  NAME     - HSLtoRGB
  FUNCTION - Turns HSL to RGB
  ARGS     -
  h - Hue
  s - Saturation
  l - Lightness
  a - Alpha
*/
function util.Color.HSLtoRGB(h, s, l, a)
  local r,g,b
  if s == 0 then
    r = l
    g = l
    b = l
  else
    local var1, var2

    if l < 0.5 then
      var2 = l * (1 + s)
    else
      var2 = (l + s) - (s * l)
    end

    var1 = 2 * l - var2

    local function huetorgb(v1, v2, vh)
      if vh < 0 then vh = vh + 1 end
      if vh > 1 then vh = vh - 1 end
      if 6 * vh < 1 then return v1 + (v2 - v1) * 6 * vh end
      if 2 * vh < 1 then return v2 end
      if 3 * vh < 2 then return v1 + (v2 - v1) * ((2 / 3) - vh) * 6 end
      return v1
    end

    r = huetorgb(var1, var2, h + (1 / 3))
    g = huetorgb(var1, var2, h)
    b = huetorgb(var1, var2, h - (1 / 3))
  end

  return Color(r, g, b, a)
end


/*
  NAME     - HSVtoRGB
  FUNCTION - Turns HSV to RGB
  ARGS     -
  h - Hue
  s - Saturation
  v - Value
  a - Alpha
*/
function util.Color.HSVtoRGB(h, s, v, a)
  local r,g,b

  if s == 0 then
    r = v
    g = v
    b = v
  else
    local varh, vari, var1, var2, var3
    varh = h * 6
    if varh == 6 then varh = 0 end
    vari = math.floor(varh)
    var1 = v * (1 - s)
    var2 = v * (1 - s * (varh - vari))
    var3 = v * (1 - s * (1 - (varh - vari)))

    if vari == 0 then
      r = v
      g = var3
      b = var1
    elseif vari == 1 then
      r = var2
      g = v
      b = var1
    elseif vari == 2 then
      r = var1
      g = v
      b = var3
    elseif vari == 3 then
      r = var1
      g = var2
      b = v
    elseif vari == 4 then
      r = var3
      g = var1
      b = v
    else
      r = v
      g = var1
      b = var2
    end
  end

  return Color(r, g, b, a)
end

/*
  NAME     - Lighten
  FUNCTION - Lightens a color
  ARGS     -
  amount - Amount to lighten
  ... - Color arguments
*/
function util.Color.Lighten(amount, ...)
  local h,s,l,a = util.Color.RGBtoHSL(...)
  return util.Color.HSLtoRGB(h,s,l+amount,a)
end

function COLOR_META:Lighten(a)
  self = util.Color.Lighten(a, self)
  return self
end

/*
  NAME     - Darken
  FUNCTION - Darkens a color
  ARGS     -
  amount - Amount to darken
  ... - Color arguments
*/
function util.Color.Darken(amount, ...)
  local h,s,l,a = util.Color.RGBtoHSL(...)
  return util.Color.HSLtoRGB(h,s,l-amount,a)
end

function COLOR_META:Darken(a)
  self = util.Color.Darken(a, self)
  return self
end

/*
  NAME     - Saturate
  FUNCTION - Saturates a color
  ARGS     -
  amount - Amount to saturate
  ... - Color arguments
*/
function util.Color.Saturate(amount, ...)
  local h,s,v,a = util.Color.RGBtoHSV(...)
  return util.Color.HSVtoRGB(h,s+amount,v,a)
end

function COLOR_META:Saturate(a)
  self = util.Color.Saturate(a, self)
  return self
end

/*
  NAME     - Desaturate
  FUNCTION - Desaturates a color
  ARGS     -
  amount - Amount to desaturate
  ... - Color arguments
*/
function util.Color.Desaturate(amount, ...)
  local h,s,v,a = util.Color.RGBtoHSV(...)
  return util.Color.HSVtoRGB(h,s-amount,v,a)
end

function COLOR_META:Desaturate(a)
  self = util.Color.Desaturate(a, self)
  return self
end

/*
  NAME     - Hue
  FUNCTION - Changes the hue of a color
  ARGS     -

  ... - Color arguments
*/
function util.Color.Hue(hue, ...)
  local h,s,l,a = util.Color.RGBtoHSL(...)
  return util.Color.HSLtoRGB(hue,s,l,a)
end

function COLOR_META:Hue(hue)
  self = util.Color.Hue(hue, self)
  return self
end

/*
  NAME     - Invert
  FUNCTION - Inverts a color
  ARGS     -
  ... - Color arguments
*/
function util.Color.Invert(r, g, b, a)
  if IsColor(r) then
    r, g, b, a = r.r, r.g, r.b, r.a
  end
  return Color(1-r, 1-g, 1-b, a)
end

function COLOR_META:Invert()
  self = util.Color.Invert(self)
  return self
end

/*
  NAME     - InvertHue
  FUNCTION - Inverts the hue of a color
  ARGS     -
  ... - Color arguments
*/
function util.Color.InvertHue(...)
  local h,s,l,a = util.Color.RGBtoHSL(...)
  return util.Color.HSLtoRGB(1-h,s,l,a)
end

function COLOR_META:InvertHue()
  self = util.Color.InvertHue(self)
  return self
end

/*
  NAME     - Alpha
  FUNCTION - Sets the alpha of a color table.
*/
function util.Color.Alpha(col, alpha)
  local new_col = Color(255,255,255):Copy(col)
  new_col.a = math.Clamp(alpha, 0, 255)
  col = new_col
	return col

end

function COLOR_META:Alpha(a)
  return util.Color.Alpha(self, a)
end
ColorAlpha = util.Color.Alpha
/*
  NAME     - Unpack
  FUNCTION - Returns a color structure
*/
function util.Color.Unpack(color)
	return color.r, color.g, color.b, color.a
end

function COLOR_META:Unpack()
  return util.Color.Unpack(self)
end

/*
  NAME     - Pack
  FUNCTION - Turns a color structure into a color table. Can also insert color table and it'll use the selected color from that table.
  ARGS     -
  r - Red
  g - Green
  b - Blue
  a - Alpha
*/
function util.Color.Pack(r, g, b, a)
  if IsColor(r) then
    r = r.r
  elseif !r then
    r = 255
  end
  if IsColor(g) then
    g = g.g
  elseif !g then
    g = 255
  end
  if IsColor(b) then
    b = b.b
  elseif !b then
    b = 255
  end
  if IsColor(a) then
    a = a.a
  elseif !a then
    a = 255
  end
	return Color(r, g, b, a)
end

/*
  NAME     - TableToCopl
  FUNCTION - Turns a table into color
  ARGS     -
  tbl - Table
*/
function util.Color.TableToCol(tbl)

	return Color(tbl[1], tbl[2], tbl[3])
end

/*
  NAME     - ColToTable
  FUNCTION - Turns color to table
  ARGS     -
  r - Red or Color table
  g - Green
  b - Blue
  a - Alpha
*/

function util.Color.ColToTable(r, g, b, a)
  if IsColor(r) then
    return {r.r, r.g, r.b, r.a}
  end
  return {r, g, b, a}
end

function COLOR_META:ToTable()
  self = util.Color.ColToTable(self:Unpack())
  return self
end

/*
  NAME     - Lerp
  FUNCTION - Lerps a color
*/

function util.Color.Lerp(frac, a, b)
  local aR, aG, aB, aA = a:Unpack()
  local bR, bG, bB, bA = b:Unpack()
  return Color(Lerp(frac, aR, bR), Lerp(frac, aG, bG), Lerp(frac, aB, bB), Lerp(frac, aA, bA))
end

function COLOR_META:Lerp(frac, to)
  self.r, self.g, self.b, self.a = util.Color.Lerp(frac, self, to):Unpack()
  return self
end

/*
  NAME     - Lerp
  FUNCTION - Lerps a color
*/

function util.Color.Copy( a, b )
  if !b then return Color(a:Unpack()) end
  a = Color(b:Unpack())
  return a
end

function COLOR_META:Copy(b)
  self = util.Color.Copy( self, b )
  return self
end

/*
  NAME     - Sub
  FUNCTION - Subtracts two colors
*/

function util.Color.Sub( a, b )
  return Color(clamp(a.r - b.r, 0, 255), clamp(a.g - b.g, 0, 255), clamp(a.b - b.b, 0, 255), clamp(a.a - b.a, 0, 255))
end

function COLOR_META:Sub(b)
  self = util.Color.Sub( self, b )
  return self
end

/*
  NAME     - Add
  FUNCTION - Adds two colors
*/

function util.Color.Add( a, b )
  return Color(clamp(a.r + b.r, 0, 255), clamp(a.g + b.g, 0, 255), clamp(a.b + b.b, 0, 255), clamp(a.a + b.a, 0, 255))
end

function COLOR_META:Add(b)
  self = util.Color.Add( self, b )
  return self
end

/*
  NAME     - Mult
  FUNCTION - Multiplies two colors
*/

function util.Color.Mult( a, b )
  return Color(clamp(a.r * b.r, 0, 255), clamp(a.g * b.g, 0, 255), clamp(a.b * b.b, 0, 255), clamp(a.a * b.a, 0, 255))
end

function COLOR_META:Mult(b)
  self = util.Color.Mult( self, b )
  return self
end

/*
  NAME     - Div
  FUNCTION - Divides two colors
*/

function util.Color.Div( a, b )
  return Color(clamp(a.r / b.r, 0, 255), clamp(a.g / b.g, 0, 255), clamp(a.b / b.b, 0, 255), clamp(a.a / b.a, 0, 255))
end

function COLOR_META:Div(b)
  self = util.Color.Div( self, b )
  return self
end


/*
  NAME     - Equals
  FUNCTION - Checs to see if two colors are identical
*/

function util.Color.Equals( a, b, round )
  if round then
    a = Color(math.Round(a.r, round), math.Round(a.g, round), math.Round(a.b, round), math.Round(a.a, round))
    b = Color(math.Round(b.r, round), math.Round(b.g, round), math.Round(b.b, round), math.Round(b.a, round))
  end
  return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
end

function COLOR_META:Equals(b, round)
  return util.Color.Equals( self, b, round )
end

util.c = util.Color
ut_col = util.Color
ut_col_pal = util.Color.Palette
/*
function test()
  local test = Color(1,1,1,1)
  test:Alpha(5)
  print(test)
end
test()
*/
