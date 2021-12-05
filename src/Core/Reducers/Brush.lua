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
		BrushSelectedSet = function(state, action)
			local guid = action.guid
			return Cryo.Dictionary.join(
				state,
				{
					selected = guid
				}
			)
		end,
		BrushSelectedClear = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					selected = ""
				}
			)
		end,
		BrushDeletingSet = function(state, action)
			local guid = action.guid
			return Cryo.Dictionary.join(
				state,
				{
					deleting = guid
				}
			)
		end,
		BrushDeletingClear = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					deleting = ""
				}
			)
		end,
		BrushFilterSet = function(state, action)
			local filter = action.filter
			return Cryo.Dictionary.join(
				state,
				{
					filter = filter
				}
			)
		end,
		BrushRadiusSet = function(state, action)
			local radius = action.radius
			return Cryo.Dictionary.join(
				state,
				{
					radius = radius
				}
			)
		end,
		BrushSpacingSet = function(state, action)
			local spacing = action.spacing
			return Cryo.Dictionary.join(
				state,
				{
					spacing = spacing
				}
			)
		end,
		BrushIgnoreWaterSet = function(state, action)
			local ignoreWater = action.ignoreWater
			return Cryo.Dictionary.join(
				state,
				{
					ignoreWater = ignoreWater
				}
			)
		end,
		BrushIgnoreInvisibleSet = function(state, action)
			local ignoreInvisible = action.ignoreInvisible
			return Cryo.Dictionary.join(
				state,
				{
					ignoreInvisible = ignoreInvisible
				}
			)
		end,
		BrushRotationSet = function(state, action)
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
		BrushScaleSet = function(state, action)
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
		BrushWobbleSet = function(state, action)
			local mode = action.mode
			local min = action.min
			local max = action.max
			
			return Cryo.Dictionary.join(
				state,
				{
					wobble = Cryo.Dictionary.join(
						state.wobble,
						{
							mode = mode,
							min = min,
							max = max
						}
					)
				}
			)
		end,
		BrushOrientationSet = function(state, action)
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
		BrushedParentSet = function(state, action)
			return Cryo.Dictionary.join(
				state,
				{
					brushedParent = action.brushedParent
				}
			)
		end,
		_CopyFromState = function(state, action)
			return action.init.brush
		end
	}
)