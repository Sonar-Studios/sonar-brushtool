local Plugin = script.Parent.Parent.Parent.Parent

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

local ThemedTextBox = Roact.PureComponent:extend("ThemedTextBox")

function ThemedTextBox:init()
	self.lastValidText = self.props.textInput or ""
end

function ThemedTextBox:render()
	local props = self.props
	local textInput = props.textInput or ""
	local Size = props.Size or UDim2.new(1, 0, 0, Constants.INPUT_FIELD_BOX_HEIGHT)
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local TextSize = props.TextSize or Constants.FONT_SIZE_MEDIUM
	local AnchorPoint = props.AnchorPoint
	local onFocused = props.onFocused
	local placeholderText = props.placeholderText
	local onFocusLost = props.onFocusLost or function(t) return t end
	local textFormatCallback = props.textFormatCallback or function(t) return t end
	local newTextValidateCallback = props.newTextValidateCallback or function() return true end
	local onInputChanged = props.onInputChanged or function() return end
	
	return withTheme(function(theme)
		return withModal(function()
			local modal = getModal(self)
			local fieldTheme = theme.textField
			local textPadding = Constants.INPUT_FIELD_TEXT_PADDING
			local fontSize = Constants.FONT_SIZE_MEDIUM
			local font = Constants.FONT
			local inputColor = fieldTheme.box.textColor
			local isHovered = self.state.isHovered
			local isFocused = self.state.isFocused
			
			local boxState
			if isFocused then
				boxState = "Focused"
			elseif isHovered and not (modal.isShowingModal() or modal.isAnyButtonPressed()) then
				boxState = "Hovered"
			else
				boxState = "Default"
			end
			
			local borderColor
			if boxState == "Focused" then
				borderColor = fieldTheme.box.borderColor.Selected
			elseif boxState == "Hovered" then
				borderColor = fieldTheme.box.borderColor.Hover
			else
				borderColor = fieldTheme.box.borderColor.Default
			end
			
			local backgroundColor
			if boxState == "Focused" then
				backgroundColor = fieldTheme.box.backgroundColor.Selected
			elseif boxState == "Hovered" then
				backgroundColor = fieldTheme.box.backgroundColor.Hover
			else
				backgroundColor = fieldTheme.box.backgroundColor.Default
			end
			
			local placeholderColor = fieldTheme.box.placeholderColor
			
			local children = {}
			if props[Roact.Children] then
				for key, child in next, props[Roact.Children] do
					children[key] = child
				end
			end
			
			children.Input = Roact.createElement(
				"TextBox",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -textPadding*2, 1, 0),
					Position = UDim2.new(0, textPadding, 0, 0),
					Font = font,
					TextSize = fontSize,
					TextColor3 = inputColor,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false,
					Text = textFormatCallback(textInput),
					TextTruncate = Enum.TextTruncate.AtEnd,
					PlaceholderText = placeholderText,
					PlaceholderColor3 = placeholderColor,
					[Roact.Event.Focused] = function(rbx)
						if (modal.isShowingModal() or modal.isAnyButtonPressed()) then
							self.focusDebounce = true
							rbx:ReleaseFocus(false)
							self.focusDebounce = false
							return
						end
						
						if not isFocused then
							rbx.Text = textInput
							self:setState(
								{
									isFocused = true
								}
							)
							if onFocused then
								onFocused()
							end
						end
					end,
					[Roact.Event.FocusLost] = function(rbx, enterPressed, input)
						if isFocused and not self.focusDebounce then
							self:setState(
								{
									isFocused = false
								}
							)
							local text = onFocusLost(rbx.Text, enterPressed, input)
							if text ~= nil then
								self.changeDebounce = true
								rbx.Text = textFormatCallback(text)
								self.changeDebounce = false
							else
								self.changeDebounce = true
								rbx.Text = textFormatCallback(textInput)
								self.changeDebounce = false
							end
						end
					end,
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
					[Roact.Ref] = function(rbx)
						if rbx then
							self.changedConn = rbx:GetPropertyChangedSignal("Text"):Connect(function()
								if self.changeDebounce then return end
								if not self.state.isFocused then return end
								local newText = rbx.Text
								if not newTextValidateCallback(newText) then
									self.changeDebounce = true
									rbx.Text = self.lastValidText
									self.changeDebounce = false
								else
									if onInputChanged then
										onInputChanged(newText)
									end
									self.lastValidText = newText
								end
							end)
						else
							self.changedConn:Disconnect()
						end
					end
				}
			)
						
			return Roact.createElement(
				RoundedBorderedFrame,
				{
					Size = Size,
					BackgroundColor3 = backgroundColor,
					BorderColor3 = borderColor,
					Position = Position,
					AnchorPoint = AnchorPoint
				},
				children
			)
		end)
	end)
end

return ThemedTextBox