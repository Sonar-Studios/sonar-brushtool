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

local EraseSettingsSection = require(script.EraseSettingsSection)

local ErasePage = Roact.PureComponent:extend("ErasePage")

function ErasePage:init()
	self:setState(
		{
			eraseSettingsOpen = true,
		}
	)
end

function ErasePage:render()
	local Visible = self.props.Visible
	
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
							width = UDim.new(1, 0)
						},
						{
							ToggleButton = withBrushtool(function(brushtool)
								local mode = brushtool.mode
								
								return Roact.createElement(
									ThemedTextButtonWithIcon,
									{
										Size = UDim2.new(1, 0, 0, 80),
										Text = mode == "Erase" and "Deactivate Eraser" or "Activate Eraser",
										buttonStyle = "Default",
										TextSize = Constants.FONT_SIZE_LARGE,
										selected = mode == "Erase",
										onClick = function()
											if mode ~= "None" then
												brushtool:Deactivate()
											else
												brushtool:Activate("Erase")
											end
										end,
										icon = Constants.ERASE_IMAGE
									}
								)
							end),
							EraseSettingsBar = Roact.createElement(
								CollapsibleTitledSection,
								{
									title = "Erase Settings",
									collapsed = not self.state.eraseSettingsOpen,
									LayoutOrder = generateSequentialLayoutOrder(),
									onCollapseToggled = function()
										self:setState{eraseSettingsOpen = not self.state.eraseSettingsOpen}
									end
								},
								{
									EraseSettingsSection = Roact.createElement(
										EraseSettingsSection,
										{
											LayoutOrder = generateSequentialLayoutOrder(),
											Visible = self.state.eraseSettingsOpen
										},
										{}
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
	return {
		
	}
end

local function mapDispatchToProps(dispatch)
	return {
		
	}
end

ErasePage = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(ErasePage)

return ErasePage