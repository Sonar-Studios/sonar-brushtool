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
local PreciseFrame = require(Foundation.PreciseFrame)
local PreciseButton = require(Foundation.PreciseButton)

local LabeledFieldTemplate = Roact.PureComponent:extend("LabeledFieldTemplate")

function LabeledFieldTemplate:init()

end

function LabeledFieldTemplate:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local label = props.label
	local indentLevel = props.indentLevel or 0
	local labelWidth = props.labelWidth or 120
	local Visible = props.Visible
	local collapsible = not not props.collapsible
	local collapsed = not not props.collapsed
	local onCollapseToggled = props.onCollapseToggled
	local enabled = props.enabled ~= false
	local rowHeight = props.rowHeight or 1

	local modal = getModal(self)

	return withTheme(function(theme)
		local fieldTheme = theme.labeledField
		local fieldHeight = Constants.INPUT_FIELD_HEIGHT*rowHeight
		local perLevelIndent = Constants.INPUT_FIELD_INDENT_PER_LEVEL
		local labelPadding = Constants.INPUT_FIELD_LABEL_PADDING
		local fontSize = Constants.FONT_SIZE_MEDIUM
		local font = Constants.FONT
		local labelColor = enabled and fieldTheme.textColor.Enabled or fieldTheme.textColor.Disabled
		local arrowColor = fieldTheme.arrowColor
		local totalIndent = perLevelIndent*(indentLevel)
		local width = labelWidth-totalIndent
		
		local arrowRight = Constants.COLLAPSIBLE_ARROW_RIGHT_IMAGE
		local arrowDown = Constants.COLLAPSIBLE_ARROW_DOWN_IMAGE
		local arrowSize = Constants.COLLAPSIBLE_ARROW_SIZE
		local arrowPosition = Constants.COLLAPSIBLE_ARROW_POSITION
		
		local finalLabelWidth = width-labelPadding
		local textFits = Utility.GetTextSize(label, fontSize, font, Vector2.new(9999, 9999)).X <= finalLabelWidth
		
		return Roact.createElement(
			PreciseFrame,
			{
				Size = UDim2.new(1, 0, 0, fieldHeight),
				BackgroundTransparency = 1,
				LayoutOrder = LayoutOrder,
				ZIndex = ZIndex,
				Visible = Visible
			},
			{
--				ArrowLines = indentLevel > 0 and Roact.createElement(
--					"TextLabel",
--					{
--						Size = UDim2.new(0, 20, 1, 0),
--						BackgroundTransparency = 1,
--						TextColor3 = arrowColor,
--						TextSize = 15,
--						Font = Enum.Font.SourceSans,
--						Text = "└─",
--						AnchorPoint = Vector2.new(1, 0),
--						Position = UDim2.new(0, totalIndent-3, 0, -1),
--						TextXAlignment = Enum.TextXAlignment.Right,
--						ZIndex = 2
--					}
--				),
--				ArrowHead = indentLevel > 0 and Roact.createElement(
--					"TextLabel",
--					{
--						Size = UDim2.new(0, 20, 1, 0),
--						BackgroundTransparency = 1,
--						TextColor3 = arrowColor,
--						TextSize = 15,
--						Font = Enum.Font.SourceSans,
--						Text = ">",
--						AnchorPoint = Vector2.new(1, 0),
--						Position = UDim2.new(0, totalIndent-3, 0, -1),
--						TextXAlignment = Enum.TextXAlignment.Right,
--						ZIndex = 2
--					}
--				),
				Label = Roact.createElement(
					"TextLabel",
					{
						Size = UDim2.new(0, finalLabelWidth, 0, Constants.INPUT_FIELD_HEIGHT),
						BackgroundTransparency = 1,
						TextColor3 = labelColor,
						TextSize = fontSize,
						TextTruncate = textFits and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
						Font = font,
						Text = label,
						TextXAlignment = Enum.TextXAlignment.Left,
						Position = UDim2.new(0, totalIndent+labelPadding, 0, 0),
						ZIndex = 2
					}
				),
				FieldContainer = Roact.createElement(
					"Frame",
					{
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -labelWidth, 0, fieldHeight),
						Position = UDim2.new(0, labelWidth, 0, 0),
						ZIndex = 2
					},
					props[Roact.Children]
				),
				CollapseArrowButton = collapsible and Roact.createElement(
					PreciseButton,
					{
						Size = UDim2.new(0, totalIndent, 0, fieldHeight),
						BackgroundTransparency = 1,
						[Roact.Event.MouseButton1Down] = collapsible and onCollapseToggled and function()
							onCollapseToggled()
						end
					},
					{
						Arrow = Roact.createElement(
							"ImageLabel",
							{
								Size = UDim2.new(0, arrowSize, 0, arrowSize),
								Position = arrowPosition,
								Image = collapsed and arrowRight or arrowDown,
								BackgroundTransparency = 1
							}
						)
					}
				)
			}
		)
	end)
end

return LabeledFieldTemplate