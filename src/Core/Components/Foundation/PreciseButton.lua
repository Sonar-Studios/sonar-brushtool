local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local PreciseButton = Roact.PureComponent:extend("PreciseButton")

function PreciseButton:init()
	self:setState{
		isMouseInside = false
	}
	
	self.lastClick = 0
end

function PreciseButton:render()
	local props = self.props
	
	local onMouseEnter = props[Roact.Event.MouseEnter]
	local onMouseLeave = props[Roact.Event.MouseLeave]
	local onMouseMoved = props[Roact.Event.MouseMoved]
	local onMouseButton1Down = props[Roact.Event.MouseButton1Down]
	local onMouseButton2Down = props[Roact.Event.MouseButton2Down]
	local onMouseButton1Up = props[Roact.Event.MouseButton1Up]
	local onMouseButton2Up = props[Roact.Event.MouseButton2Up]
	local onMouseButton1Click = props[Roact.Event.MouseButton1Click]
	local onMouseButton2Click = props[Roact.Event.MouseButton2Click]
	local onDoubleMouseButton1Down = props.onDoubleMouseButton1Down
	
	local doubleClickDelay = Constants.DOUBLE_CLICK_DELAY
	
	return Roact.createElement(
		"TextButton",
		{
			Text = "",
			Size = props.Size,
			Position = props.Position,
			BackgroundColor3 = props.BackgroundColor3,
			BorderSizePixel = props.BorderSizePixel,
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			ZIndex = props.ZIndex,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			AutoButtonColor = props.AutoButtonColor,
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
			end,
			[Roact.Event.MouseButton1Down] = (onMouseButton1Down ~= nil or onDoubleMouseButton1Down ~= nil) and function(rbx, x, y)
				if not self.state.mouseInside then return end
				
				if onMouseButton1Down then
					onMouseButton1Down(rbx, x, y)
				end
				
				local timeNow = tick()
				if timeNow - self.lastClick < doubleClickDelay and onDoubleMouseButton1Down then
					self.lastClick = 0
					onDoubleMouseButton1Down()
				else
					self.lastClick = timeNow
				end
			end or nil,
			[Roact.Event.MouseButton1Up] = onMouseButton1Up and function(rbx, x, y)
				if not self.state.mouseInside then return end
				onMouseButton1Up(rbx, x, y)
			end or nil,
			[Roact.Event.MouseButton1Click] = onMouseButton1Click and function(rbx)
				if not self.state.mouseInside then return end
				onMouseButton1Click(rbx)
			end or nil,
			[Roact.Event.MouseButton2Down] = onMouseButton2Down and function(rbx, x, y)
				if not self.state.mouseInside then return end
				onMouseButton2Down(rbx, x, y)
			end or nil,
			[Roact.Event.MouseButton2Up] = onMouseButton2Up and function(rbx, x, y)
				if not self.state.mouseInside then return end
				onMouseButton2Up(rbx, x, y)
			end or nil,
			[Roact.Event.MouseButton2Click] = onMouseButton2Click and function(rbx)
				if not self.state.mouseInside then return end
				onMouseButton2Click(rbx)	
			end or nil,
			[Roact.Event.InputEnded] = props[Roact.Event.InputEnded],
			[Roact.Ref] = props[Roact.Ref]
		},
		props[Roact.Children]
	)
end

return PreciseButton