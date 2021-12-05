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
local VerticalListSeparator = require(Foundation.VerticalListSeparator)
local AutoHeightThemedText = require(Foundation.AutoHeightThemedText)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)

local StampSettingsSection = require(script.StampSettingsSection)
local StampsSection = require(script.StampsSection)
local PlacementSettingsSection = require(script.PlacementSettingsSection)

local StampPage = Roact.PureComponent:extend("StampPage")

function StampPage:init()
	self:setState(
		{
			stampSettingsOpen = true,
			placementSettingsOpen = true,
			stampsOpen = true,
		}
	)
end

function StampPage:render()
	local props = self.props
	local Visible = props.Visible
	local currentlyStamping = props.currentlyStamping
	local areStampsAvailable = props.areStampsAvailable
	
	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end

	local brushtool = getBrushtool(self)
	
	local labelWidth = Constants.FIELD_LABEL_WIDTH
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
							width = UDim.new(1, 0),
						},
						{
							ToggleButton = withBrushtool(function(brushtool)
								local mode = brushtool.mode
								
								if currentlyStamping then
									return Roact.createElement(
										ThemedTextButtonWithIcon,
										{
											Size = UDim2.new(1, 0, 0, 80),
											Text = mode == "Stamp" and "Deactivate Stamp" or "Activate Stamp",
											buttonStyle = "Default",
											TextSize = Constants.FONT_SIZE_LARGE,
											selected = mode == "Stamp",
											onClick = function()
												if mode ~= "None" then
													brushtool:Deactivate()
												else
													brushtool:Activate("Stamp")
												end
											end,
											icon = Constants.STAMP_IMAGE
										}
									)
								else
									return withTheme(function(theme)
										return Roact.createElement(
											RoundedBorderedFrame,
											{
												Size = UDim2.new(1, 0, 0, 80),
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
														textStyle = "Warning",
														Text = currentlyStamping and "" or not areStampsAvailable and "No stamps available. Add one first!" or "You are not stamping anything. Click one of the stamps below!",
														PaddingLeftPixel = 4,
														PaddingRightPixel = 4,
														PaddingTopPixel = 4,
														PaddingBottomPixel = 4
													}
												)
											}
										)
									end)
								end
							end),
							StampSettingsBar = Roact.createElement(
								CollapsibleTitledSection,
								{
									title = "Stamp Settings",
									collapsed = not self.state.stampSettingsOpen,
									LayoutOrder = generateSequentialLayoutOrder(),
									onCollapseToggled = function()
										self:setState{stampSettingsOpen = not self.state.stampSettingsOpen}
									end
								},
								{
									StampSettingsSection = Roact.createElement(
										StampSettingsSection,
										{
											LayoutOrder = generateSequentialLayoutOrder(),
											Visible = self.state.stampSettingsOpen
										},
										{}
									),	
								}
							),
							StampsBar = Roact.createElement(
								CollapsibleTitledSection,
								{
									title = "Stamps",
									collapsed = not self.state.stampsOpen,
									LayoutOrder = generateSequentialLayoutOrder(),
									onCollapseToggled = function()
										self:setState{stampsOpen = not self.state.stampsOpen}
									end,
									BorderTop = self.state.stampSettingsOpen
								},
								{
									StampsSection = Roact.createElement(
										StampsSection,
										{
											LayoutOrder = generateSequentialLayoutOrder(),
											Visible = self.state.stampsOpen
										}
									),
								}
							),
							PlacementSettingsBar = currentlyStamping and Roact.createElement(
								CollapsibleTitledSection,
								{
									title = "Placement Settings for " .. props.stampingName,
									collapsed = not self.state.placementSettingsOpen,
									LayoutOrder = generateSequentialLayoutOrder(),
									onCollapseToggled = function()
										self:setState{placementSettingsOpen = not self.state.placementSettingsOpen}
									end,
									BorderTop = self.state.stampsOpen
								},
								{
									PlacementSettingsSection = currentlyStamping and Roact.createElement(
										PlacementSettingsSection,
										{
											LayoutOrder = generateSequentialLayoutOrder(),
											Visible = self.state.placementSettingsOpen
										},
										{}
									),
								}
							)
						}
					)
				}
			)
		}
	)
end


local function mapStateToProps(state)
	local currentlyStamping = state.stamp.currentlyStamping
	local stampObjects = state.stampObjects
	local object = stampObjects[currentlyStamping]
	local areStampsAvailable = next(stampObjects) ~= nil
	return {
		currentlyStamping = object ~= nil,
		stampingName = object and object.name,
		areStampsAvailable = areStampsAvailable
	}
end

local function mapDispatchToProps(dispatch)
	return {
		
	}
end

StampPage = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(StampPage)

return StampPage