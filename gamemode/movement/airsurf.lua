Airsurf = {}

hookAdd("Init_Player_Vars", "Init_airsurf", function(ply)
    ply:AddSettings("slide_ang", Vector(0,0,0))
    ply:AddSettings("surf_ang", 45)
end)


function Airsurf:GetAngles(ply, cmd)
    local fmove = cmd:GetForwardMove()
    local smove = cmd:GetSideMove()
    if ( smove == 0 && fmove > 0 ) then
        return 0
    elseif ( smove < 0 && fmove > 0 ) then
        return 45
    elseif ( smove < 0 && fmove == 0 ) then
        return 90
    elseif ( smove < 0 && fmove < 0 ) then
        return 135
    elseif ( smove == 0 && fmove < 0 ) then
        return 180
    elseif ( smove > 0 && fmove < 0 ) then
        return -135
    elseif ( smove > 0 && fmove == 0 ) then
        return -90
    elseif ( smove > 0 && fmove > 0 ) then
        return -45
    end
    return 180
end

function Airsurf.Checkslide(mv, cmd, normal)
	local forward, right = mv:GetMoveAngles():Forward(), mv:GetMoveAngles():Right()
	local wish_vel, wish_speed, wish_dir
    local vel = mv:GetVelocity()
	
	forward.z, right.z = 0, 0
	forward:Normalize()
	right:Normalize()
	wish_vel = (forward * cmd:GetForwardMove()) + (right * cmd:GetSideMove())
	--wish_vel.z = 0
	
	wish_speed = wish_vel
	wish_speed:Normalize()
	wish_speed = wish_speed:Length()
	wish_speed = wish_speed * mv:GetMaxSpeed()
	
	if wish_speed > mv:GetMaxSpeed() then
		wish_vel = wish_vel * (mv:GetMaxSpeed()/wish_speed)
	end
	
	wish_dir = wish_vel
	if (normal:Dot(wish_dir) < 0 and vel:Dot(normal) < 0) then
		return true
	end
	return false
end

function Airsurf:Move(ply, mv, cmd)
    
    local vel = mv:GetVelocity()
    local vel_normalized = mv:GetVelocity() * Vector(1,1,0)

    vel_normalized:Normalize()
    local newvel = Vector(0,0,0)
    local angle = (ply:surf_ang()/90)
    local fmove = cmd:GetForwardMove()
    local smove = cmd:GetSideMove()
    local angles = Airsurf:GetAngles(ply, cmd)
    local aim = (vel_normalized * Vector(1,1,0)):Angle()
    aim:RotateAroundAxis(Vector(0,0,1), angles)
    aim = -aim:Forward()
    aim.z = angle
    if mv:KeyPressed(IN_SPEED) then
        ply:slide_ang(aim)
    elseif mv:KeyReleased(IN_SPEED) then
        ply:slide_ang(Vector(0,0,0))
    end
 
    if mv:KeyDown(IN_SPEED) and Airsurf.Checkslide(mv, cmd,  ply:slide_ang()) then
        RampSlide.PhysicsClipVelocity( vel, ply:slide_ang(), newvel, 1 )
        if newvel.z < vel.z then
            newvel.z = vel.z
        end
        mv:SetVelocity(newvel)
    end
end
/*
function Airsurf.ChangeAngle( ply, but )
    print(ply:slide_ang())
    if but == MOUSE_5 then
        ply:surf_ang(math.Clamp(ply:surf_ang() + 5, 0, 180))
        ply:slide_ang((ply:slide_ang() * Vector(1,1,0)) + Vector(0,0,ply:surf_ang()/90))
    elseif but == MOUSE_4 then
        ply:surf_ang(math.Clamp(ply:surf_ang() - 5, 0, 180))
        ply:slide_ang((ply:slide_ang() * Vector(1,1,0)) + Vector(0,0,ply:surf_ang()/90))
    end
end
hook.Add("PlayerButtonDown", "Airsurf.ChangeAngle", Airsurf.ChangeAngle)
*/