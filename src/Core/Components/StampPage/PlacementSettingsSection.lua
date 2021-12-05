local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Funcs = require(Plugin.Core.Util.Funcs)

local withTheme = ContextHelper.withTheme

local Actions = Plugin.Core.Actions
local SetStampObjectRotationMode = require(Actions.SetStampObjectRotationMode)
local SetStampObjectRotationFixed = require(Actions.SetStampObjectRotationFixed)
local SetStampObjectRotationMin = require(Actions.SetStampObjectRotationMin)
local SetStampObjectRotationMax = require(Actions.SetStampObjectRotationMax)
local SetStampObjectScaleMode = require(Actions.SetStampObjectScaleMode)
local SetStampObjectScaleFixed = require(Actions.SetStampObjectScaleFixed)
local SetStampObjectScaleMin = require(Actions.SetStampObjectScaleMin)
local SetStampObjectScaleMax = require(Actions.SetStampObjectScaleMax)
local SetStampObjectWobbleMode = require(Actions.SetStampObjectWobbleMode)
local SetStampObjectWobbleMin = require(Actions.SetStampObjectWobbleMin)
local SetStampObjectWobbleMax = require(Actions.SetStampObjectWobbleMax)
local SetStampObjectVerticalOffsetMode = require(Actions.SetStampObjectVerticalOffsetMode)
local SetStampObjectVerticalOffsetFixed = require(Actions.SetStampObjectVerticalOffsetFixed)
local SetStampObjectVerticalOffsetMin = require(Actions.SetStampObjectVerticalOffsetMin)
local SetStampObjectVerticalOffsetMax = require(Actions.SetStampObjectVerticalOffsetMax)
local SetStampObjectOrientationMode = require(Actions.SetStampObjectOrientationMode)
local SetStampObjectOrientationCustom = require(Actions.SetStampObjectOrientationCustom)
local SetStampObjectStampCenterMode = require(Actions.SetStampObjectStampCenterMode)

local rotationFormatCallback = Funcs.rotationFormatCallback
local rotationValidateCallback = Funcs.rotationValidateCallback
local rotationFixedOnFocusLost = Funcs.rotationFixedOnFocusLost
local rotationMinOnFocusLost = Funcs.rotationMinOnFocusLost
local rotationMaxOnFocusLost = Funcs.rotationMaxOnFocusLost
local scaleFormatCallback = Funcs.scaleFormatCallback
local scaleValidateCallback = Funcs.scaleValidateCallback
local scaleFixedOnFocusLost = Funcs.scaleFixedOnFocusLost
local scaleMinOnFocusLost = Funcs.scaleMinOnFocusLost
local scaleMaxOnFocusLost = Funcs.scaleMaxOnFocusLost
local verticalOffsetFormatCallback = Funcs.verticalOffsetFormatCallback
local verticalOffsetValidateCallback = Funcs.verticalOffsetValidateCallback
local verticalOffsetFixedOnFocusLost = Funcs.verticalOffsetFixedOnFocusLost
local verticalOffsetMinOnFocusLost = Funcs.verticalOffsetMinOnFocusLost
local verticalOffsetMaxOnFocusLost = Funcs.verticalOffsetMaxOnFocusLost
local formatVector3 = Funcs.formatVector3
local orientationFormatCallback = Funcs.orientationFormatCallback
local orientationValidateCallback = Funcs.orientationValidateCallback
local orientationCustomOnFocusLost = Funcs.orientationCustomOnFocusLost

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local CheckboxField = require(Foundation.CheckboxField)
local DropdownField = require(Foundation.DropdownField)
local TextField = require(Foundation.TextField)
local NumericalSliderField = require(Foundation.NumericalSliderField)

local PlacementSettingsSection = Roact.PureComponent:extend("PlacementSettingsSection")

function PlacementSettingsSection:init()
	self:setState{
	}
end

function PlacementSettingsSection:render()
	local props = self.props
	
	if not props.guid then
		return
	end
	
	local Visible = props.Visible
	local orientation = props.orientation
	local guid = props.guid
	local rotation = props.rotation
	local scale = props.scale
	local wobble = props.wobble
	local orientation = props.orientation
	local verticalOffset = props.verticalOffset
	
	
	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end

	local labelWidth = Constants.FIELD_LABEL_WIDTH
	
	return Roact.createElement(
		VerticalList,
		{
			width = UDim.new(1, 0),
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			PaddingTopPixel = 4,
			PaddingBottomPixel = 4,
			ElementPaddingPixel = 4		
		},
		{
			Rotation = Roact.createElement(
				DropdownField,
				{
					label = "Rotation",
					indentLevel = 0,
					labelWidth = labelWidth,
					entries = {
						{ id = "None", text = "Do not rotate" },
						{ id = "ClickAndDrag", text = "Click and Drag" },
						{ id = "Random", text = "Random" },
						{ id = "Fixed", text = "Fixed" }
					},
					selectedId = rotation.mode,
					LayoutOrder = generateSequentialLayoutOrder(),
					onSelected = function(mode) props.setRotationMode(guid, mode) end
				}
			),
			RotationFixed = rotation.mode == "Fixed" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Angle",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_ROTATION,
					maxValue = Constants.MAX_ROTATION,
					textboxWidthPixel = 50,
					valueRound = 0.1,
					valueSnap = 15,
					value = rotation.fixed,
					onValueChanged = function(newValue)
						props.setRotationFixed(guid, newValue)
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 1,
					maxCharacters = 6
				}
			),
			RotationMin = rotation.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Min Angle",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_ROTATION,
					maxValue = Constants.MAX_ROTATION,
					textboxWidthPixel = 50,
					valueRound = 0.1,
					valueSnap = 15,
					value = rotation.min,
					onValueChanged = function(newValue)
						props.setRotationMin(guid, newValue)
						if newValue > rotation.max then
							props.setRotationMax(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 1,
					maxCharacters = 6
				}
			),
			RotationMax = rotation.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Max Angle",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_ROTATION,
					maxValue = Constants.MAX_ROTATION,
					textboxWidthPixel = 50,
					valueRound = 0.1,
					valueSnap = 15,
					value = rotation.max,
					onValueChanged = function(newValue)
						props.setRotationMax(guid, newValue)
						if newValue < rotation.min then
							props.setRotationMin(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 1,
					maxCharacters = 6
				}
			),
			Scale = Roact.createElement(
				DropdownField,
				{
					label = "Scale",
					indentLevel = 0,
					labelWidth = labelWidth,
					entries = {
						{ id = "None", text = "Do not scale" },
						{ id = "Fixed", text = "Fixed" },
						{ id = "Random", text = "Random" },
					},
					selectedId = scale.mode,
					LayoutOrder = generateSequentialLayoutOrder(),
					onSelected = function(mode) props.setScaleMode(guid, mode) end
				}
			),
			ScaleFixed = scale.mode == "Fixed" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Factor",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_SCALE,
					maxValue = Constants.MAX_SCALE,
					textboxWidthPixel = 50,
					valueRound = 0.01,
					valueSnap = 0.1,
					value = scale.fixed,
					onValueChanged = function(newValue)
						props.setScaleFixed(guid, newValue)
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			ScaleMin = scale.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Min Factor",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_SCALE,
					maxValue = Constants.MAX_SCALE,
					textboxWidthPixel = 50,
					valueRound = 0.01,
					valueSnap = 0.1,
					value = scale.min,
					onValueChanged = function(newValue)
						props.setScaleMin(guid, newValue)
						if newValue > scale.max then
							props.setScaleMax(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			ScaleMax = scale.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Max Factor",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_SCALE,
					maxValue = Constants.MAX_SCALE,
					textboxWidthPixel = 50,
					valueRound = 0.01,
					valueSnap = 0.1,
					value = scale.max,
					onValueChanged = function(newValue)
						props.setScaleMax(guid, newValue)
						if newValue < scale.min then
							props.setScaleMin(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			Wobble = Roact.createElement(
				DropdownField,
				{
					label = "Wobble",
					indentLevel = 0,
					labelWidth = labelWidth,
					entries = {
						{ id = "None", text = "Do not wobble" },
						{ id = "Random", text = "Random" },
					},
					selectedId = wobble.mode,
					LayoutOrder = generateSequentialLayoutOrder(),
					onSelected = function(mode) props.setWobbleMode(guid, mode) end
				}
			),
			WobbleMin = wobble.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Min Angle",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_WOBBLE,
					maxValue = Constants.MAX_WOBBLE,
					textboxWidthPixel = 50,
					valueRound = 0.1,
					valueSnap = 5,
					value = wobble.min,
					onValueChanged = function(newValue)
						props.setWobbleMin(guid, newValue)
						if newValue > wobble.max then
							props.setWobbleMax(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			WobbleMax = wobble.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Max Angle",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_WOBBLE,
					maxValue = Constants.MAX_WOBBLE,
					textboxWidthPixel = 50,
					valueRound = 0.1,
					valueSnap = 5,
					value = wobble.max,
					onValueChanged = function(newValue)
						props.setWobbleMax(guid, newValue)
						if newValue < wobble.min then
							props.setWobbleMin(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			Orientation = Roact.createElement(
				DropdownField,
				{
					label = "Orientation",
					indentLevel = 0,
					labelWidth = labelWidth,
					entries = {
						{ id = "Normal", text = "Normal" },
						{ id = "Up", text = "Up" },
						{ id = "Custom", text = "Custom" }
					},
					selectedId = orientation.mode,
					LayoutOrder = generateSequentialLayoutOrder(),
					onSelected = function(mode) props.setOrientationMode(guid, mode) end
				}
			),
			OrientationCustom = orientation.mode == "Custom" and Roact.createElement(
				TextField,
				{
					label = "Direction",
					indentLevel = 1,
					labelWidth = labelWidth,
					textInput = formatVector3(orientation.custom.x, orientation.custom.y, orientation.custom.z),
					LayoutOrder = generateSequentialLayoutOrder(),
					textFormatCallback = orientationFormatCallback,
					onFocusLost = orientationCustomOnFocusLost(
						orientation.custom, 
						function(custom) props.setOrientationCustom(guid, custom) 
					end),
					newTextValidateCallback = orientationValidateCallback
				}
			),
			VerticalOffset = Roact.createElement(
				DropdownField,
				{
					label = "Vertical Offset",
					indentLevel = 0,
					labelWidth = labelWidth,
					entries = {
						{ id = "Auto", text = "Auto" },
						{ id = "Fixed", text = "Fixed" },
						{ id = "Random", text = "Random" },
					},
					selectedId = verticalOffset.mode,
					LayoutOrder = generateSequentialLayoutOrder(),
					onSelected = function(mode) props.setOffsetMode(guid, mode) end
				}
			),
			VerticalOffsetFixed = verticalOffset.mode == "Fixed" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Studs",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_VERTICAL_OFFSET,
					maxValue = Constants.MAX_VERTICAL_OFFSET,
					textboxWidthPixel = 50,
					valueRound = 0.01,
					valueSnap = 1,
					value = verticalOffset.fixed,
					onValueChanged = function(newValue)
						props.setOffsetFixed(guid, newValue)
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			VerticalOffsetMin = verticalOffset.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Min Studs",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_VERTICAL_OFFSET,
					maxValue = Constants.MAX_VERTICAL_OFFSET,
					textboxWidthPixel = 50,
					valueRound = 0.01,
					valueSnap = 1,
					value = verticalOffset.min,
					onValueChanged = function(newValue)
						props.setOffsetMin(guid, newValue)
						if newValue > verticalOffset.max then
							props.setOffsetMax(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			VerticalOffsetMax = verticalOffset.mode == "Random" and Roact.createElement(
				NumericalSliderField,
				{
					label = "Max Studs",
					indentLevel = 1,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_VERTICAL_OFFSET,
					maxValue = Constants.MAX_VERTICAL_OFFSET,
					textboxWidthPixel = 50,
					valueRound = 0.01,
					valueSnap = 1,
					value = verticalOffset.max,
					onValueChanged = function(newValue)
						props.setOffsetMax(guid, newValue)
						if newValue < verticalOffset.min then
							props.setOffsetMin(guid, newValue)
						end
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 2,
					maxCharacters = 6
				}
			),
			CenterMode = Roact.createElement(
				DropdownField,
				{
					label = "Centered At",
					indentLevel = 0,
					labelWidth = labelWidth,
					entries = {
						{ id = "BoundingBox", text = "Bounding Box" },
						{ id = "PrimaryPart", text = "Primary Part" }
					},
					selectedId = props.centerMode,
					LayoutOrder = generateSequentialLayoutOrder(),
					enabled = props.hasPrimaryPart,
					onSelected = function(mode) props.setCenterMode(guid, mode) end,
				}
			)
		}
	)
end

local function mapStateToProps(state, props)	
	local stamp = state.stamp
	local currentlyStamping = stamp.currentlyStamping
	local stampObjects = state.stampObjects
	local object = stampObjects[currentlyStamping]
	if object then
		local rbxObject = object.rbxObject
		return {
			rotation = object.rotation,
			scale = object.scale,
			wobble = object.wobble,
			orientation = object.orientation,
			verticalOffset = object.verticalOffset,
			centerMode = object.stampCenterMode,
			guid = currentlyStamping,
			hasPrimaryPart = rbxObject:IsA("Model") and rbxObject.PrimaryPart ~= nil
		}
	else
		return {
			guid = nil
		}
	end
end

local function mapDispatchToProps(dispatch)
	return {
		setRotationMode = function(guid, mode) dispatch(SetStampObjectRotationMode(guid, mode)) end,
		setRotationFixed = function(guid, fixed) dispatch(SetStampObjectRotationFixed(guid, fixed)) end,
		setRotationMin = function(guid, min) dispatch(SetStampObjectRotationMin(guid, min)) end,
		setRotationMax = function(guid, max) dispatch(SetStampObjectRotationMax(guid, max)) end,
		setScaleMode = function(guid, mode) dispatch(SetStampObjectScaleMode(guid, mode)) end,
		setScaleFixed = function(guid, fixed) dispatch(SetStampObjectScaleFixed(guid, fixed)) end,
		setScaleMin = function(guid, min) dispatch(SetStampObjectScaleMin(guid, min)) end,
		setScaleMax = function(guid, max) dispatch(SetStampObjectScaleMax(guid, max)) end,
		setWobbleMode = function(guid, mode) dispatch(SetStampObjectWobbleMode(guid, mode)) end,
		setWobbleMin = function(guid, min) dispatch(SetStampObjectWobbleMin(guid, min)) end,
		setWobbleMax = function(guid, max) dispatch(SetStampObjectWobbleMax(guid, max)) end,
		setOffsetMode = function(guid, mode) dispatch(SetStampObjectVerticalOffsetMode(guid, mode)) end,
		setOffsetFixed = function(guid, fixed) dispatch(SetStampObjectVerticalOffsetFixed(guid, fixed)) end,
		setOffsetMin = function(guid, min) dispatch(SetStampObjectVerticalOffsetMin(guid, min)) end,
		setOffsetMax = function(guid, max) dispatch(SetStampObjectVerticalOffsetMax(guid, max)) end,
		setOrientationMode = function(guid, mode) dispatch(SetStampObjectOrientationMode(guid, mode)) end,
		setOrientationCustom = function(guid, custom) dispatch(SetStampObjectOrientationCustom(guid, custom)) end,
		setCenterMode = function(guid, centerMode) dispatch(SetStampObjectStampCenterMode(guid, centerMode)) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(PlacementSettingsSection)