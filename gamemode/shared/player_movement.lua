MOVEMENT_MODES = {
	"Parkour",
	"Grapple",
	"RadioSkate",
	"VQ3",
	"CPMA",
	"Bhop",
	"Momentum",
	"Airmove",
	"Pole",
	"Airstrafe"
	
}
if CLIENT then
	CreateClientConVar( "mm_mode", "1", false,true, "Switches between modes. 1-Parkour, 2-Grapple, 3-Radioskate, 4-VQ3, 5-CPMA, 6-Bhop, 7-Momentum")
	cvars.AddChangeCallback( "mm_mode", function( convar_name, value_old, value_new )
		LocalPlayer():movement_mode(math.max(math.min(value_new, #MOVEMENT_MODES), 1))
		net.Start("Mode_Networking")
		net.WriteInt(LocalPlayer():movement_mode(), 6)
		net.WriteEntity(LocalPlayer())
		net.SendToServer()
		LocalPlayer():friction(8)
		LocalPlayer():accel(10)
		LocalPlayer():air_accel(10)
		LocalPlayer():gravity(300)
	end )
else
	util.AddNetworkString( "Mode_Networking" )
	
	net.Receive("Mode_Networking", function()
		local int = net.ReadInt(6)
		local ply = net.ReadEntity()
		ply:movement_mode(int)
		ply:friction(8)
		ply:accel(10)
		ply:air_accel(10)
		ply:gravity(300)
	end)
	
	
end

//
// Player Vars
//
hookAdd("Init_Player_Vars", "Init_Movement", function(ply)
	ply:AddSettings("last_vel", Vector(0,0,0))
	ply:AddSettings("top_speed", {})
	ply:AddSettings("air_accel", 10)
	ply:AddSettings("accel", 10)
	ply:AddSettings("friction", 8)
	ply:AddSettings("gravity", 300)
	ply:AddSettings("air_accel_speed", 0)
	ply:AddSettings("water_friction", 1)
	ply:AddSettings("water_accel", 10)
	ply:AddSettings("LeftGround", false)
	ply:AddSettings("step_size", ply:GetStepSize())
	ply:AddSettings("can_rocketjump", false)
	ply:SetStepSize(32)
	ply:AddSettings("movement_mode", 1)
	ply:AddSettings("velocity_scale", 1)
	ply:AddSettings("default_jump_power", ply:GetJumpPower())
	
	for _, modes in ipairs(MOVEMENT_MODES) do
		table.insert(ply:top_speed(), 0)
	end
	
end)
/*
	NAME		- SetJumpVelocity
	FUNCTION	- Sets the amount of velocity to gain by jumping
	ARGS		-
		ply - PLayer
		vel - Jump velocity
*/
function SetJumpVelocity(ply, vel)
	if ply:GetJumpPower() != vel * ply:velocity_scale() then
		ply:SetJumpPower(vel * ply:velocity_scale())
		ply:default_jump_power(vel * ply:velocity_scale())
	end
end

/*
	NAME		- SetWalkSpeed
	FUNCTION 	- Sets the movement speed
	ARGS 		-
		ply - Player
		vel - Movement speed
*/
function SetWalkSpeed(ply, vel)
	if ply:GetWalkSpeed() != vel then
		ply:SetWalkSpeed(vel)
		ply:SetRunSpeed( vel )
	end
end

function SetVelocityScale(ply, scale)
	if ply:velocity_scale() != scale || ply:GetJumpPower() != ply:default_jump_power() * scale then
		ply:velocity_scale(scale)
		ply:SetJumpPower(ply:default_jump_power() * scale)
	end
end

function SetSettings(ply, accel, air_accel, gravity, friction, canrj)
	if ply:accel() != accel then
		ply:AddSettings("accel", accel)
	end
	if ply:air_accel() != air_accel then
		ply:AddSettings("air_accel", air_accel)
	end
	if ply:gravity() != gravity then
		ply:AddSettings("gravity", gravity)
	end
	if ply:friction() != friction then
		ply:AddSettings("friction", friction)
	end
	if ply:can_rocketjump() != canrj then
		ply:AddSettings("can_rocketjump", canrj)
	end
end

--TODO Temporary until I make something more convenient
local function Movement_Parkour(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Parkour") then
		SetWalkSpeed(ply, 400)
		SetJumpVelocity(ply, 220)
		SetSettings(ply, 10, 10, 300, 8, false)
		WallJump(ply, mv, cmd)
		WallSlide(ply, mv, cmd)
	end
end

local function Movement_Grapple(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Grapple") then
		SetWalkSpeed(ply, 400)
		SetJumpVelocity(ply, 220)
		SetSettings(ply, 10, 10, 600, 8, false)
		Hook(ply, mv, cmd)
	end
end

local function Movement_Bhop(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Bhop") then
		SetWalkSpeed(ply, 250)
		
		SetJumpVelocity(ply, 290)
		SetSettings(ply, 5, 500, 800, 4, false)
		AutoHop(ply, mv, true)
	end
end

local function Movement_RadioSkate(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "RadioSkate") then
		mv:SetMaxSpeed(150)
		SetWalkSpeed(ply, 250)
		SetJumpVelocity(ply, 250)
		SetSettings(ply, 50, 50, 500, 0, false)
		
	end
end

local function Movement_Momentum(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Momentum") then
		SetSettings(ply, 15, 0, 600, 6, true)
		SetWalkSpeed(ply, 250)
		SetJumpVelocity(ply, 220)
		PM_AirMove( ply, mv, cmd, 1, 0, 150, 1, 320 )
		AutoHop(ply, mv, true)
	end
end

local function Movement_VQ3(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "VQ3") then
		SetSettings(ply, 10, 0, 800, 6, true)
		SetWalkSpeed(ply, 250)
		SetJumpVelocity(ply, 270)
		PM_AirMove( ply, mv, cmd, 1, 1, 0, 1, 400 )
		AutoHop(ply, mv, true)
	end
end

local function Movement_CPMA(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "CPMA") then
		SetSettings(ply, 15, 0, 800, 8, true)
		SetWalkSpeed(ply, 250)
		SetJumpVelocity(ply, 270)
		PM_AirMove( ply, mv, cmd, 1, 2.5, 150, 70, 30 )
		AutoHop(ply, mv, true)
	end
end

local function Movement_Airmove(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Airmove") then
		SetSettings(ply, 10, 500, 600, 6, false)
		SetWalkSpeed(ply, 250)
		SetJumpVelocity(ply, 270)
		AutoHop(ply, mv, true)
		Airsurf:Move(ply, mv, cmd)
	end
end

local function Movement_Pole(ply, mv, cmd)
	if ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Pole") then
		SetSettings(ply, 10, 500, 100, 6, false)
		SetWalkSpeed(ply, 250)
		SetJumpVelocity(ply, 270)
		PoleMove(ply, mv, cmd)
		ButtSlideMove(ply, mv, cmd)
	end
end

hook.Add("SetupMove", "Core_Movement", function(ply, mv, cmd)
	
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	if !ply:OnGround() and !ply:LeftGround() then
		hook.Call("PlayerLeftGround", nil, ply, cmd:TickCount())
	end
	--mv:SetVelocity(mv:GetVelocity() / ply:velocity_scale())
	if ply:WaterLevel() > 1 and !ply:OnGround() then
		WaterMove(ply, mv, ply:accel(), 1)
	end


	ply:air_accel_speed(0)
	
	
	
	
	--print(mv:GetVelocity())
	Movement_Parkour(ply, mv, cmd)
	Movement_Bhop(ply, mv, cmd)
	Movement_Airmove(ply, mv, cmd)
	Movement_RadioSkate(ply, mv, cmd)
	Movement_Grapple(ply, mv, cmd)
	
	if ply:GetGroundEntity() != NULL then
		if !(mv:KeyPressed(IN_JUMP) and !mv:KeyWasDown( IN_JUMP )) then -- Allow bhop
			Friction( ply, mv, cmd, ply:friction() )
			Accelerate( ply, mv, cmd, ply:accel() )
		end
	else
		-- 30 gain is normal.
		if ply:movement_mode() != util.Table.GetByValue(MOVEMENT_MODES, "CPMA") && ply:movement_mode() != util.Table.GetByValue(MOVEMENT_MODES, "VQ3") && ply:movement_mode() != util.Table.GetByValue(MOVEMENT_MODES, "Momentum") && ply:movement_mode() != util.Table.GetByValue(MOVEMENT_MODES, "Airmove") then
			AirAccelerate( ply, mv, cmd, ply:air_accel(), 30 )
		elseif ply:movement_mode() == util.Table.GetByValue(MOVEMENT_MODES, "Airmove") then
			ThreeDAirAccelerate( ply, mv, cmd, ply:air_accel(), 30 )
		end
		Movement_Momentum(ply, mv, cmd)
		Movement_VQ3(ply, mv, cmd)
		Movement_CPMA(ply, mv, cmd)
	end
	
	RampSlide.Slide(ply, mv, cmd)
	
	if ply:top_speed()[ply:movement_mode()] < ply:Speed2D() then
		ply:top_speed()[ply:movement_mode()] = ply:Speed2D()
	end
	Movement_Pole(ply, mv, cmd)
	ply:last_vel(mv:GetVelocity())
	StartGravity(ply, mv, ply:gravity(), Vector(0,0,-1))
	--mv:SetVelocity(mv:GetVelocity() * ply:velocity_scale())
end)

local function DisableNoclip( ply )
	return true
end
hook.Add( "PlayerNoClip", "DisableNoclip", DisableNoclip )