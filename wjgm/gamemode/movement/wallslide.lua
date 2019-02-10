local PLAYER = FindMetaTable("Player")
local MOVE = FindMetaTable( "CMoveData" )
hook.Add("OnEntityCreated","WallSlide_InitPlayer",function(ply)
  local plMeta = getmetatable(ply)
	if plMeta!=FindMetaTable("Player") then
    return
  end
  // Player variables
  ply.can_wallslide = true
  ply.is_sliding = false
	ply.slide_time = 0
	ply.sync_samples_wallslide = {}
end)

/*
  NAME      - Player:CanWallSlide
  FUNCTION  - Trace and key check to see if the player can wallslide.
  ARGS 			-
		tick - Current tickrate
*/
function PLAYER:CanWallSlide(tick)
	if !self.can_wallslide then return false, false, false end
	local tracedata = {}
	tracedata.start = self:EyePos()
	tracedata.endpos = self:EyePos()+(self:GetAimVector()*40)
	tracedata.filter = self
	local trFW = util.TraceLine(tracedata)

	local tracedata = {}
	tracedata.start = self:EyePos()
	tracedata.endpos = self:EyePos()+(self:GetAimVector()*-40)
	tracedata.filter = self

	local trBK = util.TraceLine(tracedata)

	// Found something to grab onto
	if ((trFW.HitWorld && !trFW.HitSky) || (trBK.HitWorld && !trBK.HitSky)) && (trFW.Fraction < 1 || trBK.Fraction < 1) then
		if self:KeyDown(IN_ATTACK2) && !self:OnGround() then

			return true, trFW.HitWorld, trBK.HitWorld
		end
	end
	return false, false, false
end

/*
  NAME      - Player:StartSlide
  FUNCTION  - Prepares the player for sliding.
  ARGS 			-
		time     - Player
		velocity - Current velocity
		tick		 - Current tickrate
*/
function PLAYER:StartSlide(time, velocity, tick)
	-- Update once when the player starts wallsliding.
	-- Only keeping this in for lSD.
	if self.is_sliding && IsFirstTimePredicted() then return end
		self.slide_time = time
		self.slide_vel = velocity
		self.slide_vel.z = 0
		if !self.ebtimer || self.ebtimer < time || self.eb > 3 then
			self.eb = 0
			self.ebtimer = time + 0.65
		end
		self.is_sliding = true
	if !table.HasValue(self.sync_samples_wallslide, tick) then
		table.insert(self.sync_samples_wallslide, 1, tick)
	end
end

/*
  NAME      - CMoveData:Slide
  FUNCTION  - Updates while sliding.
  ARGS 			-
		ply  - Player
		tick - Current tickrate
*/
function MOVE:Slide(ply, tick)
  ply.sound:Play()
	local aimvec = ply:GetAimVector()
	aimvec.z = aimvec.z*0.1
	local bleed = math.max(5/(CurTime()-ply.slide_time+5), 0)
	-- Apply velocity bleeding while the player is sliding.
  self:SetVelocity(((bleed * ply.slide_vel) + (aimvec * (400 * math.min((CurTime()-ply.slide_time)/5, 1)))))
	if !table.HasValue(ply.sync_samples_wallslide, tick) then
		table.insert(ply.sync_samples_wallslide, 1, tick)
	end
end

/*
  NAME      - Player:StopSlide
  FUNCTION  - Stops wallsliding.
*/
function PLAYER:StopSlide()
	if !self.is_sliding then return end
  self.is_sliding = false
  self.sound:FadeOut(0.1)
end

/*
  NAME      - WallSlide
  FUNCTION  - Gives the player the ability to wallslide when M2/Attack2 is pressed.
  ARGS 			-
		ply - Player
		mv  - CMoveData
	  cmd - CUserCmd
	TODO 			-
		1. Improve synchronization
		2. Synchronize emergency brake with client
*/
function WallSlide(ply, mv, cmd)
	ply.sound = ply.sound || CreateSound(ply, "physics/body/body_medium_scrape_smooth_loop1.wav")
	local cur_time = CurTime()
	local tick_count = cmd:TickCount()
	local can_slide, fwd_trace, bk_trace = ply:CanWallSlide(tick_count)
	if #ply.sync_samples_wallslide > 0 then
		if #ply.sync_samples_wallslide >= 10 then
			table.remove(ply.sync_samples_wallslide, #ply.sync_samples_wallslide)
		end
	end
	if (!can_slide || (ply.slide_time+10 < cur_time && ply.is_sliding)) || table.HasValue(ply.sync_samples_walljump, tick_count) then
		ply:StopSlide()
		return
	end
	if can_slide then
		ply:StartSlide(cur_time, mv:GetVelocity(), tick_count)
	end
	if (ply.is_sliding && can_slide) || table.HasValue(ply.sync_samples_wallslide, tick_count)  then
		mv:Slide(ply, tick_count)
	end
	-- Emergency braking, also stops fence riding. Remove these lines to enable fence riding.
	if ply.ebtimer then
		if ply.ebtimer > cur_time && ply:KeyPressed(IN_ATTACK2) then
			if IsFirstTimePredicted() then
				ply.eb = ply.eb +1
				if ply.eb >= 3 then
					ply.is_sliding = false
					ply.sound:FadeOut(0.1)
					mv:SetVelocity(ply:GetAimVector()*400)
				end
			end
		end
	end
end
