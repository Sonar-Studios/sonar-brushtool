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
local ThemedTextBox = require(Foundation.ThemedTextBox)

local TextField = Roact.PureComponent:extend("TextField")

function TextField:init()

end

function TextField:render()
	local props = self.props
	local indentLevel = props.indentLevel
	local labelWidth = props.labelWidth
	local textInput = props.textInput
	local label = props.label
	local LayoutOrder = props.LayoutOrder
	local onFocused = props.onFocused
	local onFocusLost = props.onFocusLost
	local textFormatCallback = props.textFormatCallback
	local newTextValidateCallback = props.newTextValidateCallback
	local Visible = props.Visible
	local collapsible = props.collapsible
	local collapsed = props.collapsed
	local onCollapseToggled = props.onCollapseToggled
	
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
			collapsible = collapsible,
			collapsed = collapsed,
			onCollapseToggled = onCollapseToggled
		},
		{
			Box = Roact.createElement(
				ThemedTextBox,
				{
					textInput = textInput,
					Size = UDim2.new(1, -boxPadding*2, 0, boxHeight),
					Position = UDim2.new(0, boxPadding, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					TextSize = fontSize,
					onFocused = onFocused,
					onFocusLost = onFocusLost,
					textFormatCallback = textFormatCallback,
					newTextValidateCallback = newTextValidateCallback
				}
			)
		}
	)
end

return TextField