local test = {}

local function FindGrid(pos, size)
	local grid_pos = pos
	if grid_pos.x % size < size/2 then
		grid_pos.x = grid_pos.x - grid_pos.x % size
	else
		grid_pos.x = grid_pos.x + (size - grid_pos.x % size)
	end
	if grid_pos.y % size < size/2 then
		grid_pos.y = grid_pos.y - grid_pos.y % size
	else
		grid_pos.y = grid_pos.y + (size - grid_pos.y % size)
	end
	if grid_pos.z % size < size/2 then
		grid_pos.z = grid_pos.z - grid_pos.z % size
	else
		grid_pos.z = grid_pos.z + (size - grid_pos.z % size)
	end
	
	return grid_pos
end

hook.Add("PostDrawTranslucentRenderables","Airmove",function()
	local ply = LocalPlayer()
	local max_cubes = 2
	local cube_size = 100
	local cubes = {}
	if ply:slide_ang():Length() != 0 then
		for i = 1, max_cubes do
			local pos = i % 9
			if pos == 1 then
				pos = Vector(0,0,0)
			elseif pos == 2 then
				pos = Vector(0,0,0)
			end
			render.DrawWireframeBox( ply:GetPos() - ply:slide_ang()*ply:OBBMaxs().x, ply:slide_ang():Angle(), Vector(0,-cube_size,-cube_size), Vector(1,cube_size,cube_size), Color(255,0,0), true )
		end
	end
end)