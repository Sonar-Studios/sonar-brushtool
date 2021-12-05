local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Funcs = require(Plugin.Core.Util.Funcs)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local withBrushtool = ContextHelper.withBrushtool
local getPlugin = ContextGetter.getPlugin
local getModal = ContextGetter.getModal
local getBrushtool = ContextGetter.getBrushtool

local Actions = Plugin.Core.Actions
local SetStampedParent = require(Actions.SetStampedParent)
local SetBrushedParent = require(Actions.SetBrushedParent)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local ScrollingVerticalList = require(Foundation.ScrollingVerticalList)
local TextField = require(Foundation.TextField)
local DropdownField = require(Foundation.DropdownField)
local CheckboxField = require(Foundation.CheckboxField)
local CollapsibleTitledSection = require(Foundation.CollapsibleTitledSection)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local ThemedTextButtonWithIcon = require(Foundation.ThemedTextButtonWithIcon)
local VerticalList = require(Foundation.VerticalList)
local RoundedBorderedVerticalList = require(Foundation.RoundedBorderedVerticalList)
local VerticalListSeparator = require(Foundation.VerticalListSeparator)
local AutoHeightThemedText = require(Foundation.AutoHeightThemedText)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)

local MiscPage = Roact.PureComponent:extend("MiscPage")

function MiscPage:init()
	self:setState(
		{
			saveSettingsOpen = true,
			setBrushedParentOpen = true,
			setStampedParentOpen = true,
			clearTagsOpen = true,
			flip = false
		}
	)
	
	self.timeSinceLastUpdate = 0
end

--function wrapTick(tickTime, render)
--	local tickComponent = Roact.PureComponent:extend("tick")
--	
--	function tickComponent:init()
--		self:setState{
--			flip = false
--		}
--		
--		self.timeSinceLastUpdate = 0
--	end
--	
--	function tickComponent:render()
--		return self.props.render()
--	end
--	
--	function tickComponent:didMount()
--		self.hConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
--			self.timeSinceLastUpdate = self.timeSinceLastUpdate-dt
--			if self.timeSinceLastUpdate < 0 then
--				self.timeSinceLastUpdate = self.timeSinceLastUpdate+tickTime
--				self:setState{
--					flip = not self.state.flip
--				}
--			end
--		end)
--	end
--	
--	function tickComponent:willUnmount()
--		self.hConn:Disconnect()
--	end
--	
--	return Roact.createElement(
--		tickComponent,
--		{
--			render = render
--		}
--	)
--end

function MiscPage:render()
	local Visible = self.props.Visible
	
	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end

	local labelWidth = Constants.FIELD_LABEL_WIDTH
	return withTheme(function(theme)
		return withBrushtool(function(brushtool)
			local props = self.props
			local brushedParent = props.brushedParent
			local stampedParent = props.stampedParent
			local selection = brushtool.selection
			local selectionCount = #selection
			local brushWarningText = "Select one object in workspace."
			local stampWarningText = "Select one object in workspace."
			local brushButtonText = "Set brushed parent to..."
			local stampButtonText = "Set stamped parent to..."
			local brushSetEnabled = false
			local stampSetEnabled = false
			local brushWarningType = "Default"
			local stampWarningType = "Default"
			if selectionCount > 1 then
				brushWarningText = "Must only select one object."
				stampWarningText = "Must only select one object."
				brushWarningType = "Warning"
				stampWarningType = "Warning"
			elseif selectionCount == 1 then
				local target = selection[1]
				if target ~= workspace and not target:IsDescendantOf(workspace) then
					brushWarningText = "Object must be workspace or one of its descendants."
					stampWarningText = "Object must be workspace or one of its descendants."
					brushWarningType = "Warning"
					stampWarningType = "Warning"
				else
					if target == brushedParent then
						brushWarningText = string.format("Already set to %s", target:GetFullName())
						brushWarningType = "Positive"
					else
						brushWarningText = ""
						brushButtonText = ("Set brushed parent to %s"):format(target.Name)
						brushSetEnabled = true
					end
					
					if target == stampedParent then
						stampWarningText = string.format("Already set to %s", target:GetFullName())
						stampWarningType = "Positive"
					else
						stampWarningText = ""
						stampButtonText = ("Set stamped parent to %s"):format(target.Name)
						stampSetEnabled = true
					end
				end
			end
			
			local tagButtonEnabled = true
			if #brushtool:GetBrushedObjects() == 0 then
				tagButtonEnabled = false
			end
			
			return Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, -1, 1, -1),
					Position = UDim2.new(0, 1, 0, 0),
					BackgroundTransparency = 1,
					Visible = Visible
				},
				{
					List = Roact.createElement(
						ScrollingVerticalList,
						{},
						{
							Padder = Roact.createElement(
								VerticalList,
								{
									PaddingTopPixel = 4,
									PaddingBottomPixel = 4,
									PaddingLeftPixel = 4,
									PaddingRightPixel = 4,
									ElementPaddingPixel = 4,
									width = UDim.new(1, 0)
								},
								{
									SaveSettings = Roact.createElement(
										CollapsibleTitledSection,
										{
											title = "Save Settings",
											collapsed = not self.state.saveSettingsOpen,
											LayoutOrder = generateSequentialLayoutOrder(),
											onCollapseToggled = function()
												self:setState{saveSettingsOpen = not self.state.saveSettingsOpen}
											end
										},
										{
											List = Roact.createElement(
												VerticalList,
												{
													width = UDim.new(1, 0),
													PaddingLeftPixel = 4,
													PaddingRightPixel = 4,
													PaddingTopPixel = 4,
													PaddingBottomPixel = 4,
													ElementPaddingPixel = 4,
													Visible = self.state.saveSettingsOpen
												},
												{
													Indent = Roact.createElement(
														VerticalList,
														{
															width = UDim.new(1, 0),
															PaddingLeftPixel = 8
														},
														{
															Body1 = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = "Click the button below to save your settings. " ..
																		"The settings for this plugin are embedded in your place file in a folder under the Geometry Service. ",
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															),
															Body2 = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = "It's a good idea to save before publishing or saving the place, otherwise your settings may be lost!",
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															),
															SaveTimer = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = brushtool:MustSave() == false and ("Your settings are autosaved every %d seconds."):format(Constants.AUTOSAVE_INTERVAL)
																			or ("Your settings are autosaved every %d seconds. Autosaving in %d seconds."):format(Constants.AUTOSAVE_INTERVAL, math.ceil(brushtool:TimeToAutosave())),
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															),
														}
													),
													Button = brushtool:MustSave() and Roact.createElement(
														ThemedTextButton,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															Text = "Save Settings",
															buttonStyle = "Default",
															LayoutOrder = generateSequentialLayoutOrder(),
															onClick = function() brushtool:Save() end,
															TextSize = Constants.FONT_SIZE_MEDIUM
														}
													),
													Warn = not brushtool:MustSave() and Roact.createElement(
														RoundedBorderedFrame,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															BorderColor3 = theme.borderColor,
															BackgroundColor3 = theme.mainBackgroundColor,
														},
														{
															Text = Roact.createElement(
																AutoHeightThemedText,
																{
																	width = UDim.new(1, 0),
																	Position = UDim2.new(0.5, 0, 0.5, 0),
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	Font = Constants.FONT,
																	TextSize = Constants.FONT_SIZE_SMALL,
																	BackgroundTransparency = 1,
																	textStyle = "Positive",
																	Text = "Already up to date!"
																}
															)
														}
													)
												}
											)
										}
									),
									
									SetBrushedParent = Roact.createElement(
										CollapsibleTitledSection,
										{
											title = "Set Brushed Parent",
											collapsed = not self.state.setBrushedParentOpen,
											LayoutOrder = generateSequentialLayoutOrder(),
											onCollapseToggled = function()
												self:setState{setBrushedParentOpen = not self.state.setBrushedParentOpen}
											end
										},
										{
											List = Roact.createElement(
												VerticalList,
												{
													width = UDim.new(1, 0),
													PaddingLeftPixel = 4,
													PaddingRightPixel = 4,
													PaddingTopPixel = 4,
													PaddingBottomPixel = 4,
													ElementPaddingPixel = 4,
													Visible = self.state.setBrushedParentOpen
												},
												{
													Indent = Roact.createElement(
														VerticalList,
														{
															width = UDim.new(1, 0),
															PaddingLeftPixel = 8
														},
														{
															Body1 = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = "Things you brush will be parented to whatever this is set to. Deleting or moving " ..
																		"this will reset this to workspace.",
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															),
															Body2 = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = string.format("Currently set to %s", brushedParent:GetFullName()),
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															),
														}
													),
													Button = brushSetEnabled and Roact.createElement(
														ThemedTextButton,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															Text = brushButtonText,
															buttonStyle = "Default",
															LayoutOrder = generateSequentialLayoutOrder(),
															onClick = function() props.setBrushedParent(selection[1]) end,
															TextSize = Constants.FONT_SIZE_MEDIUM
														}
													),
													Warn = not brushSetEnabled and Roact.createElement(
														RoundedBorderedFrame,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															BorderColor3 = theme.borderColor,
															BackgroundColor3 = theme.mainBackgroundColor,
														},
														{
															Text = Roact.createElement(
																AutoHeightThemedText,
																{
																	width = UDim.new(1, 0),
																	Position = UDim2.new(0.5, 0, 0.5, 0),
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	Font = Constants.FONT,
																	TextSize = Constants.FONT_SIZE_SMALL,
																	BackgroundTransparency = 1,
																	textStyle = brushWarningType,
																	Text = brushWarningText
																}
															)
														}
													)
												}
											)
										}
									),
									
									SetStampedParent = Roact.createElement(
										CollapsibleTitledSection,
										{
											title = "Set Stamped Parent",
											collapsed = not self.state.setStampedParentOpen,
											LayoutOrder = generateSequentialLayoutOrder(),
											onCollapseToggled = function()
												self:setState{setStampedParentOpen = not self.state.setStampedParentOpen}
											end
										},
										{
											List = Roact.createElement(
												VerticalList,
												{
													width = UDim.new(1, 0),
													PaddingLeftPixel = 4,
													PaddingRightPixel = 4,
													PaddingTopPixel = 4,
													PaddingBottomPixel = 4,
													ElementPaddingPixel = 4,
													Visible = self.state.setStampedParentOpen
												},
												{
													Indent = Roact.createElement(
														VerticalList,
														{
															width = UDim.new(1, 0),
															PaddingLeftPixel = 8
														},
														{
															Body1 = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = "Things you stamp will be parented to whatever this is set to. Deleting or moving " ..
																		"this will reset this to workspace.",
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															),
															Body2 = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = string.format("Currently set to %s", stampedParent:GetFullName()),
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															),
														}
													),
													Button = stampSetEnabled and Roact.createElement(
														ThemedTextButton,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															Text = stampButtonText,
															buttonStyle = "Default",
															LayoutOrder = generateSequentialLayoutOrder(),
															disabled = not stampSetEnabled,
															onClick = stampSetEnabled and function() props.setStampedParent(selection[1]) end,
															TextSize = Constants.FONT_SIZE_MEDIUM
														}
													),
													Warn = not stampSetEnabled and Roact.createElement(
														RoundedBorderedFrame,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															BorderColor3 = theme.borderColor,
															BackgroundColor3 = theme.mainBackgroundColor,
														},
														{
															Text = Roact.createElement(
																AutoHeightThemedText,
																{
																	width = UDim.new(1, 0),
																	Position = UDim2.new(0.5, 0, 0.5, 0),
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	Font = Constants.FONT,
																	TextSize = Constants.FONT_SIZE_SMALL,
																	BackgroundTransparency = 1,
																	textStyle = stampWarningType,
																	Text = stampWarningText
																}
															)
														}
													)
												}
											)
										}
									),
									
									ClearColletionServiceTags = Roact.createElement(
										CollapsibleTitledSection,
										{
											title = "Clear CollectionService Tags",
											collapsed = not self.state.clearTagsOpen,
											LayoutOrder = generateSequentialLayoutOrder(),
											onCollapseToggled = function()
												self:setState{clearTagsOpen = not self.state.clearTagsOpen}
											end
										},
										{
											List = Roact.createElement(
												VerticalList,
												{
													width = UDim.new(1, 0),
													PaddingLeftPixel = 4,
													PaddingRightPixel = 4,
													PaddingTopPixel = 4,
													PaddingBottomPixel = 4,
													ElementPaddingPixel = 4,
													Visible = self.state.clearTagsOpen
												},
												{
													Indent = Roact.createElement(
														VerticalList,
														{
															width = UDim.new(1, 0),
															PaddingLeftPixel = 8
														},
														{
															Body1 = Roact.createElement(
																AutoHeightThemedText,
																{
																	Text = "This plugin tags brushed/stamped objects so that you won't stack objects on top of each other. Unless your game iterates " ..
																		"over the results of CollectionService:GetTags(), it is recommended that you leave these tags alone.",
																	TextXAlignment = Enum.TextXAlignment.Left,
																	width = UDim.new(1, 0),
																	PaddingBottomPixel = 5,
																	LayoutOrder = generateSequentialLayoutOrder()
																}
															)
														}
													),
													Button = tagButtonEnabled and Roact.createElement(
														ThemedTextButton,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															Text = "Clear all tags",
															buttonStyle = "Default",
															LayoutOrder = generateSequentialLayoutOrder(),
															TextSize = Constants.FONT_SIZE_MEDIUM,
															onClick = function()
																brushtool:ClearTags()
															end
														}
													),
													Warn = not tagButtonEnabled and Roact.createElement(
														RoundedBorderedFrame,
														{
															Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
															BorderColor3 = theme.borderColor,
															BackgroundColor3 = theme.mainBackgroundColor,
														},
														{
															Text = Roact.createElement(
																AutoHeightThemedText,
																{
																	width = UDim.new(1, 0),
																	Position = UDim2.new(0.5, 0, 0.5, 0),
																	AnchorPoint = Vector2.new(0.5, 0.5),
																	Font = Constants.FONT,
																	TextSize = Constants.FONT_SIZE_SMALL,
																	BackgroundTransparency = 1,
																	textStyle = "Default",
																	Text = "Already cleared."
																}
															)
														}
													)
												}
											)
										}
									),
								}
							)
						}
					)
				}
			)
		end)
	end)
end

function MiscPage:didMount()
	self.hConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
		self.timeSinceLastUpdate = self.timeSinceLastUpdate-dt
		if self.timeSinceLastUpdate < 0 then
			self.timeSinceLastUpdate = self.timeSinceLastUpdate+1
			self:setState{
				flip = not self.state.flip
			}
		end
	end)
end

function MiscPage:willUnmount()
	self.hConn:Disconnect()
end

local function mapStateToProps(state)
	local stamp = state.stamp
	local brush = state.brush
	return {
		stampedParent = stamp.stampedParent,
		brushedParent = brush.brushedParent
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setStampedParent = function(stampedParent) dispatch(SetStampedParent(stampedParent)) end,
		setBrushedParent = function(brushedParent) dispatch(SetBrushedParent(brushedParent)) end
	}
end

MiscPage = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(MiscPage)

return MiscPage