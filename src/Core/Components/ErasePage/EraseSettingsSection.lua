local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Actions = Plugin.Core.Actions
local SetEraseRadius = require(Actions.SetEraseRadius)
local SetEraseIgnoreWater = require(Actions.SetEraseIgnoreWater)
local SetEraseIgnoreInvisible = require(Actions.SetEraseIgnoreInvisible)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local CheckboxField = require(Foundation.CheckboxField)
local DropdownField = require(Foundation.DropdownField)
local TextField = require(Foundation.TextField)
local NumericalSliderField = require(Foundation.NumericalSliderField)

local EraseSettingsSection = Roact.PureComponent:extend("EraseSettingsSection")

function EraseSettingsSection:render()
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
			),
		}
	)
end

local function mapStateToProps(state, props)
	local erase = state.erase
	return {
		radius = erase.radius,
		spacing = erase.spacing,
		ignoreWater = erase.ignoreWater,
		ignoreInvisible = erase.ignoreInvisible,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setRadius = function(radius) dispatch(SetEraseRadius(radius)) end,
		setIgnoreWater = function(ignoreWater) dispatch(SetEraseIgnoreWater(ignoreWater)) end,
		setIgnoreInvisible = function(ignoreInvisible) dispatch(SetEraseIgnoreInvisible(ignoreInvisible)) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(EraseSettingsSection)