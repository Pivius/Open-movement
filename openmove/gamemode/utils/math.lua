util = util or {}

util.Math = {}

util.Math.Easing = {}
--http://wiki.unity3d.com/index.php/Mathfx
/*
  NAME     - Hermite
  FUNCTION - Ease in and out
  ARGS 		 -
  frac  - Fraction
  from  - Starting value
  to    - End value
*/
function util.Math.Easing.Hermite(frac, from, to)
	return Lerp(frac * frac * (3 - 2 * frac), from, to)
end

/*
  NAME     - Sinerp
  FUNCTION - Easing around the end, when fraction is near one.
  ARGS 		 -
  frac  - Fraction
  from  - Starting value
  to    - End value
*/
function util.Math.Easing.Sinerp(frac, from, to)
	return Lerp(math.sin(frac * math.pi * 0.5), from, to)
end

/*
  NAME     - Coserp
  FUNCTION - Similar to Sinerp, except it eases in, when fraction is near zero, instead of easing out
  ARGS 		 -
  frac  - Fraction
  from  - Starting value
  to    - End value
*/
function util.Math.Easing.Coserp(frac, from, to)
	return Lerp(1 - math.cos(frac * math.pi * 0.5), from, to)
end

/*
  NAME     - Berp
  FUNCTION - Short for 'boing-like interpolation', this method will first overshoot, then waver back and forth around the end fraction before coming to a rest.
  ARGS 		 -
  frac  - Fraction
  from  - Starting value
  to    - End value
*/
function util.Math.Easing.Berp(frac, from, to)
  frac = math.Clamp(frac, 0, 1)
  frac = (math.sin(frac * math.pi * (0.2 + 2.5 * frac * frac * frac)) * math.pow(1 - frac, 2.2) + frac) * (1 + (1.2 * (1 - frac)))
  return from + (to - from) * frac
end

/*
  NAME     - Berp
  FUNCTION - Short for 'boing-like interpolation', this method will first overshoot, then waver back and forth around the end fraction before coming to a rest.
  ARGS 		 -
  frac  - Fraction
  from  - Starting value
  to    - End value
*/
function util.Math.Easing.SmoothStep(x, min, max)
  x = math.Clamp(x, min, max)
  local v1 = (x - min) / (max - min)
  local v2 = (x - min) / (max - min)
  return -2 * v1 * v1 * v1 + 3 * v2 * v2
end

/*
  NAME     - Bounce
  FUNCTION - Returns a value between 0 and 1 that can be used to easily make bouncing effect
  ARGS 		 -
  x - value
*/
function util.Math.Easing.Bounce(x)
  return math.abs(math.sin(6.28 * (x + 1) * (x + 1)) * (1 - x))
end

/*
  NAME     - Approx
  FUNCTION - Test for value that is near specified float.
  ARGS 		 -
  x - value
*/
function util.Math.Easing.Approx(val, about, range)
  return (math.abs(val - about) < range)
end

/*
  NAME     - CLerp
  FUNCTION - it's like lerp but handles the wraparound from 0 to 360
  ARGS 		 -
  x - value
*/
function util.Math.Easing.CLerp(frac, from, to)
  local min, max = 0, 360
  local half = math.abs((max - min) / 2)
  local retval, diff = 0, 0
  if ((to - from) < -half) then
    diff = ((max - from) + to) * frac
    retval = from + diff
  elseif ((to - from) > half) then
    diff = -((max - to) + from) * frac
    retval = from + diff
  else
    retval = from + (to - from) * frac
  end
  return retval
end

local function TestEase()
  local sample_rate = 125
  local start_x = (ScrW() / 2) - sample_rate
  local start_y = (ScrH() / 2)
  surface.SetDrawColor(255,0,0,255)
  for i = 1, 125 do
    surface.DrawLine( start_x+i, start_y, start_x+i - 1 , start_y - ut_ease.Coserp(i/sample_rate, 0, i) )
  end
end

function util.Math.Easing.Constant(c, from, to)
    if from > to then
      return from - c
    elseif from < to then
      return from + c
    end
	return 0
end


util.m = util.Math
ut_math = util.Math

util.Easing = util.Math.Easing
ut_ease = util.Math.Easing
