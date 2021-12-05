local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withBrushtool = ContextHelper.withBrushtool

local Actions = Plugin.Core.Actions
local SetBrushRadius = require(Actions.SetBrushRadius)
local SetBrushSpacing = require(Actions.SetBrushSpacing)
local SetBrushIgnoreWater = require(Actions.SetBrushIgnoreWater)
local SetBrushIgnoreInvisible = require(Actions.SetBrushIgnoreInvisible)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local CheckboxField = require(Foundation.CheckboxField)
local DropdownField = require(Foundation.DropdownField)
local TextField = require(Foundation.TextField)
local NumericalSliderField = require(Foundation.NumericalSliderField)

local BrushSettingsSection = Roact.PureComponent:extend("BrushSettingsSection")

function BrushSettingsSection:render()
	local props = self.props
	local Visible = props.Visible
	
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
			Radius = Roact.createElement(
				NumericalSliderField,
				{
					label = "Radius",
					indentLevel = 0,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_RADIUS,
					maxValue = Constants.MAX_RADIUS,
					textboxWidthPixel = 50,
					valueRound = 0.1,
					valueSnap = 1,
					value = props.radius,
					onValueChanged = function(newValue)
						props.setRadius(newValue)
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 1,
					maxCharacters = 6
				}
			),
			Spacing = Roact.createElement(
				NumericalSliderField,
				{
					label = "Spacing",
					indentLevel = 0,
					labelWidth = labelWidth,
					LayoutOrder = generateSequentialLayoutOrder(),
					minValue = Constants.MIN_SPACING,
					maxValue = Constants.MAX_SPACING,
					textboxWidthPixel = 50,
					valueRound = 0.1,
					valueSnap = 1,
					value = props.spacing,
					onValueChanged = function(newValue)
						props.setSpacing(newValue)
					end,
					isValueIntegral = false,
					decimalPlacesToShow = 1,
					maxCharacters = 6
				}
			),
			IgnoreWater = Roact.createElement(
				CheckboxField,
				{
					label = "Ignore Water",
					indentLevel = 0,
					labelWidth = labelWidth,
					checked = props.ignoreWater,
					LayoutOrder = generateSequentialLayoutOrder(),
					onToggle = function() props.setIgnoreWater(not props.ignoreWater) end
				}
			),
			IgnoreInvisible = Roact.createElement(
				CheckboxField,
				{
					label = "Ignore Invisible",
					indentLevel = 0,
					labelWidth = labelWidth,
					checked = props.ignoreInvisible,
					LayoutOrder = generateSequentialLayoutOrder(),
					onToggle = function() props.setIgnoreInvisible(not props.ignoreInvisible) end
				}
			)
		}
	)
end

local function mapStateToProps(state, props)
	local brush = state.brush
	return {
		radius = brush.radius,
		spacing = brush.spacing,
		ignoreWater = brush.ignoreWater,
		ignoreInvisible = brush.ignoreInvisible
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setRadius = function(radius) dispatch(SetBrushRadius(radius)) end,
		setSpacing = function(spacing) dispatch(SetBrushSpacing(spacing)) end,
		setIgnoreWater = function(ignoreWater) dispatch(SetBrushIgnoreWater(ignoreWater)) end,
		setIgnoreInvisible = function(ignoreInvisible) dispatch(SetBrushIgnoreInvisible(ignoreInvisible)) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BrushSettingsSection)