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
		StampObjectNew = function(state, action)
			local guid = action.guid
			if state.currentlyStamping == "" then
				return Cryo.Dictionary.join(
					state,
					{
						currentlyStamping = guid
					}
				)
			end
			
			return state
		end,
		StampSelectedSet = function(state, action)
			local guid = action.guid
			return Cryo.Dictionary.join(
				state,
				{
					selected = guid
				}
			)
		end,
		StampSelectedClear = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					selected = ""
				}
			)
		end,
		StampDeletingSet = function(state, action)
			local guid = action.guid
			return Cryo.Dictionary.join(
				state,
				{
					deleting = guid
				}
			)
		end,
		StampDeletingClear = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					deleting = ""
				}
			)
		end,
		StampFilterSet = function(state, action)
			local filter = action.filter
			return Cryo.Dictionary.join(
				state,
				{
					filter = filter
				}
			)
		end,
		StampIgnoreWaterSet = function(state, action)
			local ignoreWater = action.ignoreWater
			return Cryo.Dictionary.join(
				state,
				{
					ignoreWater = ignoreWater
				}
			)
		end,
		StampIgnoreInvisibleSet = function(state, action)
			local ignoreInvisible = action.ignoreInvisible
			return Cryo.Dictionary.join(
				state,
				{
					ignoreInvisible = ignoreInvisible
				}
			)
		end,
		StampRotationSet = function(state, action)
			local mode = action.mode
			local fixed = action.fixed
			local min = action.min
			local max = action.max
			
			return Cryo.Dictionary.join(
				state,
				{
					rotation = Cryo.Dictionary.join(
						state.rotation,
						{
							mode = mode,
							fixed = fixed,
							min = min,
							max = max
						}
					)
				}
			)
		end,
		StampScaleSet = function(state, action)
			local mode = action.mode
			local fixed = action.fixed
			local min = action.min
			local max = action.max
			
			return Cryo.Dictionary.join(
				state,
				{
					scale = Cryo.Dictionary.join(
						state.scale,
						{
							mode = mode,
							fixed = fixed,
							min = min,
							max = max
						}
					)
				}
			)
		end,
		StampOrientationSet = function(state, action)
			local mode = action.mode
			local custom = action.custom
			
			return Cryo.Dictionary.join(
				state,
				{
					orientation = Cryo.Dictionary.join(
						state.orientation,
						{
							mode = mode,
							custom = custom
						}
					)
				}
			)
		end,
		StampedParentSet = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					stampedParent = action.stampedParent
				}
			)
		end,
		StampCurrentlyStampingSet = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					currentlyStamping = action.guid
				}
			)
		end,
		StampCurrentlyStampingClear = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					currentlyStamping = ""
				}
			)
		end,
		_CopyFromState = function(state, action)
			return action.init.stamp
		end
	}
)