local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Actions = Plugin.Core.Actions
local SetBrushFilter = require(Actions.SetBrushFilter)
local EnableAllBrushes = require(Actions.EnableAllBrushes)
local DisableAllBrushes = require(Actions.DisableAllBrushes)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local ThemedTextButton = require(Foundation.ThemedTextButton)
local ThemedTextBox = require(Foundation.ThemedTextBox)
local VerticalList = require(Foundation.VerticalList)
local VerticalListSeparator = require(Foundation.VerticalListSeparator)
local CheckboxField = require(Foundation.CheckboxField)
local BorderedFrame = require(Foundation.BorderedFrame)
local DropdownField = require(Foundation.DropdownField)
local TextField = require(Foundation.TextField)
local ObjectThumbnail = require(Foundation.ObjectThumbnail)
local StampObjectsGrid = require(script.StampObjectsGrid)
local FilterBox = require(script.FilterBox)

local StampsSection = Roact.PureComponent:extend("StampsSection")

function StampsSection:init()

end

function StampsSection:render()
	local props = self.props
	local labelWidth = Constants.FIELD_LABEL_WIDTH
	local LayoutOrder = props.LayoutOrder
	local Visible = props.Visible

	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end

	return withTheme(function(theme)
		local fieldHeight = Constants.INPUT_FIELD_HEIGHT
		local boxHeight = Constants.INPUT_FIELD_BOX_HEIGHT
		local boxPadding = Constants.INPUT_FIELD_BOX_PADDING
		local fontSize = Constants.FONT_SIZE_MEDIUM
		local font = Constants.FONT
		local buttonHeight = Constants.BUTTON_HEIGHT
		local gridTheme = theme.objectGrid
		local gridBackgroundColor = gridTheme.backgroundColor
		local gridBorderColor = gridTheme.borderColor
		local gridPadding = Constants.BRUSH_GRID_PADDING
		local cellSize = Constants.BRUSH_GRID_CELL_SIZE
				
		return Roact.createElement(
			VerticalList,
			{
				width = UDim.new(1, 0),
				PaddingLeftPixel = 4,
				PaddingRightPixel = 4,
				PaddingTopPixel = 4,
				PaddingBottomPixel = 4,
				LayoutOrder = LayoutOrder,
				Visible = Visible
			},
			{
				FilterBox = Roact.createElement(
					FilterBox,
					{
						LayoutOrder = generateSequentialLayoutOrder()
					}
				),
				FilterPadding = Roact.createElement(
					VerticalListSeparator,
					{
						height = boxPadding,
						LayoutOrder = generateSequentialLayoutOrder()
					}
				),
				StampsGridFrame = Roact.createElement(
					StampObjectsGrid,
					{
						LayoutOrder = generateSequentialLayoutOrder()
					}
				)
			}
		)
	end)
end

function mapStateToProps(state, props)
	local objects = state.brushObjects
	local brush = state.brush
	
	local isAllDisabled = true
	local isAllEnabled = true
	for _, object in next, objects do
		if object.brushEnabled and isAllDisabled then
			isAllDisabled = false
		elseif not object.brushEnabled and isAllEnabled then
			isAllEnabled = false
		end
		
		if not isAllDisabled and not isAllEnabled then
			break
		end
	end
	
	return {
		filter = brush.filter,
		isAllEnabled = isAllEnabled,
		isAllDisabled = isAllDisabled
	}
end

function mapDispatchToProps(dispatch)
	return {
		setFilter = function(filter) dispatch(SetBrushFilter(filter)) end,
		enableAll = function()
			dispatch(EnableAllBrushes())
		end,
		disableAll = function()
			dispatch(DisableAllBrushes())
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(StampsSection)