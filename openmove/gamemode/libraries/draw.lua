draw_lib = {}
local surface = surface
local DrawRect = surface.DrawRect
local SetDrawColor = surface.SetDrawColor
/*
  NAME      - Text
  FUNCTION  - Draws text
  ARGS 			-
    text  - The text you want to draw
		x     - X position
	  y     - Y position
    align - Align the text to the right, center or left of the positions
          1/NA - Left
          2    - Center
          3    - Right
    xstep - Moves the text X amount of times by it's text width
    ystep - Moves the text X amount of times by it's text height
*/
function draw_lib.Text(text, x, y, align, xstep, ystep)
  local tx_original, ty_original = surface.GetTextSize( text )
  if !xstep then xstep = 1 end
  if !ystep then ystep = 0 end
  local tx = tx_original*xstep
  local ty = ty_original*ystep
  if !align || align == 1 then -- Left
    if ystep != 0 then
      y = y - ty
    end
    if xstep != 0 then
      x = x - ty
    end
    surface.SetTextPos( x, y )
  elseif align == 2 then -- cemter
    tx = math.max( tx, tx_original)
    surface.SetTextPos( x - tx / 2, y - ty )
  else -- Right
    surface.SetTextPos( x - tx, y - ty)
  end
  surface.DrawText( text )
end

/*
  NAME      - Outline
  FUNCTION  - Draws an outline
  ARGS 			-
    x - X Position
    y - Y Position
    w - Width
    h - Height
    t - Thickness
*/
function draw_lib.Outline(x, y, w, h, t)
  if not !t then t = 1 end
  DrawRect(x, y, w, t)
  DrawRect(x, y + (h - t), w, t)
  DrawRect(x, y, t, h)
  DrawRect(x + (w - t), y, t, h)
end

/*
  NAME      - OutlinedBox
  FUNCTION  - Draws outlined box
  ARGS 			-
    x      - X Position
    y      - Y Position
    w      - Width
    h      - Height
    t      - Thickness
    outcol - Outline Color
*/
function draw_lib.OutlinedBox(x, y, w, h, t, outcol)
  if not !t then t = 1 end
  surface_DrawRect(x + 1, y + 1, w - 2, h - 2)
  draw_lib.Outline(x, y, w, h, t)
end

/*
  NAME      - DrawBox
  FUNCTION  - Draws box
  ARGS 			-
    x      - X Position
    y      - Y Position
    w      - Width
    h      - Height
    col    - Color
*/
function draw_lib.DrawBox(x, y, w, h, col)
  SetDrawColor( col )
  DrawRect( x, y, w, h )
end

/*
  NAME      - DrawPoly
  FUNCTION  - Draws box
  ARGS 			-
    x      - X Position
    y      - Y Position
    w      - Width
    h      - Height
    col    - Color
*/
function draw_lib.DrawPoly(vertices, col)
  print(col)
  if !col then col = Color(255,255,255, 255) end
  SetDrawColor( col )
  surface.DrawPoly( vertices )
end

/*
  NAME      - DrawRoundedBox
  FUNCTION  - RoundedBoxEx from the github, but without rounding the positions and size
  ARGS 			-
    x          - X Position
    y          - Y Position
    w          - Width
    h          - Height
    col        - Color
    bordersize - Size of the corners
    tl         - Top left
    tr         - Top right
    bl         - Bottom left
    br         - Bottom right
*/
local tex_corner8	= surface.GetTextureID( "gui/corner8" )
local tex_corner16	= surface.GetTextureID( "gui/corner16" )
local tex_corner32	= surface.GetTextureID( "gui/corner32" )
local tex_corner64	= surface.GetTextureID( "gui/corner64" )
local tex_corner512	= surface.GetTextureID( "gui/corner512" )
function draw_lib.DrawRoundedBox(x, y, w, h, col, bordersize, tl, tr, bl, br)
	-- Do not waste performance if they don't want rounded corners
	if ( bordersize <= 0 ) then
		draw_lib.DrawBox(x, y, w, h, col)
		return
	end

	bordersize = math.min( math.Round( bordersize ), math.floor( w / 2 ) )

	-- Draw as much of the rect as we can without textures
  draw_lib.DrawBox(x + bordersize, y, w - bordersize * 2, h, col)
  draw_lib.DrawBox(x, y + bordersize, bordersize, h - bordersize * 2, col)
  draw_lib.DrawBox(x + w - bordersize, y + bordersize, bordersize, h - bordersize * 2, col)

	local tex = tex_corner8
	if ( bordersize > 8 ) then tex = tex_corner16 end
	if ( bordersize > 16 ) then tex = tex_corner32 end
	if ( bordersize > 32 ) then tex = tex_corner64 end
	if ( bordersize > 64 ) then tex = tex_corner512 end

	surface.SetTexture( tex )

	if ( tl ) then
		surface.DrawTexturedRectUV( x, y, bordersize, bordersize, 0, 0, 1, 1 )
	else
    draw_lib.DrawBox(x, y, bordersize, bordersize, col)
	end

	if ( tr ) then
		surface.DrawTexturedRectUV( x + w - bordersize, y, bordersize, bordersize, 1, 0, 0, 1 )
	else
    draw_lib.DrawBox(x + w - bordersize, y, bordersize, bordersize, col)
	end

	if ( bl ) then
		surface.DrawTexturedRectUV( x, y + h -bordersize, bordersize, bordersize, 0, 1, 1, 0 )
	else
    draw_lib.DrawBox(x, y + h - bordersize, bordersize, bordersize, col)
	end

	if ( br ) then
		surface.DrawTexturedRectUV( x + w - bordersize, y + h - bordersize, bordersize, bordersize, 1, 1, 0, 0 )
	else
    draw_lib.DrawBox(x + w - bordersize, y + h - bordersize, bordersize, bordersize, col)
	end
end

/*
  NAME      - Circle
  FUNCTION  - Draws circle
  ARGS 			-
    x         - X Position
    y         - Y Position
    startang  - Starting Angle
    endang    - End Angle
    radius    - Radius
    roughness - Roughness step
*/
function draw_lib.Circle(x, y, startang, endang, radius, roughness)
  local vertices = {}
  for degree=startang,endang,roughness do
    local x1,y1 = math.cos(math.rad(degree)) * radius + x, math.sin(math.rad(degree)) * radius + y
    table.insert(vertices, {x = x1,y = y1})
  end
  surface.DrawPoly(vertices)
end

/*
  NAME      - OutlineCircle
  FUNCTION  - Draws the outline of a circle using rects.
  ARGS 			-
    x         - X Position
    y         - Y Position
    startang  - Starting Angle
    endang    - End Angle
    radius    - Radius
    thickness - Thickness
    roughness - Roughness step
*/
function draw_lib.OutlineCircle(x, y, startang, endang, radius, thickness, roughness, modifier)
  if !modifier then modifier = 1 end
  startang = math.Clamp( startang or 0, 0, 360 );
    endang = math.Clamp( endang or 360, 0, 360 );

    if endang < startang then
        local temp = endang;
        endang = startang;
        startang = temp;
    end

  for i=startang, endang, roughness do
    draw.NoTexture()
    surface.DrawTexturedRectRotated(x + math.cos( math.rad(i) ) * (radius) , y + math.sin( math.rad(i) ) * (radius) ,thickness, modifier*2, -i )
  end
end
