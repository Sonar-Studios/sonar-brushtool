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
local SetBrushRotationMode = require(Actions.SetBrushRotationMode)
local SetBrushRotationFixed = require(Actions.SetBrushRotationFixed)
local SetBrushRotationMin = require(Actions.SetBrushRotationMin)
local SetBrushRotationMax = require(Actions.SetBrushRotationMax)
local SetBrushScaleMode = require(Actions.SetBrushScaleMode)
local SetBrushScaleFixed = require(Actions.SetBrushScaleFixed)
local SetBrushScaleMin = require(Actions.SetBrushScaleMin)
local SetBrushScaleMax = require(Actions.SetBrushScaleMax)
local SetBrushWobbleMode = require(Actions.SetBrushWobbleMode)
local SetBrushWobbleMin = require(Actions.SetBrushWobbleMin)
local SetBrushWobbleMax = require(Actions.SetBrushWobbleMax)
local SetBrushOrientationMode = require(Actions.SetBrushOrientationMode)
local SetBrushOrientationCustom = require(Actions.SetBrushOrientationCustom)

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
	local Visible = props.Visible
	local rotation = props.rotation
	local scale = props.scale
	local wobble = props.wobble
	local orientation = props.orientation
	
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
			Visible = Visible,
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
						{ id = "Fixed", text = "Fixed" },
						{ id = "Random", text = "Random" },
					},
					selectedId = rotation.mode,
					LayoutOrder = generateSequentialLayoutOrder(),
					onSelected = function(mode) props.setRotationMode(mode) end
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
						props.setRotationFixed(newValue)
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
						props.setRotationMin(newValue)
						if newValue > rotation.max then
							props.setRotationMax(newValue)
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
						props.setRotationMax(newValue)
						if newValue < rotation.min then
							props.setRotationMin(newValue)
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
					onSelected = function(mode) props.setScaleMode(mode) end
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
						props.setScaleFixed(newValue)
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
						props.setScaleMin(newValue)
						if newValue > scale.max then
							props.setScaleMax(newValue)
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
						props.setScaleMax(newValue)
						if newValue < scale.min then
							props.setScaleMin(newValue)
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
					onSelected = function(mode) props.setWobbleMode(mode) end
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
						props.setWobbleMin(newValue)
						if newValue > wobble.max then
							props.setWobbleMax(newValue)
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
						props.setWobbleMax(newValue)
						if newValue < wobble.min then
							props.setWobbleMin(newValue)
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
					onSelected = function(mode) props.setOrientationMode(mode) end
				}
			),
			OrientationCustom = orientation.mode == "Custom" and  Roact.createElement(
				TextField,
				{
					label = "Direction",
					indentLevel = 1,
					labelWidth = labelWidth,
					textInput = formatVector3(orientation.custom.x, orientation.custom.y, orientation.custom.z),
					LayoutOrder = generateSequentialLayoutOrder(),
					textFormatCallback = orientationFormatCallback,
					onFocusLost = orientationCustomOnFocusLost(orientation.custom, props.setOrientationCustom),
					newTextValidateCallback = orientationValidateCallback
				}
			)
		}
	)
end

local function mapStateToProps(state, props)
	local brush = state.brush
	return {
		rotation = brush.rotation,
		scale = brush.scale,
		wobble = brush.wobble,
		orientation = brush.orientation,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setRotationMode = function(mode) dispatch(SetBrushRotationMode(mode)) end,
		setRotationFixed = function(fixed) dispatch(SetBrushRotationFixed(fixed)) end,
		setRotationMin = function(min) dispatch(SetBrushRotationMin(min)) end,
		setRotationMax = function(max) dispatch(SetBrushRotationMax(max)) end,
		setScaleMode = function(mode) dispatch(SetBrushScaleMode(mode)) end,
		setScaleFixed = function(fixed) dispatch(SetBrushScaleFixed(fixed)) end,
		setScaleMin = function(min) dispatch(SetBrushScaleMin(min)) end,
		setScaleMax = function(max) dispatch(SetBrushScaleMax(max)) end,
		setWobbleMode = function(mode) dispatch(SetBrushWobbleMode(mode)) end,
		setWobbleMin = function(min) dispatch(SetBrushWobbleMin(min)) end,
		setWobbleMax = function(max) dispatch(SetBrushWobbleMax(max)) end,
		setOrientationMode = function(mode) dispatch(SetBrushOrientationMode(mode)) end,
		setOrientationCustom = function(custom) dispatch(SetBrushOrientationCustom(custom)) end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(PlacementSettingsSection)