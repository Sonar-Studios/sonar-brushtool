local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

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
local SetStampSelected = require(Actions.SetStampSelected)
local ClearStampSelected = require(Actions.ClearStampSelected)
local SetStampDeleting = require(Actions.SetStampDeleting)
local ClearStampDeleting = require(Actions.ClearStampDeleting)
local DeleteStampObject = require(Actions.DeleteStampObject)
local SetStampCurrentlyStamping = require(Actions.SetStampCurrentlyStamping)
local ClearStampCurrentlyStamping = require(Actions.ClearStampCurrentlyStamping)

local rotationFormatCallback = Funcs.rotationFormatCallback
local rotationValidateCallback = Funcs.rotationValidateCallback
local rotationFixedOnFocusLost = Funcs.rotationFixedOnFocusLost
local rotationMinOnFocusLost = Funcs.rotationMinOnFocusLost
local rotationMaxOnFocusLost = Funcs.rotationMaxOnFocusLost
local scaleFormatCallback = Funcs.scaleFormatCallback
local scaleValidateCallback = Funcs.scaleValidateCallback
local scaleFixedOnFocusLost = Funcs.scaleFixedOnFocusLost
local scaleMinOnFocusLost = Funcs.scaleMinOnFocusLost
local scaleMaxOnFocusLost = Funcs.scaleMaxOnFocusLost
local verticalOffsetFormatCallback = Funcs.verticalOffsetFormatCallback
local verticalOffsetValidateCallback = Funcs.verticalOffsetValidateCallback
local verticalOffsetFixedOnFocusLost = Funcs.verticalOffsetFixedOnFocusLost
local verticalOffsetMinOnFocusLost = Funcs.verticalOffsetMinOnFocusLost
local verticalOffsetMaxOnFocusLost = Funcs.verticalOffsetMaxOnFocusLost
local formatVector3 = Funcs.formatVector3
local orientationFormatCallback = Funcs.orientationFormatCallback
local orientationValidateCallback = Funcs.orientationValidateCallback
local orientationCustomOnFocusLost = Funcs.orientationCustomOnFocusLost

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local ThemedCheckbox = require(Foundation.ThemedCheckbox)
local ObjectThumbnail = require(Foundation.ObjectThumbnail)
local PreciseButton = require(Foundation.PreciseButton)
local BorderedVerticalList = require(Foundation.BorderedVerticalList)
local VerticalList = require(Foundation.VerticalList)
local CollapsibleTitledSection = require(Foundation.CollapsibleTitledSection)
local TextField = require(Foundation.TextField)
local DropdownField = require(Foundation.DropdownField)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local DeleteButton = require(script.DeleteButton)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local RoundedBorderedVerticalList = require(Foundation.RoundedBorderedVerticalList)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local StampObjectEntry = Roact.PureComponent:extend("StampObjectEntry")

function StampObjectEntry:init()
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
		local currentlyStamping = props.currentlyStamping
		local guid = props.guid
		if not currentlyStamping then
			props.setCurrentlyStamping(guid)
		else
			props.clearCurrentlyStamping()
		end
	end
end

function StampObjectEntry:render()
local props = self.props
	local stale = props.state
	if stale then -- this doesn't seem to do anything?
		return nil
	end
	
	local isHovered = self.state.isHovered
	local isPressed = self.state.isPressed
	local LayoutOrder = props.LayoutOrder
	local guid = props.guid
	local rbxObject = props.rbxObject
	local name = props.name
	local selected = props.selected
	local currentlyStamping = props.currentlyStamping
	local Visible = props.Visible
	local BorderTop = props.BorderTop ~= false
	local BorderBottom = props.BorderBottom ~= false
	local labelWidth = Constants.FIELD_LABEL_WIDTH
	local rotation = props.rotation
	local scale = props.scale
	local verticalOffset = props.verticalOffset
	local orientation = props.orientation
	local deleting = props.deleting

	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end
	
	if props.stale then
		return
	end

	return withTheme(function(theme)
		local buttonTheme = theme.button
		local entryTheme = theme.objectGridEntry
		
		local entryHeight = 60
		local entryPadding = 4
		local rightButtonSize = 40
		local buttonsOnRightSpace = rightButtonSize*1
		local modal = getModal(self)
		local buttonHeight = Constants.BUTTON_HEIGHT
		
		local thumbnailSize = entryHeight-entryPadding*2
		
		local buttonState = self.state.buttonState
		local boxState
		if currentlyStamping then
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
		
		local bgColors = entryTheme.backgroundColor
		local bgColor = bgColors[boxState]
		
		return Roact.createElement(
			RoundedBorderedVerticalList,
			{
				width = UDim.new(1, 0),
				LayoutOrder = props.LayoutOrder,
				BackgroundColor3 = theme.mainBackgroundColor,
				BorderColor3 = theme.borderColor,
			},
			not deleting and 
			{
				Wrap = Roact.createElement(
					"Frame",
					{
						Size = UDim2.new(1, 0, 0, entryHeight),
						BackgroundTransparency = 1,
						Visible = Visible,
						LayoutOrder = 1
					},
					{
						Border = Roact.createElement(
							RoundedBorderedFrame,
							{
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundColor3 = bgColor,
								BorderColor3 = theme.borderColor,
								LayoutOrder = props.LayoutOrder,
								slice = selected and "Top" or "Center"
							}
						),
						Detector = Roact.createElement(
							StatefulButtonDetector,
							{
								Size = UDim2.new(1, -buttonsOnRightSpace, 1, 0),
								BackgroundTransparency = 1,
								onClick = self.onClick,
								onStateChanged = self.onStateChanged
							}
						),
						ImageFrame = Roact.createElement(
							BorderedFrame,
							{
								Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
								Position = UDim2.new(0, entryPadding, 0, entryPadding),
								BackgroundColor3 = theme.mainBackgroundColor,
								BorderColor3 = theme.borderColor,
								ZIndex = 2
							},
							{
								Size = Roact.createElement(
									"Frame",
									{
										Size = UDim2.new(1, -2, 1, -2),
										Position = UDim2.new(0, 1, 0, 1),
										BackgroundTransparency = 1
									},
									{
										Image = Roact.createElement(
											ObjectThumbnail,
											{
												object = rbxObject,
												BackgroundColor3 = theme.mainBackgroundColor,
												ImageTransparency = currentlyStamping and 0 or 0.5,
												ImageColor3 = currentlyStamping and Color3.new(1, 1, 1) or Color3.new(0.5, 0.5, 0.5)
											}
										)
									}
								)
							}
						),
						ContentFrame = Roact.createElement(
							"Frame",
							{
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 1, 0),
								Position = UDim2.new(0, 0, 0, 0),
								ZIndex = 2
							},
							{
								TextLabel = Roact.createElement(
									"TextLabel",
									{
										BackgroundTransparency = 1,
										Font = Constants.FONT_BOLD,
										TextColor3 = currentlyStamping and entryTheme.textColorEnabled or entryTheme.textColorDisabled,
										Size = UDim2.new(1, -thumbnailSize-entryPadding*2-buttonsOnRightSpace-entryPadding, 1, 0),
										Position = UDim2.new(0, thumbnailSize+entryPadding*2, 0, 0),
										Text = name,
										TextSize = Constants.FONT_SIZE_MEDIUM,
										TextXAlignment = Enum.TextXAlignment.Center,
										TextYAlignment = Enum.TextYAlignment.Center,
										TextTruncate = Enum.TextTruncate.AtEnd,
										ZIndex = 9
									}
								),
								DeleteButton = Roact.createElement(
									DeleteButton,
									{
										guid = guid,
										selected = selected
									}
								)
							}
						)
					}
				)
			}
			or
			{
				Wrap = Roact.createElement(
					"Frame",
					{
						Size = UDim2.new(1, 0, 0, entryHeight),
						BackgroundTransparency = 1,
						Visible = Visible,
						LayoutOrder = 1
					},
					{
						Roact.createElement(
							RoundedBorderedFrame,
							{
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundColor3 = entryTheme.backgroundColor.Default,
								BorderColor3 = theme.borderColor,
								LayoutOrder = props.LayoutOrder
							}
						),
						DeleteText = Roact.createElement(
							"TextLabel",
							{
								BackgroundTransparency = 1,
								Font = Constants.FONT_BOLD,
								TextColor3 = entryTheme.textColorEnabled,
								Size = UDim2.new(1, -entryPadding*2, 0, Constants.FONT_SIZE_MEDIUM),
								Position = UDim2.new(0.5, 0, 0, 5),
								Text = string.format("Are you sure you want to delete %s?", name),
								AnchorPoint = Vector2.new(0.5, 0),
								TextSize = Constants.FONT_SIZE_MEDIUM,
								TextXAlignment = Enum.TextXAlignment.Center,
								TextTruncate = Enum.TextTruncate.AtEnd,
								ZIndex = 2
							}
						),
						DeleteButton = Roact.createElement(
							ThemedTextButton,
							{
								Text = "Delete",
								buttonStyle = "Delete",
								Size = UDim2.new(0, 100, 0, buttonHeight),
								AnchorPoint = Vector2.new(1, 1),
								Position = UDim2.new(0.5, -3, 1, -entryPadding),
								ZIndex = 2,
								onClick = function()
									props.clearCurrentlyStamping()
									props.deleteObject(guid)
									props.clearDeleting()
								end
							}
						),
						CancelButton = Roact.createElement(
							ThemedTextButton,
							{
								Text = "Cancel",
								Size = UDim2.new(0, 100, 0, buttonHeight),
								AnchorPoint = Vector2.new(0, 1),
								Position = UDim2.new(0.5, 3, 1, -entryPadding),
								ZIndex = 2,
								onClick = function()
									props.clearDeleting()
								end
							}
						)
					}
				)
			}
		)
	end)
end
	
local function mapStateToProps(state, props)
	-- we mark this as stale if the object was removed from the state.
	-- this is because this gets re-rendered before the grid unmounts it.
	local stamp = state.stamp
	local objects = state.stampObjects
	local guid = props.guid
	local object = objects[guid]
	if object then
		local rbxObject = object.rbxObject
		local currentlyStamping = stamp.currentlyStamping
		
		return {
			rbxObject = rbxObject,
			selected = stamp.selected == guid,
			currentlyStamping = currentlyStamping == guid,
			name = object.name,
			stale = false,
			guid = guid,
			deleting = stamp.deleting == guid,
			rotation = object.rotation,
			scale = object.scale,
			verticalOffset = object.verticalOffset,
			orientation = object.orientation,
			centerMode = object.stampCenterMode,
			hasPrimaryPart = rbxObject:IsA("Model") and rbxObject.PrimaryPart ~= nil
		}
	else
		return {
			stale = true
		}
	end
end
	
local function mapDispatchToProps(dispatch)
	return {
		setSelected = function(guid) dispatch(SetStampSelected(guid)) end,
		clearSelected = function() dispatch(ClearStampSelected()) end,
		setDeleting = function(guid) dispatch(SetStampDeleting(guid)) end,
		clearDeleting = function() dispatch(ClearStampDeleting()) end,
		deleteObject = function(guid) dispatch(DeleteStampObject(guid)) end,
		setCurrentlyStamping = function(guid) dispatch(SetStampCurrentlyStamping(guid)) end,
		clearCurrentlyStamping = function() dispatch(ClearStampCurrentlyStamping()) end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(StampObjectEntry)