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
local AutoHeightText = require(Foundation.AutoHeightText)

local AutoHeightThemedText = Roact.PureComponent:extend("AutoHeightThemedText")

-- Children must have a zero Y-Scale size.
function AutoHeightThemedText:render()
	local props = self.props
	local width = props.width or UDim.new(1, 0)
	local Text = props.Text or ""
	local Position = props.Position
	local Font = props.Font or Constants.FONT
	local TextSize = props.TextSize or Constants.FONT_SIZE_MEDIUM
	local TextXAlignment = props.TextXAlignment
	local textStyle = props.textStyle or "Default"
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	local PaddingLeftPixel = props.PaddingLeftPixel or 0
	local PaddingRightPixel = props.PaddingRightPixel or 0
	local AnchorPoint = props.AnchorPoint
	
	return withTheme(function(theme)
		local TextColor3 = textStyle == "Warning" and theme.warningTextColor or 
			textStyle == "Positive" and theme.positiveTextColor or
			theme.mainTextColor
		return Roact.createElement(
			AutoHeightText,
			{
				width = width,
				Text = Text,
				Position = Position,
				Font = Font,
				TextSize = TextSize,
				TextXAlignment = TextXAlignment,
				TextColor3 = TextColor3,
				LayoutOrder = LayoutOrder,
				ZIndex = ZIndex,
				PaddingTopPixel = PaddingTopPixel,
				PaddingBottomPixel = PaddingBottomPixel,
				PaddingLeftPixel = PaddingLeftPixel,
				PaddingRightPixel = PaddingRightPixel,
				AnchorPoint = AnchorPoint
			}
		)
	end)
end

return AutoHeightThemedText