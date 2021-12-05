local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local getModal = ContextGetter.getModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local LabeledFieldTemplate = require(Foundation.LabeledFieldTemplate)
local ThemedDropdown = require(Foundation.ThemedDropdown)

local DropdownField = Roact.PureComponent:extend("DropdownField")

function DropdownField:init()
end

function DropdownField:render()
	local props = self.props
	local indentLevel = props.indentLevel
	local labelWidth = props.labelWidth
	local textInput = props.textInput
	local label = props.label
	local LayoutOrder = props.LayoutOrder
	local entries = props.entries
	local selectedId = props.selectedId
	local Visible = props.Visible ~= false
	local onSelected = props.onSelected
	local collapsible = props.collapsible
	local collapsed = props.collapsed
	local onCollapseToggled = props.onCollapseToggled
	local enabled = props.enabled
	local inactive = props.inactive
	
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
			onCollapseToggled = onCollapseToggled,
			enabled = enabled
		},
		{
			Box = Roact.createElement(
				ThemedDropdown,
				{
					entries = entries,
					selectedId = selectedId,
					Size = UDim2.new(1, -boxPadding*2, 0, boxHeight),
					Position = UDim2.new(0, boxPadding, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					TextSize = fontSize,
					onSelected = onSelected,
					enabled = enabled,
					onOpen =  props.onOpen,
					onClose = props.onClose,
					Visible = Visible,
					inactive = inactive
				}
			)
		}
	)
end

return DropdownField