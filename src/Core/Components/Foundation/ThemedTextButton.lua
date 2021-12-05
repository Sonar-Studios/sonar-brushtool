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
local AutoHeightThemedText = require(Foundation.AutoHeightThemedText)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local ThemedTextButton = Roact.PureComponent:extend("ThemedTextButton")

function ThemedTextButton:init()
	self:setState(
		{
			buttonState = "Default"
		}
	)
end

function ThemedTextButton:render()
	local props = self.props
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local checked = props.checked or false
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size or UDim2.new(0, 100, 0, 100)
	local onClick = props.onClick
	local Text = props.Text
	local LayoutOrder = props.LayoutOrder
	local buttonStyle = props.buttonStyle or "Default"
	local TextWrapped = props.TextWrapped or false
	local TextXAlignment = props.TextXAlignment
	local TextYAlignment = props.TextYAlignment
	local disabled = props.disabled
	local Font = props.Font or Constants.FONT
	local TextSize = props.TextSize or Constants.FONT_SIZE_MEDIUM
	local ZIndex = props.ZIndex
	local selected = props.selected
	
	return withTheme(function(theme)
		local buttonTheme = theme.button
		
		local boxState = "Default"
		local buttonState = self.state.buttonState
					
		if disabled then
			boxState = "Disabled"
		elseif selected then
			local map = {
				Default = "Selected",
				Hovered = "SelectedHovered",
				PressedInside = "SelectedPressedInside",
				PressedOutside = "SelectedPressedOutside"
			}
			
			boxState = map[buttonState]
		else
			local map = {
				Default = "Default",
				Hovered = "Hovered",
				PressedInside = "PressedInside",
				PressedOutside = "PressedOutside"
			}
			
			boxState = map[buttonState]
		end
		
		local borderColor = buttonTheme.box.borderColor[buttonStyle][boxState]
		local backgroundColor = buttonTheme.box.backgroundColor[buttonStyle][boxState]
		local textColor = not disabled and buttonTheme.textColor[buttonStyle] or buttonTheme.textColor.Disabled
		
		return Roact.createElement(
			RoundedBorderedFrame,
			{
				Size = Size,
				BackgroundColor3 = backgroundColor,
				BorderColor3 = borderColor,
				Position = Position,
				AnchorPoint = AnchorPoint,
				LayoutOrder = LayoutOrder,
				ZIndex = ZIndex
			},
			{
				Button = Roact.createElement(
					StatefulButtonDetector,
					{
						Size = UDim2.new(1, 0, 1, 0),
						onClick = onClick,
						onStateChanged = function(s) self:setState{ buttonState = s } end
					},
					{
						Text = Roact.createElement(
							"TextLabel",
							{
								Size = UDim2.new(1, -10, 1, 0),
								Position = UDim2.new(0, 5, 0, 0),
								BackgroundTransparency = 1,
								Text = Text,
								TextColor3 = textColor,
								Font = Font,
								TextSize = TextSize,
								TextXAlignment = TextXAlignment,
								TextYAlignment = TextYAlignment,
								TextWrapped = TextWrapped,
								TextTruncate = Enum.TextTruncate.AtEnd
							}
						)
					}
				)
			}
		)
	end)
end

return ThemedTextButton