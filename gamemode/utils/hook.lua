customHook = customHook or {}
customHook.event = customHook.event or {}

function hookRemove(event, identifier)
  if !event or !identifier then return end
  customHook.event[event][identifier] = nil
end

function hookAdd(event, identifier, func)
  if !event or !identifier or !func then return end
  if !customHook.event[event] then
		customHook.event[event] = {}
	end
  customHook.event[event][identifier] = func
end

function hookCall(event, ...)
  if !event then return end
  local vararg = {...}
  if !vararg then
    vararg = {}
  end

  if customHook.event[event] then
    for ident,func in pairs(customHook.event[event]) do
      func(unpack(vararg))
    end

  end
end

function hookCallByIdent(event, identifier, ...)
  if !event or !identifier then return end
  local vararg = {...}
  if !vararg then
    vararg = {}
  end
  if customHook.event[event][identifier] then
    return customHook.event[event][identifier](unpack(vararg))
  end
end
