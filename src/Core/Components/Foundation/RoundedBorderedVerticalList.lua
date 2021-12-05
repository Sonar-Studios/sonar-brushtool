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
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)

local RoundedBorderedVerticalList = Roact.PureComponent:extend("RoundedBorderedVerticalList")

-- Very important note when using this: Do NOT add a direct child that has a
-- non-zero scale component for its Y-Size.
function RoundedBorderedVerticalList:init()
	self.listRef = Roact.createRef()
	self.frameRef = Roact.createRef()
end

function RoundedBorderedVerticalList:render()
	local children = {}
	local props = self.props
	local width = props.width or UDim.new(0, 100)
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local LayoutOrder = props.LayoutOrder
	local AnchorPoint = props.AnchorPoint
	local ZIndex = props.ZIndex
	local BackgroundColor3 = props.BackgroundColor3
	local BorderColor3 = props.BorderColor3
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	local PaddingLeftPixel = props.PaddingLeftPixel or 0
	local PaddingRightPixel = props.PaddingRightPixel or 0
	local BorderThicknessTop = props.BorderThicknessTop
	local BorderThicknessBottom = props.BorderThicknessBottom
	local BorderThicknessLeft = props.BorderThicknessLeft
	local BorderThicknessRight = props.BorderThicknessRight
	local Visible = props.Visible
	local slice = props.slice
	
	local frameChildren = {}
	local listProps = {}
	listProps[Roact.Change.AbsoluteContentSize] = function(rbx, pos)
		game:GetService("RunService").Heartbeat:Wait()
		
		local PaddingTopPixel = self.props.PaddingTopPixel or 0
		local PaddingBottomPixel = self.props.PaddingBottomPixel or 0
		local cs = rbx.AbsoluteContentSize
		local frame = self.frameRef.current
		if frame then
			frame.Size = UDim2.new(width, UDim.new(0, cs.Y+PaddingTopPixel+PaddingBottomPixel))
		end
	end
	listProps[Roact.Ref] = self.listRef
	listProps.SortOrder = Enum.SortOrder.LayoutOrder
	frameChildren.UIListLayout = Roact.createElement("UIListLayout", listProps)
	
	if props[Roact.Children] then
		for key, value in pairs(props[Roact.Children]) do
			frameChildren[key] = value
		end
	end
		
	return Roact.createElement(
		RoundedBorderedFrame,
		{
			BackgroundTransparency = 1,
			Position = Position,
			LayoutOrder = LayoutOrder,
			ZIndex = ZIndex,
			AnchorPoint = AnchorPoint,
			BorderColor3 = BorderColor3,
			BackgroundColor3 = BackgroundColor3,
			Size = UDim2.new(width, UDim.new(0, PaddingTopPixel+PaddingBottomPixel)),
			Visible = Visible,
			[Roact.Ref] = self.frameRef,
			slice = slice
		},
		{
			Content = Roact.createElement(
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -(PaddingLeftPixel+PaddingRightPixel), 1, -(PaddingTopPixel+PaddingBottomPixel)),
					Position = UDim2.new(0, PaddingLeftPixel, 0, PaddingTopPixel)
				},
				frameChildren
			)
		}
	)
end

function RoundedBorderedVerticalList:didMount()
	local list = self.listRef.current
	local frame = self.frameRef.current
	
	local cs = list.AbsoluteContentSize
	local props = self.props
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	frame.Size = UDim2.new(props.width, UDim.new(0, cs.Y+PaddingTopPixel+PaddingBottomPixel))
end

return RoundedBorderedVerticalList
