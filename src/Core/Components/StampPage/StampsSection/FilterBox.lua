local Plugin = script.Parent.Parent.Parent.Parent.Parent

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

local Actions = Plugin.Core.Actions
local SetStampFilter = require(Actions.SetStampFilter)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local ThemedTextBox = require(Foundation.ThemedTextBox)

local FilterBox = Roact.PureComponent:extend("FilterBox")

function FilterBox:init()
	self:setState(
		{
			isHovered = false
		}
	)
end

function FilterBox:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local isHovered = self.state.isHovered
	
	return withTheme(function(theme)
		return withModal(function(modalTarget, modalStatus)
			local buttonState
			if getModal(self).isShowingModal() then
				buttonState = "Default"
			elseif isHovered then
				buttonState = "Hovered"
			else
				buttonState = "Default"		
			end
			
			local boxHeight = Constants.INPUT_FIELD_BOX_HEIGHT
			local boxTheme = theme.filterBox
		
			return Roact.createElement(
				ThemedTextBox,
				{
					Size = UDim2.new(1, 0, 0, boxHeight),
					Position = UDim2.new(0, 0, 0, 0),
					placeholderText = "Search...",
					LayoutOrder = LayoutOrder,
					textInput = props.filter,
					onInputChanged = function(t)
						props.setFilter(t)
					end,
					newTextValidateCallback = function(t)
						return string.len(t) < 20
					end
				},
				{
					ClearButton = Roact.createElement(
						"ImageButton",
						{
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -4, 0, 4),
							Size = UDim2.new(0, boxHeight-8, 0, boxHeight-8),
							AnchorPoint = Vector2.new(1, 0),
							Image = buttonState == "Hovered" and Constants.CLEAR_ICON_HOVER or Constants.CLEAR_ICON,
							AutoButtonColor = false,
							ImageColor3 = boxTheme.clearButtonColor[buttonState],
							Visible = props.filter ~= "",
							[Roact.Event.MouseEnter] = function(rbx)
								self:setState({
									isHovered = true
								})
							end,
							[Roact.Event.MouseLeave] = function(rbx)
								self:setState({
									isHovered = false
								})
							end,
							[Roact.Event.MouseButton1Down] = function(rbx)
								if not getModal(self).isShowingModal() then
									props.clearFilter()
								end
							end,
						}
					),
				}
			)
		end)
	end)
end

local function mapStateToProps(state, props)
	return {
		filter = state.stamp.filter
	}
end

local function mapDispatchToProps(dispatch)
	return {
		clearFilter = function() dispatch(SetStampFilter("")) end,
		setFilter = function(filter) dispatch(SetStampFilter(filter)) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(FilterBox)