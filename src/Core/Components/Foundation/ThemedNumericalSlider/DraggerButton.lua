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

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)

local DraggerButton = Roact.PureComponent:extend("DraggerButton")

function DraggerButton:init()
	self:setState(
		{
			isHovered = false,
			isPressed = false
		}
	)
end

function DraggerButton:render()
	local props = self.props
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local checked = props.checked or false
	local isHovered = self.state.isHovered
	local isPressed = self.state.isPressed
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size or UDim2.new(0, 100, 0, 100)
	local dragBegan = props.dragBegan
	local dragEnded = props.dragEnded
	local dragMoved = props.dragMoved
	local LayoutOrder = props.LayoutOrder
	local disabled = props.disabled
	local Font = props.Font or Constants.FONT
	local ZIndex = props.ZIndex
	local percent = props.percent
	
	return withTheme(function(theme)
		local buttonTheme = theme.button
		return Roact.createElement(
			"TextButton",
			{
				Text = "",
				ZIndex = ZIndex,
				BackgroundTransparency = 1,
				Size = Size,
				Position = Position,
				AnchorPoint = AnchorPoint,
				[Roact.Event.MouseButton1Down] = function(rbx, x, y)
					local modal = getModal(self)
					if props.dragBegan then
						props.dragBegan(x, y)
					end
					
					self:setState({
						isPressed = true
					})
					
					modal.onButtonPressed(self)
				end,
				[Roact.Event.InputEnded] = function(rbx, inputObject)
					local modal = getModal(self)
					if self.state.isPressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
						-- I can't do this after onClick for some reason...								
						self:setState({
							isPressed = false
						})
						
						if not disabled and not (modal.isShowingModal() or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self))) then
							if dragEnded then
								dragEnded(inputObject.Position.X, inputObject.Position.Y)
							end
						end
						
						modal.onButtonReleased()
					end
				end
			},
			{
				Button = (function()
					if isHovered then
						return withModal(function()
							local modal = getModal(self)
							
							local boxState
							if disabled then
								boxState = "Disabled"
							elseif modal.isShowingModal() or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self)) then
								boxState = "Default"
							elseif isPressed then
								boxState = "PressedInside"
							elseif isHovered then
								boxState = "Hovered"
							else
								boxState = "Default"
							end
							
							local borderColor = buttonTheme.box.borderColor.Default[boxState]
							local backgroundColor = buttonTheme.box.backgroundColor.Default[boxState]
							
							return Roact.createElement(
								RoundedBorderedFrame,
								{
									Size = UDim2.new(0, Constants.SLIDER_BUTTON_WIDTH, 0, Constants.SLIDER_BUTTON_HEIGHT),
									BackgroundColor3 = backgroundColor,
									BorderColor3 = borderColor,
									Position = UDim2.new(percent, 0, 0.5, 0),
									AnchorPoint = Vector2.new(0.5, 0.5)
								}
							)
						end)
					else
						local modal = getModal(self)
						
						local boxState
						if disabled then
							boxState = "Disabled"
						elseif isPressed then
							boxState = "PressedInside"
						elseif isHovered then
							boxState = "Hovered"
						else
							boxState = "Default"
						end
						
						local borderColor = buttonTheme.box.borderColor.Default[boxState]
						local backgroundColor = buttonTheme.box.backgroundColor.Default[boxState]
									
						return Roact.createElement(
							RoundedBorderedFrame,
							{
								Size = UDim2.new(0, Constants.SLIDER_BUTTON_WIDTH, 0, Constants.SLIDER_BUTTON_HEIGHT),
								BackgroundColor3 = backgroundColor,
								BorderColor3 = borderColor,
								Position = UDim2.new(percent, 0, 0.5, 0),
								AnchorPoint = Vector2.new(0.5, 0.5)
							}
						)
					end
				end)(),
				DragButton = Roact.createElement(
					"TextButton",
					{
						Text = "",
						Size = UDim2.new(0, Constants.SLIDER_BUTTON_WIDTH, 0, Constants.SLIDER_BUTTON_HEIGHT),
						Position = UDim2.new(percent, 0, 0.5, 0),
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						[Roact.Event.MouseEnter] = function()
							if not isHovered then
								self:setState(
									{
										isHovered = true
									}
								)
							end
						end,
						[Roact.Event.MouseLeave] = function()
							if isHovered then
								self:setState(
									{
										isHovered = false
									}
								)
							end
						end,
						[Roact.Event.MouseButton1Down] = function(rbx, x, y)
							local modal = getModal(self)
							if not self.state.isPressed and not (modal.isShowingModal() or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self))) then									
								if props.dragBegan then
									props.dragBegan(x, y)
								end
								
								self:setState({
									isPressed = true
								})
								
								modal.onButtonPressed(self)
							end
						end,
						[Roact.Event.InputEnded] = function(rbx, inputObject)
							local modal = getModal(self)
							if self.state.isPressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
								-- I can't do this after onClick for some reason...								
								self:setState({
									isPressed = false
								})
								
								if not disabled and not (modal.isShowingModal() or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self))) then
									if dragEnded then
										dragEnded(inputObject.Position.X, inputObject.Position.Y)
									end
								end
								
								modal.onButtonReleased()
							end
						end
					}
				),
				Portal = isPressed and withModal(function(modalTarget)
					return Roact.createElement(
						Roact.Portal, 
						{
							target = modalTarget,
						}, 
						{
							Detector = Roact.createElement(
								"TextButton",
								{
									Text = "",
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1,
									ZIndex = 10,
									[Roact.Event.MouseMoved] = function(rbx, x, y)
										if dragMoved then
											dragMoved(x, y)
										end
									end
								}
							)
						}
					)
				end)
			}
		)
	end)
end
	
function DraggerButton:didMount()
--	local props = self.props
--	self.changeConn = game:GetService("UserInputService").InputChanged:Connect(function(inputObject, gameProcessedEvent)
--		print(inputObject.Delta)
--		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
--			local delta = inputObject.Delta
--			print(delta)
--		end
--	end)
end

function DraggerButton:willUnmount()
--	self.changeConn:Disconnect()
end

return DraggerButton