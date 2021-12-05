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
local ThemedCheckbox = require(Foundation.ThemedCheckbox)

local CheckboxField = Roact.PureComponent:extend("CheckboxField")

function CheckboxField:init()

end

function CheckboxField:render()
	local props = self.props
	local indentLevel = props.indentLevel
	local labelWidth = props.labelWidth
	local label = props.label
	local checked = props.checked
	local LayoutOrder = props.LayoutOrder
	local Visible = props.Visible
	local onToggle = props.onToggle
	local collapsible = props.collapsible
	local collapsed = props.collapsed
	local onCollapseToggled = props.onCollapseToggled
	
	local boxPadding = Constants.INPUT_FIELD_BOX_PADDING
	local boxHeight = Constants.INPUT_FIELD_BOX_HEIGHT
	local fontSize = Constants.FONT_SIZE_MEDIUM
	local checkboxSize = Constants.CHECKBOX_SIZE

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
			Checkbox = Roact.createElement(
				ThemedCheckbox,
				{
					checked = checked,
					Size = UDim2.new(0, boxHeight, 0, boxHeight),
					Position = UDim2.new(0, boxPadding, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					onToggle = onToggle
				}
			)
		}
	)
end

return CheckboxField