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
local SetBrushSelected = require(Actions.SetBrushSelected)
local ClearBrushSelected = require(Actions.ClearBrushSelected)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local PreciseButton = require(Foundation.PreciseButton)
local BorderedFrame = require(Foundation.BorderedFrame)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local DeleteButton = Roact.PureComponent:extend("DeleteButton")

function DeleteButton:init()
	self:setState(
		{
			buttonState = "Default"
		}
	)
	
	self.onStateChanged = function(buttonState)
		game:GetService("RunService").Heartbeat:Wait()
		self:setState{
			buttonState = buttonState
		}
	end
	self.onClick = function()
		local props = self.props
		local selected = props.selected
		local guid = props.guid
		if not selected then
			props.setSelected(guid)
		else
			props.clearSelected()
		end
	end
end

function DeleteButton:render()
	local props = self.props
	local guid = props.guid
	local selected = props.selected
	local state = self.state
	return withTheme(function(theme)
		local buttonTheme = theme.button
		local entryTheme = theme.objectGridEntry
		local buttonState = self.state.buttonState
		local boxState
		if selected then
			local map = {
				Default = "Selected",
				Hovered = "SelectedHovered",
				PressedInside = "SelectedPressedInside",
				PressedOutside = "SelectedPressedOutside"
			}
			
			boxState = map[buttonState]
		else
			local map = {
				Default = "Default",
				Hovered = "Hovered",
				PressedInside = "PressedInside",
				PressedOutside = "PressedOutside"
			}
			
			boxState = map[buttonState]
		end
		
		local borderColor = buttonTheme.box.borderColor.Default[boxState]
		local backgroundColor = buttonTheme.box.backgroundColor.Default[boxState]

		return Roact.createElement(
			StatefulButtonDetector,
			{
				Size = UDim2.new(0, 40, 1, 0),
				Position = UDim2.new(1, -80, 0, 0),
				ZIndex = 2,
				BackgroundTransparency = 1,
				onStateChanged = self.onStateChanged,
				onClick = self.onClick
			},
			{
				Border = Roact.createElement(
					BorderedFrame,
					{
						Size = UDim2.new(1, 0, 1, 0),
						BorderColor3 = borderColor,
						BackgroundColor3 = backgroundColor,
						BorderThicknessRight = 0
					}
				),
				Image = Roact.createElement(
					"ImageLabel",
					{
						Image = Constants.OVERRIDE_ICON,
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
		setSelected = function(guid) dispatch(SetBrushSelected(guid)) end,
		clearSelected = function() dispatch(ClearBrushSelected()) end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(DeleteButton)