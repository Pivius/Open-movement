local sync = {}
sync.history_length = 15
sync.history = {}
sync.prev_time = CurTime()

function sync.RemoveFirst()
  for k, v in pairs(sync.history) do
    if k < table.Count(sync.history) then
      sync.history[k] = sync.history[k+1]
    else
      sync.history[k] = nil
    end
  end
end

function sync.Insert(action, time)
  if !time then time = CurTime() end
	if IsFirstTimePredicted() then
    if sync.prev_time < time then
  		sync.history[table.Count(sync.history)+1] = {[time] = action}
      sync.prev_time = time
      if table.Count(sync.history) > sync.history_length then
        sync.RemoveFirst()
      end
    end
	end
end

function sync.GetByKey(key, time)
  if !key then key = table.Count(sync.history) end
  if !time then time = sync.prev_time end
  if !sync.history[key] then return 0 end
  if !sync.history[key][time] then return 0 end
  return sync.history[key][time]
end

function sync.GetByTime(req_time)
  for _, tbl in ipairs( sync.history ) do
    for time, action in pairs(tbl) do
      if time == req_time then
        return action
      end
    end
  end
  return false
end

function sync.GetLast()
  for _, tbl in ipairs( sync.history ) do
    for time, action in pairs(tbl) do
      if time == sync.prev_time then
        return action
      end
    end
  end
  return false
end

function sync.GetLastTime()
  local highest = 0
  for _, tbl in ipairs( sync.history ) do
    for time, action in pairs(tbl) do
      if time > highest then
        highest = time
      end
    end
  end
  return highest
end

function sync.ClientCheck(tick)
  local compare = CurTime()
  if tick then
    compare = engine.TickCount()
  end
  return CLIENT and sync.GetByTime(compare)
end

function sync.GetDelta(time, compare)
   if !compare then compare = sync.prev_time end
  return time - compare
end

return sync
