local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local getModal = ContextGetter.getModal
local withModal = ContextHelper.withModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local PreciseButton = require(Foundation.PreciseButton)
local StatefulButtonDetector = Roact.PureComponent:extend("StatefulButtonDetector")

function StatefulButtonDetector:init()
	self:setState{
		isHovered = false,
		isPressed = false,
		buttonState = "Default"
	}
	
	self.onMouseEnter = function()
		if not self.state.isHovered then
			self:updateStates(true, self.state.isPressed)
		end
	end
	self.onMouseLeave = function()
		if self.state.isHovered then
			self:updateStates(false, self.state.isPressed)
		end
	end
	self.onMouseButton1Down = function()
		local modal = getModal(self)
		if not self.state.isPressed and not (modal.isShowingModal() or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self))) then
			self:updateStates(self.state.isHovered, true)
		end
		
		modal.onButtonPressed(self)
	end
	self.onInputEnded = function(rbx, inputObject)
		local modal = getModal(self)
		if self.state.isPressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:updateStates(self.state.isHovered, false)
		
			if not (modal.isShowingModal() or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self))) and self.state.isHovered then
				if self.props.onClick then
					self.props.onClick()
				end
			end
			
			modal.onButtonReleased()
		end
	end
end

function StatefulButtonDetector:updateStates(isHovered, isPressed)
	local buttonState = "Default"
	local modal = getModal(self)
	if modal.isShowingModal() or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self)) then
		buttonState = "Default"
	elseif isPressed and isHovered then
		buttonState = "PressedInside"
	elseif isPressed and not isHovered then
		buttonState = "PressedOutside"
	elseif isHovered then
		buttonState = "Hovered"
	end
	
	if buttonState ~= self.state.buttonState then
		self:setState{
			isHovered = isHovered,
			isPressed = isPressed,
			buttonState = buttonState
		}
		if self.props.onStateChanged then
			self.props.onStateChanged(buttonState, isHovered, isPressed)
		end
	elseif isHovered ~= self.state.isHovered or isPressed ~= self.state.isPressed then
		self:setState{
			isHovered = isHovered,
			isPressed = isPressed,
		}
		
		self.props.onStateChanged(buttonState, isHovered, isPressed)
	end
end

function StatefulButtonDetector:render()
	local props = self.props
	local Position = props.Position
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local isHovered = self.state.isHovered
	local isPressed = self.state.isPressed
	
	local children = {}
	if props[Roact.Children] then
		for k, v in next, props[Roact.Children] do
			children[k] = v
		end
	end
	
	children.StatefulButton = Roact.createElement(
		PreciseButton,
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseLeave] = self.onMouseLeave,
			[Roact.Event.MouseButton1Down] = self.onMouseButton1Down,
			[Roact.Event.InputEnded] = self.onInputEnded
		}
	)
	
	return Roact.createElement(
		"Frame",
		{
			Position = Position,
			AnchorPoint = AnchorPoint,
			Size = Size,
			LayoutOrder = LayoutOrder,
			ZIndex = ZIndex,
			BackgroundTransparency = 1
		},
		children
	)
end

function StatefulButtonDetector:didMount()
	self.modalDisconnect = getModal(self).modalStatus:subscribe(function()
		self:updateStates(self.state.isHovered, self.state.isPressed)
	end)
end

function StatefulButtonDetector:willUnmount()
	self.modalDisconnect()
end


return StatefulButtonDetector