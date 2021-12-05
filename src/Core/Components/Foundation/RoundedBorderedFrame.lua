local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local BorderedFrame = Roact.PureComponent:extend("BorderedFrame")

function BorderedFrame:render()
	local props = self.props
	local BorderColor3 = props.BorderColor3 or Color3.new(0, 0, 0)
	local BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1)
	local Size = props.Size or UDim2.new(0, 100, 0, 100)
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local AnchorPoint = props.AnchorPoint
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local Visible = props.Visible ~= false
	local borderTransparency = props.borderTransparency or 0
	local BackgroundTransparency = props.BackgroundTransparency or 0
	local slice = props.slice or "Center"
	local sliceLine = props.sliceLine ~= false
	
	local map = {
		Center =       { Vector2.new(0, 0), Vector2.new(10, 10), Rect.new(4, 4, 5, 5) },
		Top =          { Vector2.new(0, 0), Vector2.new(10,  5), Rect.new(4, 4, 5, 5) },
		Bottom =       { Vector2.new(0, 5), Vector2.new(10,  5), Rect.new(4, 0, 5, 1) },
		Right =        { Vector2.new(5, 0), Vector2.new( 5, 10), Rect.new(0, 4, 1, 5) },
		Left =         { Vector2.new(0, 0), Vector2.new( 5, 10), Rect.new(4, 4, 5, 5) },
		TopRight =     { Vector2.new(5, 0), Vector2.new( 5,  5), Rect.new(0, 4, 0, 4) },
		TopLeft =      { Vector2.new(0, 0), Vector2.new( 5,  5), Rect.new(4, 4, 4, 4) },
		BottomLeft =   { Vector2.new(0, 5), Vector2.new( 5,  5), Rect.new(4, 0, 4, 0) },
		BottomRight =  { Vector2.new(5, 5), Vector2.new( 5,  5), Rect.new(0, 0, 0, 0) },
	}
	
	local ro, rs, sc = unpack(map[slice])
	
	local map = {
		Top =         { UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1) },
		Bottom =      { UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 0) },
		Left =        { UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0) },
		Right =       { UDim2.new(0, 1, 1, 0), UDim2.new(0, 0, 0, 0) },
		TopRight =    { UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1) },
		TopLeft =     { UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1) },
		BottomLeft =  { UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 0) },
		BottomRight = { UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 0) },
	}
	
	local ls_1, lp_1
	if map[slice] then
		ls_1, lp_1 = unpack(map[slice])
	end
	
	local map = {
		TopRight =    { UDim2.new(0, 1, 1, 0), UDim2.new(0, 0, 0, 0) },
		TopLeft =     { UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0) },
		BottomLeft =  { UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0) },
		BottomRight = { UDim2.new(0, 1, 1, 0), UDim2.new(0, 0, 0, 0) },
	}
	
	local ls_2, lp_2
	if map[slice] then
		ls_2, lp_2 = unpack(map[slice])
	end
	
	return Roact.createElement(
		"ImageLabel",
		{
			Size = Size,
			Position = Position,
			LayoutOrder = LayoutOrder,
			AnchorPoint = AnchorPoint,
			ZIndex = ZIndex,
			Visible = Visible,
			BackgroundTransparency = 1,
			Image = "rbxassetid://3008645364",
			ImageTransparency = BackgroundTransparency,
			ImageColor3 = BackgroundColor3,
			ScaleType = Enum.ScaleType.Slice,
			ImageRectOffset = ro,
			ImageRectSize = rs,
			SliceCenter = sc,
			[Roact.Ref] = props[Roact.Ref] or nil
		},
		{
			Border = Roact.createElement(
				"ImageLabel",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://3008790403",
					ImageColor3 = BorderColor3,
					ScaleType = Enum.ScaleType.Slice,
					ImageRectOffset = ro,
					ImageRectSize = rs,
					SliceCenter = sc,
					ImageTransparency = borderTransparency
				}
			),
			Line1 = ls_1 and sliceLine and Roact.createElement(
				"Frame",
				{
					BackgroundColor3 = BorderColor3,
					BorderSizePixel = 0,
					Size = ls_1,
					Position = lp_1,
					BackgroundTransparency = borderTransparency
				}
			),
			Line2 = ls_2 and sliceLine and Roact.createElement(
				"Frame",
				{
					BackgroundColor3 = BorderColor3,
					BorderSizePixel = 0,
					Size = ls_2,
					Position = lp_2,
					BackgroundTransparency = borderTransparency
				}
			),
			ContentFrame = Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex = 2
				},
				props[Roact.Children]
			)
		}
	)
end

return BorderedFrame