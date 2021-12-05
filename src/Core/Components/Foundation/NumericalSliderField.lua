local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local LabeledFieldTemplate = require(Foundation.LabeledFieldTemplate)
local ThemedNumericalSlider = require(Foundation.ThemedNumericalSlider)

local NumericalSliderField = Roact.PureComponent:extend("NumericalSliderField")

function NumericalSliderField:init()
	self:setState{
		focused = false
	}
end

function NumericalSliderField:render()
	local props = self.props
	local indentLevel = props.indentLevel
	local labelWidth = props.labelWidth
	local label = props.label
	local LayoutOrder = props.LayoutOrder
	local Visible = props.Visible
	local collapsible = props.collapsible
	local collapsed = props.collapsed
	local onCollapseToggled = props.onCollapseToggled
	local textboxWidthPixel = props.textboxWidthPixel or 60
	local minValue = props.minValue
	local maxValue = props.maxValue
	local valueIsIntegral = props.valueIsIntegral or false
	local valueRound = props.valueRound
	local valueSnap = props.valueSnap
	local value = props.value or minValue
	local onValueChanged = props.onValueChanged
	local decimalPlacesToShow = props.decimalPlacesToShow or 2
	local maxCharacters = props.maxCharacters or 16
	local trucateTrailingZeroes = props.trucateTrailingZeroes ~= false
	
	local boxPadding = Constants.INPUT_FIELD_BOX_PADDING
	local boxHeight = Constants.INPUT_FIELD_BOX_HEIGHT
	local fontSize = Constants.FONT_SIZE_MEDIUM

	return Roact.createElement(
		LabeledFieldTemplate,
		{
			label = label,
			indentLevel = indentLevel,
			labelWidth = labelWidth,
			LayoutOrder = LayoutOrder,
			Visible = Visible,
			forceShowHighlight = self.state.focused,
			collapsible = collapsible,
			collapsed = collapsed,
			onCollapseToggled = onCollapseToggled
		},
		{
			Slider = Roact.createElement(
				ThemedNumericalSlider,
				{
					Size = UDim2.new(1, -boxPadding*2, 0, boxHeight),
					Position = UDim2.new(0, boxPadding, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					TextSize = fontSize,
					textboxWidthPixel = textboxWidthPixel,
					minValue = minValue,
					maxValue = maxValue,
					valueIsIntegral = valueIsIntegral,
					valueRound = valueRound,
					valueSnap = valueSnap,
					value = value,
					onValueChanged = onValueChanged,
					decimalPlacesToShow = decimalPlacesToShow,
					maxCharacters = maxCharacters,
					trucateTrailingZeroes = trucateTrailingZeroes
				}
			)
		}
	)
end

return NumericalSliderField