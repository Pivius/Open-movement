preset = {}
preset.presets = preset.presets || {}
preset.enabled_presets = preset.enabled_presets || {}

/*
  NAME      - load
  FUNCTION  - Loads a preset
  ARGS 			-
    p - Name of the preset to load
		...    - Arguments used in the preset.
*/
function presets.load(p, ...)
  if preset.presets[p] && preset.enabled_presets[p] then
    local args = {...}

    preset.presets[p](unpack(args))
  end
end

/*
  NAME      - enable
  FUNCTION  - Enables an already disabled preset
  ARGS 			-
    p - Name of the preset to enable
*/
function presets.enable(p)
  if preset.loaded_presets[p] && !preset.enabled_presets[p] then
    preset.enabled_presets[p] = true
  end
end

/*
  NAME      - disable
  FUNCTION  - Disables an already enabled preset
  ARGS 			-
    p - Name of the preset to disable
*/
function presets.disable(p)
  if preset.loaded_presets[p] && preset.enabled_presets[p] then
    preset.enabled_presets[p] = false
  end
end

/*
  NAME      - create
  FUNCTION  - Creates a new preset
  ARGS 			-
    p - Name of the preset to disable
    func   . The function the preset will run
*/
function presets.create(p, func)

  preset.presets[p] = func
  preset.enabled_presets[p] = true
end

/*
  NAME      - remove
  FUNCTION  - Removes a preset completely
  ARGS 			-
    p - Name of the preset to remove
*/
function presets.remove(p)
  if preset.presets[p] then
    preset.enabled_presets[p] = nil
    preset.presets[p] = nil
  end
end
