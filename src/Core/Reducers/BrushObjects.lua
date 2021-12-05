local Plugin = script.Parent.Parent.Parent
local Constants = require(Plugin.Core.Util.Constants)

local Libs = Plugin.Libs
local Cryo = require(Libs.Cryo)
local Rodux = require(Libs.Rodux)
local Utility = require(Plugin.Core.Util.Utility)
local t = require(Libs.t)

local HttpService = game:GetService("HttpService")          

local Immutable = require(Plugin.Core.Util.Immutable)

return Rodux.createReducer(
	-- This will be set by brushtool directly upon loading.
	nil,
	{
		BrushObjectNew = function(state, action)
			local guid = action.guid
			local rbxObject = action.rbxObject
			return Cryo.Dictionary.join(
				state,
				{
					[guid] = {
						rbxObject = rbxObject,
						-- attempt at adding sub-seconds.
						-- Objects may be added in the same second.
						-- This can mess up ordering later on.
						name = rbxObject.Name,
						-- warning: models with 0 parts will return an invalid size.
						-- make sure beforehand that all models have at least one part!
						size = (function()
							local min, max
							if rbxObject:IsA("Model") then
								min, max = Utility.GetModelAABB(rbxObject)
							else
								min, max = Utility.GetPartAABB(rbxObject)
							end
							
							local size =(max-min)
							return Vector3.new(size.x, size.y, size.z)
						end)(),
						timeAdded = os.time(os.date("!*t")) + tick()%1, 
						brushEnabled = true,
						brushCenterMode = "BoundingBox",
						rotation = {
							mode = "NoOverride",
							fixed = 0,
							min = 0,
							max = 360
						},
						scale = {
							mode = "NoOverride",
							fixed = 1,
							min = 1,
							max = 2
						},
						wobble = {
							mode = "NoOverride",
							min = 0,
							max = 30
						},
						verticalOffset = {
							mode = "Auto",
							fixed = 0,
							min = 0,
							max = 1
						},
						orientation = {
							mode  = "NoOverride",
							custom = Vector3.new(0, 1, 0)
						}
					}
				}
			)
		end,
		BrushObjectDelete = function(state, action)
			local guid = action.guid
			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.None
				}
			)
		end,
		BrushObjectEnableAll = function(state, action)
			local newState = Cryo.Dictionary.join(state, {})
			for guid, _ in next, state do
				newState[guid] = Cryo.Dictionary.join(
					newState[guid],
					{
						brushEnabled = true
					}
				)
			end
			
			return newState
		end,
		BrushObjectDisableAll = function(state, action)
			local newState = Cryo.Dictionary.join(state, {})
			for guid, _ in next, state do
				newState[guid] = Cryo.Dictionary.join(
					newState[guid],
					{
						brushEnabled = false
					}
				)
			end
			
			return newState
		end,
		BrushObjectBrushCenterModeSet = function(state, action)
			local guid = action.guid
			local brushCenterMode = action.brushCenterMode

			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.Dictionary.join(
						state[guid],
						{
							brushCenterMode = brushCenterMode
						}
					)
				}
			)
		end,
		BrushObjectRotationSet = function(state, action)
			local guid = action.guid
			local mode = action.mode
			local fixed = action.fixed
			local min = action.min
			local max = action.max

			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.Dictionary.join(
						state[guid],
						{
							rotation = Cryo.Dictionary.join(
								state[guid].rotation,
								{
									mode = mode,
									fixed = fixed,
									min = min,
									max = max
								}
							)
						}
					)
				}
			)
		end,
		BrushObjectScaleSet = function(state, action)
			local guid = action.guid
			local mode = action.mode
			local fixed = action.fixed
			local min = action.min
			local max = action.max
			
			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.Dictionary.join(
						state[guid],
						{
							scale = Cryo.Dictionary.join(
								state[guid].scale,
								{
									mode = mode,
									fixed = fixed,
									min = min,
									max = max
								}
							)
						}
					)
				}
			)
		end,
		BrushObjectWobbleSet = function(state, action)
			local guid = action.guid
			local mode = action.mode
			local min = action.min
			local max = action.max
			
			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.Dictionary.join(
						state[guid],
						{
							wobble = Cryo.Dictionary.join(
								state[guid].wobble,
								{
									mode = mode,
									min = min,
									max = max
								}
							)
						}
					)
				}
			)
		end,
		BrushObjectVerticalOffsetSet = function(state, action)
			local guid = action.guid
			local mode = action.mode
			local fixed = action.fixed
			local min = action.min
			local max = action.max
			
			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.Dictionary.join(
						state[guid],
						{
							verticalOffset = Cryo.Dictionary.join(
								state[guid].verticalOffset,
								{
									mode = mode,
									fixed = fixed,
									min = min,
									max = max
								}
							)
						}
					)
				}
			)
		end,
		BrushObjectOrientationSet = function(state, action)
			local guid = action.guid
			local mode = action.mode
			local custom = action.custom
			
			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.Dictionary.join(
						state[guid],
						{
							orientation = Cryo.Dictionary.join(
								state[guid].orientation,
								{
									mode = mode,
									custom = custom
								}
							)
						}
					)
				}
			)
		end,
		BrushObjectBrushEnabledSet = function(state, action)
			local guid = action.guid
			local brushEnabled = action.brushEnabled
			
			return Cryo.Dictionary.join(
				state,
				{
					[guid] = Cryo.Dictionary.join(
						state[guid],
						{
							brushEnabled = brushEnabled
						}
					)
				}
			)
		end,
		_CopyFromState = function(state, action)
			return action.init.brushObjects
		end
	}
)