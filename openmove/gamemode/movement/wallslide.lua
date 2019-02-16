local PLAYER = FindMetaTable("Player")
local MOVE = FindMetaTable( "CMoveData" )

hookAdd("Init_Player_Vars", "Init_Wallslide", function(ply)
  ply:AddSettings("can_wallslide", true)
  ply:AddSettings("release_time", 0)
  ply:AddSettings("try_slide", true)
  ply:AddSettings("is_sliding", false)
  ply:AddSettings("slide_time", 0)
  ply:AddSettings("slide_prev", {})
  ply:AddSettings("slide_tick", 0)
  ply:AddSettings("slide_vel", 0)
  ply:AddSettings("release_tick", 0)
  print("a")
  ply.ws_sync_module = load.Module( "modules/sync.lua" )
	ply.ws_sync_module.Insert(false, CurTime())
end)
/*
  NAME      - Player:CanWallSlide
  FUNCTION  - Trace and key check to see if the player can wallslide.
  ARGS 			-
		time - Current time
*/
function PLAYER:CanWallSlide(time, keydown)
	if !self:can_wallslide() then return false, false, false end
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
	if ((trFW.HitWorld && !trFW.HitSky) || (trBK.HitWorld && !trBK.HitSky)) && (self:KeyDown(IN_ATTACK2)) && !self:OnGround() then
		return true, trFW.HitWorld, trBK.HitWorld
	end

	return false, false, false
end

/*
  NAME      - Player:StartSlide
  FUNCTION  - Prepares the player for sliding.
  ARGS 			-
		time     - Time
		velocity - Current velocity
		time		 - Current time
*/
function PLAYER:StartSlide(time, velocity, tick, origin)
	-- Update once when the player starts wallsliding.
	-- Only keeping this in for lSD.

	if self:is_sliding() then return end
  if IsFirstTimePredicted() then
    self:slide_prev({slide_time = self:slide_time(), release_time = self:release_time(), slide_vel = self:slide_vel()})
  end
  self:release_tick(0)
  self:slide_tick(tick)
  self:release_time(0)
  self:slide_time(time)
  self:slide_vel(velocity)
  self:slide_vel().z = 0

  self.ws_sync_module.Insert("Preparing", tick, true)
  self:is_sliding(true)
  self.sound:Play()
end

/*
  NAME      - CMoveData:Slide
  FUNCTION  - Updates while sliding.
  ARGS 			-
		ply  - Player
		time - Current time
*/
function MOVE:Slide(ply, time, tick)

	local aim_vec = ply:GetAimVector()
  local slide_time = ply:slide_time()
  local velocity = ply:slide_vel()
  if ply:release_time() > 0 then
    time = ply:release_time()
  end


	aim_vec.z = aim_vec.z*0.1
	local bleed = math.Clamp(5/(time-slide_time+5), 0, 1)
  local aim_vel = (aim_vec * (400 * math.Clamp((time-slide_time)/5, 0, 1)))

	-- Apply velocity bleeding while the player is sliding.

  self:SetVelocity((bleed * velocity) +aim_vel)
  --print(ply.slide_vel)
	ply.ws_sync_module.Insert("Sliding", tick)
end



/*
  NAME      - Player:StopSlide
  FUNCTION  - Stops wallsliding.
*/
function PLAYER:StopSlide(time, tick)
  if !self:is_sliding() then return end
  self:release_time(time)
  self:is_sliding(false)
  self.sound:FadeOut(0.1)
  self.ws_sync_module.Insert("Stopping", tick)
end

hook.Add("WallKicked", "Disable WS on WJ", function(ply, time, tick)
  if !ply.is_sliding then return end
  ply:StopSlide(time, tick)
  ply:try_slide(false) -- Completely disable m2
end)


/*
  NAME      - WallSlide
  FUNCTION  - Gives the player the ability to wallslide when M2/Attack2 is pressed.
  ARGS 			-
		ply - Player
		mv  - CMoveData
	  cmd - CUserCmd
	TODO 			-
		1. Synchronize emergency brake with client
    2. Improve wallslide sync.
    EB Temp disabled
*/
function WallSlide(ply, mv, cmd)
	ply.sound = ply.sound || CreateSound(ply, "physics/body/body_medium_scrape_smooth_loop1.wav")
	local cur_time = CurTime()
	local tick_count = cmd:TickCount()

  ply.ws_sync_module.history_length  = 75
  local can_slide, fwd_trace, bk_trace = ply:CanWallSlide(cur_time)
  if mv:KeyReleased(IN_ATTACK2) && !ply:try_slide() then
    ply:release_tick(tick_count)
    ply:try_slide(true)
    ply.ws_sync_module.Insert("Release", tick_count)

  elseif mv:KeyPressed(IN_ATTACK2) && !ply:try_slide() then

  end

  if ply.wj_sync_module.GetByTime(tick_count) then return end
  if ((can_slide) && ply:try_slide() && !ply:is_sliding() ) && (ply.ws_sync_module.GetByTime(tick_count) != "Sliding") then

    --if mv:KeyWasDown(IN_ATTACK2) then return end
    if !IsFirstTimePredicted() && ply.ws_sync_module.GetLast() == "Release" then
      return
    end
    ply:StartSlide(cur_time, mv:GetVelocity(), tick_count, mv:GetOrigin())

  end
  if (((ply:slide_time()+1 < cur_time) || !can_slide ) && (ply:is_sliding()) )  then
      ply:StopSlide(cur_time, tick_count)
      if (ply:slide_time()+1 < cur_time) then
        ply:try_slide(false)
      end
  end

  if tick_count < ply:slide_tick() && ply:release_tick() != tick_count then
    if ply.ws_sync_module.GetByTime(tick_count) then
      ply:slide_vel(ply:slide_prev().slide_vel)
      ply:slide_time(ply:slide_prev().slide_time)
      ply:release_time(ply:slide_prev().release_time)

    end
  end
  if ((( ply:is_sliding() && can_slide ) || ( ply.ws_sync_module.GetByTime(tick_count) ) ) || (ply.ws_sync_module.GetByTime(tick_count) and !ply:is_sliding())) && ply.ws_sync_module.GetByTime(tick_count) != "Release" then

		mv:Slide(ply, cur_time, tick_count)
	end

	-- Emergency braking, also stops fence riding. Remove these lines to enable fence riding.
  /*
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
	end*/
end
