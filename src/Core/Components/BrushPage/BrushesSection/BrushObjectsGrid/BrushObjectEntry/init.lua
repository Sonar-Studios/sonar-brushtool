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
local SetBrushSelected = require(Actions.SetBrushSelected)
local ClearBrushSelected = require(Actions.ClearBrushSelected)
local SetBrushDeleting = require(Actions.SetBrushDeleting)
local ClearBrushDeleting = require(Actions.ClearBrushDeleting)
local SetBrushObjectBrushEnabled = require(Actions.SetBrushObjectBrushEnabled)
local SetBrushObjectRotationMode = require(Actions.SetBrushObjectRotationMode)
local SetBrushObjectRotationFixed = require(Actions.SetBrushObjectRotationFixed)
local SetBrushObjectRotationMin = require(Actions.SetBrushObjectRotationMin)
local SetBrushObjectRotationMax = require(Actions.SetBrushObjectRotationMax)
local SetBrushObjectScaleMode = require(Actions.SetBrushObjectScaleMode)
local SetBrushObjectScaleFixed = require(Actions.SetBrushObjectScaleFixed)
local SetBrushObjectScaleMin = require(Actions.SetBrushObjectScaleMin)
local SetBrushObjectScaleMax = require(Actions.SetBrushObjectScaleMax)
local SetBrushObjectWobbleMode = require(Actions.SetBrushObjectWobbleMode)
local SetBrushObjectWobbleMin = require(Actions.SetBrushObjectWobbleMin)
local SetBrushObjectWobbleMax = require(Actions.SetBrushObjectWobbleMax)
local SetBrushObjectVerticalOffsetMode = require(Actions.SetBrushObjectVerticalOffsetMode)
local SetBrushObjectVerticalOffsetFixed = require(Actions.SetBrushObjectVerticalOffsetFixed)
local SetBrushObjectVerticalOffsetMin = require(Actions.SetBrushObjectVerticalOffsetMin)
local SetBrushObjectVerticalOffsetMax = require(Actions.SetBrushObjectVerticalOffsetMax)
local SetBrushObjectOrientationMode = require(Actions.SetBrushObjectOrientationMode)
local SetBrushObjectOrientationCustom = require(Actions.SetBrushObjectOrientationCustom)
local SetBrushObjectBrushCenterMode = require(Actions.SetBrushObjectBrushCenterMode)
local DeleteBrushObject = require(Actions.DeleteBrushObject)

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
local OverrideButton = require(script.OverrideButton)
local NumericalSliderField = require(Foundation.NumericalSliderField)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local RoundedBorderedVerticalList = require(Foundation.RoundedBorderedVerticalList)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local BrushObjectEntry = Roact.PureComponent:extend("BrushObjectEntry")

function BrushObjectEntry:init()
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
		local enabled = props.enabled
		local guid = props.guid
		if not enabled then
			props.setBrushObjectEnabled(guid, true)
		else
			props.setBrushObjectEnabled(guid, false)
		end
	end
end

function BrushObjectEntry:render()
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
	local enabled = props.enabled
	local Visible = props.Visible
	local labelWidth = Constants.FIELD_LABEL_WIDTH
	local rotation = props.rotation
	local scale = props.scale
	local wobble = props.wobble
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
		local buttonsOnRightSpace = rightButtonSize*2
		local modal = getModal(self)
		local buttonHeight = Constants.BUTTON_HEIGHT
		
		local thumbnailSize = entryHeight-entryPadding*2
		
		local buttonState = self.state.buttonState
		local boxState
		if enabled then
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
												ImageTransparency = enabled and 0 or 0.5,
												ImageColor3 = enabled and Color3.new(1, 1, 1) or Color3.new(0.5, 0.5, 0.5)
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
										TextColor3 = enabled and entryTheme.textColorEnabled or entryTheme.textColorDisabled,
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
								OverrideButton = Roact.createElement(
									OverrideButton,
									{
										guid = guid,
										selected = selected
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
				),
				Overrides = selected and not deleting and Roact.createElement(
					VerticalList,
					{
						width = UDim.new(1, 0),
						LayoutOrder = 2
					},
					{
						List = Roact.createElement(
							VerticalList,
							{
								width = UDim.new(1, 0),
								LayoutOrder = 2,
								PaddingTopPixel = 4,
								PaddingBottomPixel = 4,
								ElementPaddingPixel = 4
							},
							{
								Rotation = Roact.createElement(
									DropdownField,
									{
										label = "Rotation",
										indentLevel = 0,
										labelWidth = labelWidth,
										entries = {
											{ id = "NoOverride", text = "(do not override)", entryStyle = "Inactive" },
											{ id = "None", text = "Do not rotate" },
											{ id = "Fixed", text = "Fixed" },
											{ id = "Random", text = "Random" },
										},
										inactive = rotation.mode == "NoOverride",
										selectedId = rotation.mode,
										LayoutOrder = generateSequentialLayoutOrder(),
										onSelected = function(mode) props.setRotationMode(guid, mode) end
									}
								),
								RotationFixed = rotation.mode == "Fixed" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Angle",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_ROTATION,
										maxValue = Constants.MAX_ROTATION,
										textboxWidthPixel = 50,
										valueRound = 0.1,
										valueSnap = 15,
										value = rotation.fixed,
										onValueChanged = function(newValue)
											props.setRotationFixed(guid, newValue)
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 1,
										maxCharacters = 6
									}
								),
								RotationMin = rotation.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Min Angle",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_ROTATION,
										maxValue = Constants.MAX_ROTATION,
										textboxWidthPixel = 50,
										valueRound = 0.1,
										valueSnap = 15,
										value = rotation.min,
										onValueChanged = function(newValue)
											props.setRotationMin(guid, newValue)
											if newValue > rotation.max then
												props.setRotationMax(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 1,
										maxCharacters = 6
									}
								),
								RotationMax = rotation.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Max Angle",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_ROTATION,
										maxValue = Constants.MAX_ROTATION,
										textboxWidthPixel = 50,
										valueRound = 0.1,
										valueSnap = 15,
										value = rotation.max,
										onValueChanged = function(newValue)
											props.setRotationMax(guid, newValue)
											if newValue < rotation.min then
												props.setRotationMin(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 1,
										maxCharacters = 6
									}
								),
								Scale = Roact.createElement(
									DropdownField,
									{
										label = "Scale",
										indentLevel = 0,
										labelWidth = labelWidth,
										entries = {
											{ id = "NoOverride", text = "(do not override)", entryStyle = "Inactive" },
											{ id = "None", text = "Do not scale" },
											{ id = "Fixed", text = "Fixed" },
											{ id = "Random", text = "Random" },
										},
										inactive = scale.mode == "NoOverride",
										selectedId = scale.mode,
										LayoutOrder = generateSequentialLayoutOrder(),
										onSelected = function(mode) props.setScaleMode(guid, mode) end
									}
								),
								ScaleFixed = scale.mode == "Fixed" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Factor",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_SCALE,
										maxValue = Constants.MAX_SCALE,
										textboxWidthPixel = 50,
										valueRound = 0.01,
										valueSnap = 0.1,
										value = scale.fixed,
										onValueChanged = function(newValue)
											props.setScaleFixed(guid, newValue)
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								ScaleMin = scale.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Min Factor",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_SCALE,
										maxValue = Constants.MAX_SCALE,
										textboxWidthPixel = 50,
										valueRound = 0.01,
										valueSnap = 0.1,
										value = scale.min,
										onValueChanged = function(newValue)
											props.setScaleMin(guid, newValue)
											if newValue > scale.max then
												props.setScaleMax(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								ScaleMax = scale.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Max Factor",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_SCALE,
										maxValue = Constants.MAX_SCALE,
										textboxWidthPixel = 50,
										valueRound = 0.01,
										valueSnap = 0.1,
										value = scale.max,
										onValueChanged = function(newValue)
											props.setScaleMax(guid, newValue)
											if newValue < scale.min then
												props.setScaleMin(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								Wobble = Roact.createElement(
									DropdownField,
									{
										label = "Wobble",
										indentLevel = 0,
										labelWidth = labelWidth,
										entries = {
											{ id = "NoOverride", text = "(do not override)", entryStyle = "Inactive" },
											{ id = "None", text = "Do not wobble" },
											{ id = "Random", text = "Random" },
										},
										inactive = wobble.mode == "NoOverride",
										selectedId = wobble.mode,
										LayoutOrder = generateSequentialLayoutOrder(),
										onSelected = function(mode) props.setWobbleMode(guid, mode) end
									}
								),
								WobbleMin = wobble.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Min Angle",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_WOBBLE,
										maxValue = Constants.MAX_WOBBLE,
										textboxWidthPixel = 50,
										valueRound = 0.1,
										valueSnap = 5,
										value = wobble.min,
										onValueChanged = function(newValue)
											props.setWobbleMin(guid, newValue)
											if newValue > wobble.max then
												props.setWobbleMax(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								WobbleMax = wobble.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Max Angle",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_WOBBLE,
										maxValue = Constants.MAX_WOBBLE,
										textboxWidthPixel = 50,
										valueRound = 0.1,
										valueSnap = 5,
										value = wobble.max,
										onValueChanged = function(newValue)
											props.setWobbleMax(guid, newValue)
											if newValue < wobble.min then
												props.setWobbleMin(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								Orientation = Roact.createElement(
									DropdownField,
									{
										label = "Orientation",
										indentLevel = 0,
										labelWidth = labelWidth,
										entries = {
											{ id = "NoOverride", text = "(do not override)", entryStyle = "Inactive" },
											{ id = "Normal", text = "Normal" },
											{ id = "Up", text = "Up" },
											{ id = "Custom", text = "Custom" }
										},
										inactive = orientation.mode == "NoOverride",
										selectedId = orientation.mode,
										LayoutOrder = generateSequentialLayoutOrder(),
										onSelected = function(mode) 
											props.setOrientationMode(guid, mode)
										end
									}
								),
								OrientationCustom = orientation.mode == "Custom" and Roact.createElement(
									TextField,
									{
										label = "Custom",
										indentLevel = 1,
										labelWidth = labelWidth,
										textInput = formatVector3(orientation.custom.x, orientation.custom.y, orientation.custom.z),
										LayoutOrder = generateSequentialLayoutOrder(),
										textFormatCallback = orientationFormatCallback,
										onFocusLost = orientationCustomOnFocusLost(
											orientation.custom, 
											function(custom) props.setOrientationCustom(guid, custom) 
										end),
										newTextValidateCallback = orientationValidateCallback
									}
								),
								VerticalOffset = Roact.createElement(
									DropdownField,
									{
										label = "Vertical Offset",
										indentLevel = 0,
										labelWidth = labelWidth,
										entries = {
											{ id = "Auto", text = "Auto" },
											{ id = "Fixed", text = "Fixed" },
											{ id = "Random", text = "Random" },
										},
										selectedId = verticalOffset.mode,
										LayoutOrder = generateSequentialLayoutOrder(),
										onSelected = function(mode) props.setOffsetMode(guid, mode) end
									}
								),
								VerticalOffsetFixed = verticalOffset.mode == "Fixed" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Studs",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_VERTICAL_OFFSET,
										maxValue = Constants.MAX_VERTICAL_OFFSET,
										textboxWidthPixel = 50,
										valueRound = 0.01,
										valueSnap = 1,
										value = verticalOffset.fixed,
										onValueChanged = function(newValue)
											props.setOffsetFixed(guid, newValue)
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								VerticalOffsetMin = verticalOffset.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Min Studs",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_VERTICAL_OFFSET,
										maxValue = Constants.MAX_VERTICAL_OFFSET,
										textboxWidthPixel = 50,
										valueRound = 0.01,
										valueSnap = 1,
										value = verticalOffset.min,
										onValueChanged = function(newValue)
											props.setOffsetMin(guid, newValue)
											if newValue > verticalOffset.max then
												props.setOffsetMax(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								VerticalOffsetMax = verticalOffset.mode == "Random" and Roact.createElement(
									NumericalSliderField,
									{
										label = "Max Studs",
										indentLevel = 1,
										labelWidth = labelWidth,
										LayoutOrder = generateSequentialLayoutOrder(),
										minValue = Constants.MIN_VERTICAL_OFFSET,
										maxValue = Constants.MAX_VERTICAL_OFFSET,
										textboxWidthPixel = 50,
										valueRound = 0.01,
										valueSnap = 1,
										value = verticalOffset.max,
										onValueChanged = function(newValue)
											props.setOffsetMax(guid, newValue)
											if newValue < verticalOffset.min then
												props.setOffsetMin(guid, newValue)
											end
										end,
										isValueIntegral = false,
										decimalPlacesToShow = 2,
										maxCharacters = 6
									}
								),
								CenterMode = Roact.createElement(
									DropdownField,
									{
										label = "Centered At",
										indentLevel = 0,
										labelWidth = labelWidth,
										entries = {
											{ id = "BoundingBox", text = "Bounding Box" },
											{ id = "PrimaryPart", text = "Primary Part" }
										},
										selectedId = props.centerMode,
										LayoutOrder = generateSequentialLayoutOrder(),
										enabled = props.hasPrimaryPart,
										onSelected = function(mode) props.setCenterMode(guid, mode) end,
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
	local brush = state.brush
	local objects = state.brushObjects
	local guid = props.guid
	local object = objects[guid]
	if object then
		local rbxObject = object.rbxObject
		local selected = brush.selected
		
		return {
			rbxObject = rbxObject,
			selected = brush.selected == guid,
			name = object.name,
			enabled = object.brushEnabled,
			stale = false,
			guid = guid,
			rotation = object.rotation,
			scale = object.scale,
			wobble = object.wobble,
			verticalOffset = object.verticalOffset,
			orientation = object.orientation,
			centerMode = object.brushCenterMode,
			deleting = brush.deleting == guid,
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
		setSelected = function(guid) dispatch(SetBrushSelected(guid)) end,
		clearSelected = function() dispatch(ClearBrushSelected()) end,
		setDeleting = function(guid) dispatch(SetBrushDeleting(guid)) end,
		clearDeleting = function() dispatch(ClearBrushDeleting()) end,
		deleteObject = function(guid) dispatch(DeleteBrushObject(guid)) end,
		setBrushObjectEnabled = function(guid, enabled) dispatch(SetBrushObjectBrushEnabled(guid, enabled)) end,
		setRotationMode = function(guid, mode) dispatch(SetBrushObjectRotationMode(guid, mode)) end,
		setRotationFixed = function(guid, fixed) dispatch(SetBrushObjectRotationFixed(guid, fixed)) end,
		setRotationMin = function(guid, min) dispatch(SetBrushObjectRotationMin(guid, min)) end,
		setRotationMax = function(guid, max) dispatch(SetBrushObjectRotationMax(guid, max)) end,
		setScaleMode = function(guid, mode) dispatch(SetBrushObjectScaleMode(guid, mode)) end,
		setScaleFixed = function(guid, fixed) dispatch(SetBrushObjectScaleFixed(guid, fixed)) end,
		setScaleMin = function(guid, min) dispatch(SetBrushObjectScaleMin(guid, min)) end,
		setScaleMax = function(guid, max) dispatch(SetBrushObjectScaleMax(guid, max)) end,
		setWobbleMode = function(guid, mode) dispatch(SetBrushObjectWobbleMode(guid, mode)) end,
		setWobbleMin = function(guid, min) dispatch(SetBrushObjectWobbleMin(guid, min)) end,
		setWobbleMax = function(guid, max) dispatch(SetBrushObjectWobbleMax(guid, max)) end,
		setOffsetMode = function(guid, mode) dispatch(SetBrushObjectVerticalOffsetMode(guid, mode)) end,
		setOffsetFixed = function(guid, fixed) dispatch(SetBrushObjectVerticalOffsetFixed(guid, fixed)) end,
		setOffsetMin = function(guid, min) dispatch(SetBrushObjectVerticalOffsetMin(guid, min)) end,
		setOffsetMax = function(guid, max) dispatch(SetBrushObjectVerticalOffsetMax(guid, max)) end,
		setOrientationMode = function(guid, mode) dispatch(SetBrushObjectOrientationMode(guid, mode)) end,
		setOrientationCustom = function(guid, custom) dispatch(SetBrushObjectOrientationCustom(guid, custom)) end,
		setCenterMode = function(guid, centerMode) dispatch(SetBrushObjectBrushCenterMode(guid, centerMode)) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BrushObjectEntry)