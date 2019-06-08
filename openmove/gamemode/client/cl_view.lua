freeCam = Angle(0,0,0)
local smooth = Angle()
local lagBack = Vector()
smoothAng = Angle(0,0,0)
aimDir = Angle(0,0,0)
vpos = Vector()

playerAim = Vector()
hookAdd("Init_Player_Vars", "Init_View", function(ply)
  ply:AddSettings("shoulder_view", 0)
  ply:AddSettings("frozen", false)
  ply:AddSettings("thirdperson", false)
end)

hook.Add( "ShouldDrawLocalPlayer", "ThirdPersonDrawPlayer", function()
	return LocalPlayer():thirdperson()
end )

function FreeCam( cmd, x, y, ang )
  if !IsValid( LocalPlayer( ) ) || !LocalPlayer():thirdperson() then return false end
  local ply = LocalPlayer( )
  freeCam.p = math.Clamp( math.NormalizeAngle( freeCam.p + y * (GetConVar( "sensitivity" ):GetFloat() * GetConVar( "m_pitch" ):GetFloat()) ), -90, 90 )
  freeCam.y = math.NormalizeAngle( freeCam.y - x * (GetConVar( "sensitivity" ):GetFloat() * GetConVar( "m_yaw" ):GetFloat()) )
  return true
end

hook.Add( "InputMouseApply", "ThirdpersonFreeCam", FreeCam )

hookAdd( "CalcView", "ThirdPersonView", function( ply, pos, ang, fov, znear, zfar, view )

	if ply:Alive() and ply:thirdperson() then
		local aim = LerpAngle(25*FrameTime(), smooth, freeCam)
		smooth = aim
		if ply:shoulder_view() == 1 then
			view.pos = ply:GetPos() + Vector(0,0,60) - ( (aim:Forward() * 90) ) + ( aim:Right() * 30 ) + ( aim:Up() * 5 )
		elseif ply:shoulder_view() == 2 then
			view.pos = ply:GetPos() + Vector(0,0,60) - ( (aim:Forward() * 90) ) + ( aim:Right() * -30 ) + ( aim:Up() * 5 )
    else
      view.pos = ply:GetPos() + Vector(0,0,60) - ( (aim:Forward() * 90) ) + ( aim:Up() * 5 )
		end
		view.angles = freeCam

		local lag = LerpVector(15*FrameTime(), lagBack, view.pos)
		lagBack = lag
		view.pos = lagBack
		local crosshair =   util.TraceLine( {
			start  = view.pos,
			endpos = view.pos + ( freeCam:Forward( ) * 99999 ),
			filter = ply
		} )
		playerAim = crosshair.HitPos

		view.fov = fov
		local t = {}
		t.start = ply:GetPos() + Vector(0,0,60)
		t.endpos = view.pos
		t.filter = ply
		local tr = util.TraceLine(t)
		view.pos = tr.HitPos
		if tr.Fraction < 1.0 then
			view.pos = view.pos + tr.HitNormal * 5
		end
		vpos = view.pos

	end

end )

function MoveAngle(ply, mv, cmd)
  local frontAim, backAim, leftaim, rightAim
  if !ply:Alive() || !ply:thirdperson() then return end
  if CLIENT then
    frontAim =   util.TraceLine( {
      start  = vpos,
      endpos = vpos + ( freeCam:Forward( ) * 100 ),
      filter = ply
    } )
    backAim =   util.TraceLine( {
      start  = vpos,
      endpos = vpos + ( freeCam:Forward( ) * -100 ),
      filter = ply
    } )
    rightAim =   util.TraceLine( {
      start  = vpos,
      endpos = vpos + ( freeCam:Right( ) * 100 ),
      filter = ply
    } )
    leftAim =   util.TraceLine( {
      start  = vpos,
    endpos = vpos + ( freeCam:Right( ) * -100 ),
      filter = ply
    } )
    local curVAngle = ply:EyeAngles()
    local newEyeAng = LerpAngle(5*FrameTime(), smoothAng, aimDir)
    smoothAng = newEyeAng
    ply:SetEyeAngles( newEyeAng )
  end
  if !ply:frozen() then
    aimDir = ( frontAim.HitPos-vpos ):Angle()
  end
end
hook.Add("SetupMove", "Angle movement", MoveAngle)
