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
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local ThemedCheckbox = Roact.PureComponent:extend("ThemedCheckbox")

function ThemedCheckbox:init()
	self:setState(
		{
			buttonState = "Default",
		}
	)
	
	self.onStateChanged = function(s)
		self:setState{buttonState = s}
	end
end

function ThemedCheckbox:render()
	local props = self.props
	local Size = props.Size or UDim2.new(0, Constants.CHECKBOX_SIZE, 0, Constants.CHECKBOX_SIZE)
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local checked = not not props.checked
	local isHovered = self.state.isHovered
	local AnchorPoint = props.AnchorPoint
	local onToggle = props.onToggle
	
	return withTheme(function(theme)
		local fieldTheme = theme.checkboxField
		local checkmarkColor = fieldTheme.checkmarkColor
		local boxColors = fieldTheme.box
		
		local modal = getModal(self)
				
		return Roact.createElement(
			"Frame",
			{
				Size = Size,
				Position = Position,
				AnchorPoint = AnchorPoint,
				BackgroundTransparency = 1	
			},
			{
				Border = (function()
					local bgColor, borderColor
					local buttonState = self.state.buttonState
					if buttonState == "Hovered" or buttonState == "PressedInside" then
						bgColor = boxColors.backgroundColor.Hover
						borderColor = boxColors.borderColor.Hover
					else
						bgColor = boxColors.backgroundColor.Default
						borderColor = boxColors.borderColor.Default
					end
					
					return Roact.createElement(
						RoundedBorderedFrame,
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundColor3 = bgColor,
							BorderColor3 = borderColor,
						}
					)
				end)(),
				Button = Roact.createElement(
					StatefulButtonDetector,
					{
						Size = UDim2.new(1, 0, 1, 0),
						onClick = onToggle,
						onStateChanged = self.onStateChanged
					}
				),
				Checkmark = checked and Roact.createElement(
					"ImageLabel",
					{
						BackgroundTransparency = 1,
						Image = Constants.CHECK_IMAGE,
						Size = UDim2.new(1, -6, 1, -6),
						Position = UDim2.new(0, 3, 0, 3),
						ImageColor3 = checkmarkColor
					}
				),
			}
		)
	end)
end

return ThemedCheckbox