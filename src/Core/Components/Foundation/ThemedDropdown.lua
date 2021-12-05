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
local RoundedBorderedFrame = require(Components.Foundation.RoundedBorderedFrame)

local ThemedDropdown = Roact.PureComponent:extend("ThemedDropdown")

function ThemedDropdown:init()
	self:setState(
		{
			isOpen = false,
			isHovered = false,
			dropdownHighlightId = nil
		}
	)
	
	self.boxRef = Roact.createRef()
end

function ThemedDropdown:render()
	local props = self.props
	local Size = props.Size or UDim2.new(1, 0, 0, Constants.INPUT_FIELD_BOX_HEIGHT)
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local entries = props.entries
	local selectedId = props.selectedId
	local isOpen = self.state.isOpen
	local isHovered = self.state.isHovered
	local AnchorPoint = props.AnchorPoint
	local ZIndex = props.ZIndex
	local onSelected = props.onSelected
	local enabled = props.enabled ~= false
	local Visible = props.Visible ~= false
	local inactive = props.inactive or false
	
	return withTheme(function(theme)
		local fieldTheme = theme.dropdownField
		local textPadding = Constants.INPUT_FIELD_TEXT_PADDING
		local boxPadding = Constants.INPUT_FIELD_BOX_PADDING
		local fontSize = Constants.FONT_SIZE_MEDIUM
		local font = Constants.FONT
		local arrowColor = fieldTheme.box.arrowColor
		local arrowImage = Constants.DROPDOWN_ARROW_IMAGE
		local entryHeight = Constants.DROPDOWN_ENTRY_HEIGHT
		local dropdownBorderColor = fieldTheme.dropdown.borderColor
		local dropdownFrameColor = fieldTheme.dropdown.backgroundColor
		local highlightColor = fieldTheme.dropdown.highlightColor
				
		local selectedText = ""
		for _, entry in next, entries do
			if entry.id == selectedId then
				selectedText = entry.text
			end
		end
		
		return Roact.createElement(
			"Frame",
			{
				Size = Size,
				Position = Position,
				AnchorPoint = AnchorPoint,
				ZIndex = ZIndex,
				Visible = Visible,
				BackgroundTransparency = 1,
				[Roact.Ref] = self.boxRef,
			},
			{
				-- optimization to reduce re-rendered whenever modal is updated.
				Border = (function()
					if isHovered then
						return withModal(function()
							local modal = getModal(self)
							local boxState
							if not enabled then
								boxState = "Disabled"
							elseif isOpen then
								boxState = "Open"
							elseif isHovered and not (modal.isShowingModal() or modal.isAnyButtonPressed()) then
								boxState = "Hovered"
							else
								boxState = "Default"
							end
							
							local textState
							if boxState == "Disabled" then
								textState = "Disabled"
							elseif inactive then
								textState = "Inactive"
							else
								textState = "Default"
							end
							
							local borderColor = fieldTheme.box.borderColor[boxState]
							local backgroundColor = fieldTheme.box.backgroundColor[boxState]
							local textColor = fieldTheme.box.textColor[textState]
							
							return Roact.createElement(
								RoundedBorderedFrame,
								{
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundColor3 = backgroundColor,
									BorderColor3 = borderColor,
									Position = UDim2.new(),
									ZIndex = -1
								},
								{
									Text = Roact.createElement(
										"TextLabel",
										{
											BackgroundTransparency = 1,
											Size = UDim2.new(1, -textPadding*2, 1, 0),
											Position = UDim2.new(0, textPadding, 0, 0),
											Font = font,
											TextSize = fontSize,
											TextColor3 = textColor,
											TextXAlignment = Enum.TextXAlignment.Left,
											Text = selectedText,
											TextTruncate = Enum.TextTruncate.AtEnd,
											Visible = Visible
										}
									),
								}
							)
						end)
					else
						local boxState
						if not enabled then
							boxState = "Disabled"
						elseif isOpen then
							boxState = "Open"
						elseif isHovered then
							boxState = "Hovered"
						else
							boxState = "Default"
						end
						
						local textState
						if boxState == "Disabled" then
							textState = "Disabled"
						elseif inactive then
							textState = "Inactive"
						else
							textState = "Default"
						end
						
						local borderColor = fieldTheme.box.borderColor[boxState]
						local backgroundColor = fieldTheme.box.backgroundColor[boxState]
						local textColor = fieldTheme.box.textColor[textState]
						
						return Roact.createElement(
							RoundedBorderedFrame,
							{
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundColor3 = backgroundColor,
								BorderColor3 = borderColor,
								Position = UDim2.new(),
								ZIndex = -1
							},
							{
								Text = Roact.createElement(
									"TextLabel",
									{
										BackgroundTransparency = 1,
										Size = UDim2.new(1, -textPadding*2, 1, 0),
										Position = UDim2.new(0, textPadding, 0, 0),
										Font = font,
										TextSize = fontSize,
										TextColor3 = textColor,
										TextXAlignment = Enum.TextXAlignment.Left,
										Text = selectedText,
										TextTruncate = Enum.TextTruncate.AtEnd,
										Visible = Visible
									}
								),
							}
						)
					end
				end)(),
				Arrow = Roact.createElement(
					"ImageLabel",
					{
						Image = arrowImage,
						BackgroundTransparency = 1,
						ImageColor3 = arrowColor,
						Position = UDim2.new(1, -4, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						Size = UDim2.new(0, 12, 0, 12),
						Visible = Visible
					}
				),
				Button = Roact.createElement(
					"TextButton",
					{
						Text = "",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						Visible = Visible,
						[Roact.Event.MouseEnter] = Visible and function()
							if not isHovered then
								self:setState(
									{
										isHovered = true
									}
								)
							end
						end,
						[Roact.Event.MouseLeave] = Visible and function()
							if isHovered then
								self:setState(
									{
										isHovered = false
									}
								)
							end
						end,
						[Roact.Event.MouseButton1Down] = Visible and (not isOpen) and function()
							if isOpen then
								self:setState(
									{
										isOpen = false
									}
								)
								if props.onOpen then
									props.onClose()
								end
								getModal(self).onDropdownClosed()
							else
								if not enabled then return end
								self:setState(
									{
										isOpen = true,
										dropdownHighlightId = selectedId
									}
								)
								if props.onOpen then
									props.onOpen()
								end
								getModal(self).onDropdownOpened()
							end
						end
					}
				),
				-- Portal is nicked from toolbox
				Portal = isOpen and Roact.createElement(
					Roact.Portal, 
					{
						target = getModal(self).modalTarget,
					}, 
					{
						-- Consume all clicks outside the dropdown to close it when it "loses focus"
						ClickEventDetectFrame = Roact.createElement(
							"ImageButton", 
							{
								ZIndex = 10,
								Position = UDim2.new(0, 0, 0, 0),
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1,
								AutoButtonColor = false,
		
								[Roact.Event.MouseButton1Down] = function(rbx, x, y)
									if isOpen then
										self:setState(
											{
												isOpen = false
											}
										)
										if props.onClose then
											props.onClose()
										end
										getModal(self).onDropdownClosed()
									end
								end
							}, 
							{
								-- Also block all scrolling events going through
								ScrollBlocker = Roact.createElement(
									"ScrollingFrame", 
									{
										Size = UDim2.new(1, 0, 1, 0),
										-- We need to have ScrollingEnabled = true for this frame for it to block
										-- But we don't want it to actually scroll, so its canvas must be same size as the frame
										ScrollingEnabled = true,
										CanvasSize = UDim2.new(1, 0, 1, 0),
										BackgroundTransparency = 1,
										BorderSizePixel = 0,
										ScrollBarThickness = 0,
									}, 
									{
										DropdownWrap = withModal(function(modalTarget)
											local box = self.boxRef.current
											local dropdownHeight = #entries*entryHeight
											local dropdownTopLeft = box and (box.AbsolutePosition + Vector2.new(0, box.AbsoluteSize.Y)) or Vector2.new()
											-- account for the edges of the screen
											if box then
												local dropdownBottomRight = dropdownTopLeft + Vector2.new(box.AbsoluteSize.X, dropdownHeight)
												local screenSize = modalTarget.AbsoluteSize
												if dropdownBottomRight.X > screenSize.X or dropdownBottomRight.Y > screenSize.Y then
													dropdownTopLeft = box.AbsolutePosition - Vector2.new(0, dropdownHeight)
												end
											end
											local dropdownWidth = box and box.AbsoluteSize.X -- BUG: When the plugin is resized, the dropdown doesn't resize with it.

											return Roact.createElement(
												"Frame",
												{
													Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight),
													Position = UDim2.new(0, dropdownTopLeft.X, 0, dropdownTopLeft.Y),
													BackgroundTransparency = 1
												},
												{
													DropShadow = Roact.createElement(
														"ImageLabel",
														{
															Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight),
															ZIndex = 1,
															Position = UDim2.new(0, 4, 0, 4),
															BackgroundTransparency = 1,
															Image = Constants.DROP_SHADOW_SLICE_IMAGE,
															ScaleType = Enum.ScaleType.Slice,
															SliceCenter = Rect.new(23, 23, 46, 46),
															SliceScale = 0.125
														}
													),
													DropdownFrame = Roact.createElement(
														RoundedBorderedFrame,
														{
															Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight),
															BorderColor3 = dropdownBorderColor,
															BackgroundColor3 = dropdownFrameColor,
															Position = UDim2.new(0, 0, 0, 0),
															ZIndex = 2
														},
														(function()
															local children = {}
															local dropdownHighlightId = self.state.dropdownHighlightId
															if dropdownHighlightId then
																local highlightIndex
																for idx, entry in next, entries do
																	if entry.id == dropdownHighlightId then
																		highlightIndex = idx
																	end
																end
																
																if highlightIndex then
																	local borderTop, borderBottom = 0, 0
																	if highlightIndex == 1 then
																		borderTop = 1
																	elseif highlightIndex == #entries then
																		borderBottom = 1
																	end
																	
																	local highlight = Roact.createElement(
																		RoundedBorderedFrame,
																		{
																			Size = UDim2.new(1, 0, 0, entryHeight),
																			Position = UDim2.new(0, 0, 0, entryHeight*(highlightIndex-1)),
																			BackgroundColor3 = highlightColor,
																			borderTransparency = 1,
																			ZIndex = 2
																		}
																	)
																	children.Highlight = highlight
																end
															end
																
															for entryIndex, entry in next, entries do
																local id, text = entry.id, entry.text
																local entryStyle = entry.entryStyle or "Default"
																local entryLabel = Roact.createElement(
																	"TextLabel",
																	{
																		BackgroundTransparency = 1,
																		Size = UDim2.new(1, -textPadding*2, 0, entryHeight),
																		Position = UDim2.new(0, textPadding, 0, entryHeight * (entryIndex-1)),
																		Font = font,
																		TextSize = fontSize,
																		TextColor3 = fieldTheme.dropdown.textColor[entryStyle],
																		TextXAlignment = Enum.TextXAlignment.Left,
																		Text = text,
																		TextTruncate = Enum.TextTruncate.AtEnd,
																		ZIndex = 3
																	}
																)
																children["__DROPDOWN_ENTRY_" .. tostring(id)] = entryLabel
															end
															
															children.inputDetector = Roact.createElement(
																"TextButton",
																{
																	Text = "",
																	Position = UDim2.new(0, 0, 0, 0),
																	Size = UDim2.new(1, 0, 0, dropdownHeight),
																	BackgroundTransparency = 1,
																	[Roact.Event.MouseMoved] = function(rbx, x, y)
																		local screenPos = rbx.AbsolutePosition
																		local fromCornerY = y-screenPos.Y
																		local idx = math.clamp(math.floor(fromCornerY/entryHeight)+1, 1, #entries)
																		local hoveredEntry = entries[idx]
																		if hoveredEntry and self.state.dropdownHighlightId ~= hoveredEntry.id then
																			self:setState(
																				{
																					dropdownHighlightId = hoveredEntry.id
																				}
																			)
																		end
																	end,
																	[Roact.Event.MouseButton1Down] = function(rbx, x, y)
																		local screenPos = rbx.AbsolutePosition
																		local fromCornerY = y-screenPos.Y
																		local idx = math.clamp(math.floor(fromCornerY/entryHeight)+1, 1, #entries)
																		local hoveredEntry = entries[idx]
																		if props.onSelected then
																			props.onSelected(hoveredEntry.id)
																		end
																		self:setState(
																			{
																				isOpen = false,
																				isHovered = false
																			}
																		)
																		if props.onClose then
																			props.onClose()
																		end
																		getModal(self).onDropdownClosed()
																	end
																}
															)
															
															return children
														end)()
													)
												}
											)
										end)
									}
								)
							}
						)
					}
				)
			}
		)
	end)
end

return ThemedDropdown