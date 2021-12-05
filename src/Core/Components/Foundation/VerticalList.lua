local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local VerticalList = Roact.PureComponent:extend("VerticalList")

function VerticalList:init()
	self.listRef = Roact.createRef()
	self.frameRef = Roact.createRef()
end

-- Very important note when using this: Do NOT add a direct child that has a
-- non-zero scale component for its Y-Size.
function VerticalList:render()
	local children = {}
	local props = self.props
	local width = props.width or UDim.new(0, 100)
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local LayoutOrder = props.LayoutOrder
	local AnchorPoint = props.AnchorPoint
	local ZIndex = props.ZIndex
	local PaddingLeftPixel = props.PaddingLeftPixel or 0
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingRightPixel = props.PaddingRightPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	local ElementPaddingPixel = props.ElementPaddingPixel or 0
	local Visible = props.Visible ~= false
	local HorizontalAlignment = props.HorizontalAlignment
	
	local frameChildren = {}
	local listProps = {}
	listProps[Roact.Ref] = self.listRef
	listProps.SortOrder = Enum.SortOrder.LayoutOrder
	listProps.HorizontalAlignment = HorizontalAlignment
	listProps.Padding = UDim.new(0, ElementPaddingPixel)
	frameChildren.UIListLayout = Roact.createElement("UIListLayout", listProps)
	
	if props[Roact.Children] then
		for key, value in pairs(props[Roact.Children]) do
			frameChildren[key] = value
		end
	end
	
	return Roact.createElement(
		"Frame",
		{
			BackgroundTransparency = 1,
			Position = Position,
			LayoutOrder = LayoutOrder,
			ZIndex = ZIndex,
			AnchorPoint = AnchorPoint,
			Size = UDim2.new(width, UDim.new(0, PaddingTopPixel+PaddingBottomPixel)),
			Visible = Visible,
			[Roact.Ref] = self.frameRef
		},
		{
			Content = Roact.createElement(
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -(PaddingLeftPixel+PaddingRightPixel), 1, -(PaddingTopPixel+PaddingBottomPixel)),
					Position = UDim2.new(0, PaddingLeftPixel, 0, PaddingTopPixel),
				},
				frameChildren
			)
		}
		
	)
end

function VerticalList:updateSize()
	local list = self.listRef.current
	local frame = self.frameRef.current
	
	if not list then return end
	
	local cs = list.AbsoluteContentSize
	local props = self.props
	local width = props.width or UDim.new(0, 100)
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	frame.Size = UDim2.new(props.width, UDim.new(0, cs.Y+PaddingTopPixel+PaddingBottomPixel))
end

function VerticalList:didMount()
	local list = self.listRef.current
	
	self.resizeConn = list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		-- Haaaaax
		game:GetService("RunService").Heartbeat:Wait()
		self:updateSize()
	end)
	
	self:updateSize()
	
	-- lame hack :/
	coroutine.wrap(
		function()
			game:GetService("RunService").Heartbeat:Wait()
			game:GetService("RunService").Heartbeat:Wait()
			self:updateSize()
		end
	)()
end

function VerticalList:didUpdate()
	self:updateSize()
end

function VerticalList:willUnmount()
	self.resizeConn:Disconnect()
end

return VerticalList
