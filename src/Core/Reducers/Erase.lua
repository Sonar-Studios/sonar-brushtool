local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Core.Util.Constants)

local Libs = Plugin.Libs
local Cryo = require(Libs.Cryo)
local Rodux = require(Libs.Rodux)
local t = require(Libs.t)

local HttpService = game:GetService("HttpService")

local Immutable = require(Plugin.Core.Util.Immutable)

return Rodux.createReducer(
	-- This will be set by brushtool directly upon loading.
	nil,
	{
		EraseRadiusSet = function(state, action)
			local radius = action.radius
			return Cryo.Dictionary.join(
				state,
				{
					radius = radius
				}
			)
		end,
		EraseIgnoreWaterSet = function(state, action)
			local ignoreWater = action.ignoreWater
			return Cryo.Dictionary.join(
				state,
				{
					ignoreWater = ignoreWater
				}
			)
		end,
		EraseIgnoreInvisibleSet = function(state, action)
			local ignoreInvisible = action.ignoreInvisible
			return Cryo.Dictionary.join(
				state,
				{
					ignoreInvisible = ignoreInvisible
				}
			)
		end,
		_CopyFromState = function(state, action)
			return action.init.erase
		end
	}
)