local Plugin = script.Parent.Parent.Parent
local Libs = Plugin.Libs
local Utility = require(Plugin.Core.Util.Utility)
local Constants = require(Plugin.Core.Util.Constants)

local function rotationFixedOnFocusLost(fixed, dispatch)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_ROTATION, Constants.MAX_ROTATION), 0.01)
			dispatch(num)
			return tostring(num)
		else
			return tostring(fixed)
		end
	end
end

local function rotationMinOnFocusLost(min, max, dispatchMin, dispatchMax)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_ROTATION, Constants.MAX_ROTATION), 0.01)
			dispatchMin(num)
			if num > max then
				dispatchMax(num)
			end
			return tostring(num)
		else
			return tostring(min)
		end
	end
end

local function rotationMaxOnFocusLost(min, max, dispatchMin, dispatchMax)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_ROTATION, Constants.MAX_ROTATION), 0.01)
			dispatchMax(num)
			if num < min then
				dispatchMin(num)
			end
			return tostring(num)
		else
			return tostring(max)
		end
	end
end

local function scaleFixedOnFocusLost(fixed, dispatch)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_SCALE, Constants.MAX_SCALE), 0.01)
			dispatch(num)
			return tostring(num)
		else
			return tostring(fixed)
		end
	end
end

local function scaleMinOnFocusLost(min, max, dispatchMin, dispatchMax)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_SCALE, Constants.MAX_SCALE), 0.01)
			dispatchMin(num)
			if num > max then
				dispatchMax(num)
			end
			return tostring(num)
		else
			return tostring(min)
		end
	end
end

local function scaleMaxOnFocusLost(min, max, dispatchMin, dispatchMax)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_SCALE, Constants.MAX_SCALE), 0.01)
			dispatchMax(num)
			if num < min then
				dispatchMin(num)
			end
			return tostring(num)
		else
			return tostring(max)
		end
	end
end

local function verticalOffsetFixedOnFocusLost(fixed, dispatch)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET), 0.01)
			dispatch(num)
			return tostring(num)
		else
			return tostring(fixed)
		end
	end
end

local function verticalOffsetMinOnFocusLost(min, max, dispatchMin, dispatchMax)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET), 0.01)
			dispatchMin(num)
			if num > max then
				dispatchMax(num)
			end
			return tostring(num)
		else
			return tostring(min)
		end
	end
end

local function verticalOffsetMaxOnFocusLost(min, max, dispatchMin, dispatchMax)
	return function(t)
		local num = tonumber(t)
		if num then
			num = Utility.Round(math.clamp(num, Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET), 0.01)
			dispatchMax(num)
			if num < min then
				dispatchMin(num)
			end
			return tostring(num)
		else
			return tostring(max)
		end
	end
end

local function truncateTrailingDecimal(n, precision)
	local s, _ = string.format("%." .. precision .. "f", n):gsub("%.?0+$", "")
	
	return s
end

local function formatVector3(x, y, z)
	return string.format(
		"%s, %s, %s", 
		truncateTrailingDecimal(x, 3), 
		truncateTrailingDecimal(y, 3), 
		truncateTrailingDecimal(z, 3)
	)
end

local function orientationCustomOnFocusLost(custom, dispatch)
	return function(t)
		local x, y, z = string.match(t, "^%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*$")
		if not x or not y or not z then
			x, y, z = string.match(t, "^ *([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+) *$")
		end
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		if x and y and z then
			x, y, z = Utility.Round(x, 0.001), Utility.Round(y, 0.001), Utility.Round(z, 0.001)
			if x ~= 0 or y ~= 0 or z ~= 0 then
				local v = Vector3.new(x, y, z)
				dispatch(v)
				return formatVector3(v.x, v.y, v.z)
			else
				return formatVector3(custom.x, custom.y, custom.z)
			end
		else
			return formatVector3(custom.x, custom.y, custom.z)
		end
	end
end

local function rotationFormatCallback(t)
	return string.format("%s°", t)
end

local function rotationValidateCallback(t)
	return t:match("^[%d%s.-]*$") ~= nil
end

local function scaleFormatCallback(t)
	return string.format("%s×", t)
end

local function scaleValidateCallback(t)
	return t:match("^[%d%s.]*$") ~= nil
end

local function verticalOffsetFormatCallback(t)
	return string.format("%s studs", t)
end

local function verticalOffsetValidateCallback(t)
	return t:match("^[%d%s.-]*$") ~= nil
end

local function orientationFormatCallback(t)
	local x, y, z = string.match(t, "^%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*$")
	if not x or not y or not z then
		x, y, z = string.match(t, "^ *([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+) *$")
	end
	x, y, z = tonumber(x), tonumber(y), tonumber(z)
	x, y, z = Utility.Round(x, 0.001), Utility.Round(y, 0.001), Utility.Round(z, 0.001)
	return formatVector3(x, y, z)
end

local function orientationValidateCallback(t)
	return t:match("^[%d%s.,-]*$") ~= nil
end

return {
	rotationFixedOnFocusLost = rotationFixedOnFocusLost,
	rotationMinOnFocusLost = rotationMinOnFocusLost,
	rotationMaxOnFocusLost = rotationMaxOnFocusLost,
	scaleFixedOnFocusLost = scaleFixedOnFocusLost,
	scaleMinOnFocusLost = scaleMinOnFocusLost,
	scaleMaxOnFocusLost = scaleMaxOnFocusLost,
	verticalOffsetFixedOnFocusLost = verticalOffsetFixedOnFocusLost,
	verticalOffsetMinOnFocusLost = verticalOffsetMinOnFocusLost,
	verticalOffsetMaxOnFocusLost = verticalOffsetMaxOnFocusLost,
	orientationCustomOnFocusLost = orientationCustomOnFocusLost,
	rotationFormatCallback = rotationFormatCallback,
	rotationValidateCallback = rotationValidateCallback,
	scaleFormatCallback = scaleFormatCallback,
	scaleValidateCallback = scaleValidateCallback,
	verticalOffsetFormatCallback = verticalOffsetFormatCallback,
	verticalOffsetValidateCallback = verticalOffsetValidateCallback,
	orientationFormatCallback = orientationFormatCallback,
	orientationValidateCallback = orientationValidateCallback,
	formatVector3 = formatVector3
}