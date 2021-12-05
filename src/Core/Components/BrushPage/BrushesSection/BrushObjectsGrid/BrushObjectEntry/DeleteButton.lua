local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Funcs = require(Plugin.Core.Util.Funcs)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local getModal = ContextGetter.getModal

local Actions = Plugin.Core.Actions
local ClearBrushSelected = require(Actions.ClearBrushSelected)
local SetBrushDeleting = require(Actions.SetBrushDeleting)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local PreciseButton = require(Foundation.PreciseButton)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local DeleteButton = Roact.PureComponent:extend("DeleteButton")

function DeleteButton:init()
	self:setState(
		{
			buttonState = "Default"
		}
	)
	
	self.onStateChanged = function(s) self:setState{ buttonState = s } end
	self.onClick = function()
		local props = self.props
		local selected = props.selected
		local guid = props.guid
		props.setDeleting(guid)
		if selected then
			props.clearSelected()
		end
	end
end

function DeleteButton:render()
	local props = self.props
	local guid = props.guid
	local state = self.state
	local selected = props.selected
	return withTheme(function(theme)
		local buttonTheme = theme.button
		local entryTheme = theme.objectGridEntry
		local buttonState = self.state.buttonState
		local boxState
		local map = {
			Default = "Default",
			Hovered = "Hovered",
			PressedInside = "PressedInside",
			PressedOutside = "PressedOutside"
		}
		
		boxState = map[buttonState]
		
		local borderColor = buttonTheme.box.borderColor.Default[boxState]
		local backgroundColor = buttonTheme.box.backgroundColor.Default[boxState]

		return Roact.createElement(
			StatefulButtonDetector,
			{
				Size = UDim2.new(0, 40, 1, 0),
				Position = UDim2.new(1, -40, 0, 0),
				ZIndex = 2,
				BackgroundTransparency = 1,
				onStateChanged = self.onStateChanged,
				onClick = self.onClick
			},
			{
				Border = Roact.createElement(
					RoundedBorderedFrame,
					{
						Size = UDim2.new(1, 0, 1, 0),
						BorderColor3 = borderColor,
						BackgroundColor3 = backgroundColor,
						slice = not selected and "Right" or "TopRight"
					}
				),
				Image = Roact.createElement(
					"ImageLabel",
					{
						Image = Constants.DELETE_ICON,
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						ImageColor3 = buttonTheme.textColor.Default,
						ZIndex = 2
					}
				)
			}
		)
	end)
end

function mapStateToProps(state, props)
	return {}
end

function mapDispatchToProps(dispatch)
	return {
		clearSelected = function() dispatch(ClearBrushSelected()) end,
		setDeleting = function(guid) dispatch(SetBrushDeleting(guid)) end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(DeleteButton)