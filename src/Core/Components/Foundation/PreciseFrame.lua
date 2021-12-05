local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local PreciseFrame = Roact.PureComponent:extend("PreciseFrame")

function PreciseFrame:init()
	self:setState{
		isMouseInside = false
	}
end

function PreciseFrame:render()
	local props = self.props

	local onMouseEnter = props[Roact.Event.MouseEnter]
	local onMouseLeave = props[Roact.Event.MouseLeave]
	local onMouseMoved = props[Roact.Event.MouseMoved]

	return Roact.createElement(
		"Frame",
		{
			Size = props.Size,
			Position = props.Position,
			BackgroundColor3 = props.BackgroundColor3,
			BorderSizePixel = props.BorderSizePixel,
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			ZIndex = props.ZIndex,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			[Roact.Event.MouseEnter] = function(rbx, x, y)
				local absPos = rbx.AbsolutePosition
				local absSize = rbx.AbsoluteSize
				local topLeft = absPos
				local bottomRight = absPos + absSize
				local isInside = x > topLeft.X and
					y > topLeft.Y and
					x <= bottomRight.X and
					y <= bottomRight.Y
					
				if isInside and not self.state.mouseInside then
					self:setState{
						mouseInside = true
					}
					if onMouseEnter then
						onMouseEnter(rbx, x, y)
					end
				end
			end,
			[Roact.Event.MouseMoved] = function(rbx, x, y)
				local absPos = rbx.AbsolutePosition
				local absSize = rbx.AbsoluteSize
				local topLeft = absPos
				local bottomRight = absPos + absSize
				local isInside = x > topLeft.X and
					y > topLeft.Y and
					x <= bottomRight.X and
					y <= bottomRight.Y
					
				if isInside and not self.state.mouseInside then
					self:setState{
						mouseInside = true
					}
					if onMouseEnter then
						onMouseEnter(rbx, x, y)
					end
				elseif not isInside and self.state.mouseInside then
					self:setState{
						mouseInside = false
					}
					if onMouseLeave then
						onMouseLeave(rbx, x, y)
					end
				end
				
				if onMouseMoved then
					onMouseMoved(rbx, x, y)
				end
			end,
			[Roact.Event.MouseLeave] = function(rbx, x, y)
				self:setState{
					mouseInside = false
				}
				if onMouseLeave then
					onMouseLeave(rbx, x, y)
				end
			end
		},
		props[Roact.Children]
	)
end

return PreciseFrame