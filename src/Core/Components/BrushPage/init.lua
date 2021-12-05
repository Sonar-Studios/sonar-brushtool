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

local BrushSettingsSection = require(script.BrushSettingsSection)
local BrushesSection = require(script.BrushesSection)
local PlacementSettingsSection = require(script.PlacementSettingsSection)

local BrushPage = Roact.PureComponent:extend("BrushPage")

function BrushPage:init()
	self:setState(
		{
			brushSettingsOpen = true,
			placementSettingsOpen = true,
			brushesOpen = true,
		}
	)
end

function BrushPage:render()
	local props = self.props
	local Visible = props.Visible
	local brushableCount = props.brushableCount
	local enabledCount = props.enabledCount
	
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
								
								if enabledCount > 0 then
									return Roact.createElement(
										ThemedTextButtonWithIcon,
										{
											Size = UDim2.new(1, 0, 0, 80),
											Text = mode == "Brush" and "Deactivate Brush" or "Activate Brush",
											buttonStyle = "Default",
											TextSize = Constants.FONT_SIZE_LARGE,
											selected = mode == "Brush",
											onClick = function()
												if mode ~= "None" then
													brushtool:Deactivate()
												else
													brushtool:Activate("Brush")
												end
											end,
											icon = Constants.BRUSH_IMAGE
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
														Text = enabledCount > 0 and "" or brushableCount == 0 and "No brushes available. Add one first!" or "No brushes are enabled. Click one or more of the brushes below!",
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
							BrushSettingsBar = Roact.createElement(
								CollapsibleTitledSection,
								{
									title = "Brush Settings",
									collapsed = not self.state.brushSettingsOpen,
									LayoutOrder = generateSequentialLayoutOrder(),
									onCollapseToggled = function()
										self:setState{brushSettingsOpen = not self.state.brushSettingsOpen}
									end
								},
								{
									BrushSettingsSection = Roact.createElement(
										BrushSettingsSection,
										{
											LayoutOrder = generateSequentialLayoutOrder(),
											Visible = self.state.brushSettingsOpen
										},
										{}
									),
								}
							),
							PlacementSettingsBar = Roact.createElement(
								CollapsibleTitledSection,
								{
									title = "General Placement Settings",
									collapsed = not self.state.placementSettingsOpen,
									LayoutOrder = generateSequentialLayoutOrder(),
									onCollapseToggled = function()
										self:setState{placementSettingsOpen = not self.state.placementSettingsOpen}
									end
								},
								{
									PlacementSettingsSection = Roact.createElement(
										PlacementSettingsSection,
										{
											LayoutOrder = generateSequentialLayoutOrder(),
											Visible = self.state.placementSettingsOpen
										},
										{}
									),
								}
							),
							BrushesBar = Roact.createElement(
								CollapsibleTitledSection,
								{
									title = "Brushes",
									collapsed = not self.state.brushesOpen,
									LayoutOrder = generateSequentialLayoutOrder(),
									onCollapseToggled = function()
										self:setState{brushesOpen = not self.state.brushesOpen}
									end,
									BorderTop = self.state.placementSettingsOpen
								},
								{
									BrushesSection = Roact.createElement(
										BrushesSection,
										{
											LayoutOrder = generateSequentialLayoutOrder(),
											Visible = self.state.brushesOpen
										}
									)	
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
	local brushableCount = 0
	local enabledCount = 0
	for guid, object in next, state.brushObjects do
		brushableCount = brushableCount+1
		if object.brushEnabled then
			enabledCount = enabledCount+1
		end
	end
	
	return {
		brushableCount = brushableCount,
		enabledCount = enabledCount
	}
end

local function mapDispatchToProps(dispatch)
	return {
		
	}
end

BrushPage = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BrushPage)

return BrushPage