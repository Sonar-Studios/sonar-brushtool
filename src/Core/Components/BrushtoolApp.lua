--[[
	The brushtool itself

	Props (many of these come from the store):
		number initialWidth = 0
		number initialSelectedBackgroundIndex = 1
		number initialSelectedCategoryIndex = 1
		string initialSearchTerm = ""
		number initialSelectedSortIndex = 1

		Backgrounds backgrounds
		Categories categories
		Suggestions suggestions
		Sorts sorts

		callback loadManageableGroups()
		callback updatePageInfo()
]]

local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local TabbedMenu = require(Foundation.TabbedMenu)
local BrushPage = require(Components.BrushPage)
local StampPage = require(Components.StampPage)
local ErasePage = require(Components.ErasePage)
local MiscPage = require(Components.MiscPage)
local HelpPage = require(Components.HelpPage)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local BrushCursor = require(Components.BrushCursor)
local EraseCursor = require(Components.EraseCursor)
local StampCursor = require(Components.StampCursor)
local AutoHeightThemedText = require(Foundation.AutoHeightThemedText)
local VerticalList = require(Foundation.VerticalList)
local VerticalListSeparator = require(Foundation.VerticalListSeparator)
local ThemedCheckbox = require(Foundation.ThemedCheckbox)

local withTheme = ContextHelper.withTheme
local withBrushtool = ContextHelper.withBrushtool
local getBrushtool = ContextGetter.getBrushtool

local Brushtool = Roact.PureComponent:extend("Brushtool")

function Brushtool:init(props)
	self.state = {
		brushtoolWidth = math.max(props.initialWidth or 0, Constants.BRUSHTOOL_MIN_WIDTH),
	}

	self.brushtoolRef = Roact.createRef()

	self.onAbsoluteSizeChange = function()
		local brushtoolWidth = math.max(self.brushtoolRef.current.AbsoluteSize.x,
			Constants.BRUSHTOOL_MIN_WIDTH)
		if self.state.brushtoolWidth ~= brushtoolWidth then
			self:setState({
				brushtoolWidth = brushtoolWidth,
			})
		end
	end or function(rbx)
		local brushtoolWidth = math.max(rbx.AbsoluteSize.x, Constants.BRUSHTOOL_MIN_WIDTH)
		if self.state.brushtoolWidth ~= brushtoolWidth then
			self:setState({
				brushtoolWidth = brushtoolWidth,
			})
		end
	end
	
	self:setState({
		currentTab = "Brush",
		resetChecked = false
	})
end

function Brushtool:didMount()
	if self.brushtoolRef.current then
		self.brushtoolRef.current:GetPropertyChangedSignal("AbsoluteSize"):connect(self.onAbsoluteSizeChange)
	end
end

function Brushtool:render()
	local props = self.props
	
	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end
	
	local brushtool = getBrushtool(self)
	if not brushtool:IsInEditMode() then
		return withTheme(function(theme)
			local appTheme = theme.app
			local brushtool = getBrushtool(self)
			
			return Roact.createElement(
				"Frame", 
				{
					BackgroundColor3 = appTheme.backgroundColor,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
				},
				{
					List = Roact.createElement(
						VerticalList,
						{
							width = UDim.new(1, 0),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
						},
						{
							BrushIcon = Roact.createElement(
								"ImageLabel",
								{
									Image = Constants.MAIN_ICON,
									Size = UDim2.new(0, 150, 0, 150),
									BackgroundTransparency = 1,
									ImageColor3 = appTheme.textColor,
									LayoutOrder = generateSequentialLayoutOrder()
								},
								{
									NoIcon = Roact.createElement(
										"ImageLabel",
										{
											Image = Constants.NO_IMAGE,
											Size = UDim2.new(0, 150, 0, 150),
											BackgroundTransparency = 1,
											ImageColor3 = appTheme.noColor,
										}
									)
								}
							),
							Sep1 = Roact.createElement(
								VerticalListSeparator,
								{
									height = 16,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							TitleText = Roact.createElement(
								AutoHeightThemedText,
								{
									BackgroundTransparency = 1,
									Text = "Brushtool only runs in edit mode :'(",
									width = UDim.new(1, -32),
									Font = Constants.FONT_BOLD,
									TextSize = 32,
									TextYAlignment = Enum.TextYAlignment.Top,
									TextColor3 = appTheme.textColor,
									TextWrapped = true,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
						}
					)
				}
			)
		end)
	elseif not props.started then
		return withTheme(function(theme)
			local appTheme = theme.app
			local brushtool = getBrushtool(self)
			
			
			return Roact.createElement(
				"Frame", 
				{
					BackgroundColor3 = appTheme.backgroundColor,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0),
				},
				{
					List = Roact.createElement(
						VerticalList,
						{
							width = UDim.new(1, 0),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
						},
						{
							BrushIcon = Roact.createElement(
								"ImageLabel",
								{
									Image = Constants.MAIN_ICON,
									Size = UDim2.new(0, 150, 0, 150),
									BackgroundTransparency = 1,
									ImageColor3 = appTheme.textColor,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							Sep1 = Roact.createElement(
								VerticalListSeparator,
								{
									height = 16,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							TitleText = Roact.createElement(
								"TextLabel",
								{
									BackgroundTransparency = 1,
									Text = "Welcome to Brushtool!",
									Size = UDim2.new(1, 0, 0, 32),
									Font = Constants.FONT_BOLD,
									TextSize = 32,
									TextYAlignment = Enum.TextYAlignment.Top,
									TextColor3 = appTheme.textColor,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							Sep2 = Roact.createElement(
								VerticalListSeparator,
								{
									height = 16,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							StartButton = Roact.createElement(
								ThemedTextButton,
								{
									onClick = function()
										if self.state.resetChecked then
											brushtool:clearStoredSettings()
										end 
										brushtool:start()
									end,
									Size = UDim2.new(0, 200, 0, 48),
									Text = "Click to Start",
									Font = Constants.FONT_BOLD,
									TextSize = 24,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							Sep3 = Roact.createElement(
								VerticalListSeparator,
								{
									height = 8,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							ResetField = Roact.createElement(
								"Frame",
								{
									Size = UDim2.new(1, -32, 0, 18),
									LayoutOrder = generateSequentialLayoutOrder(),
									BackgroundTransparency = 1
								},
								{
									Checkbox = Roact.createElement(
										ThemedCheckbox,
										{
											checked = self.state.resetChecked,
											onToggle = function()
												self:setState({
													resetChecked = not self.state.resetChecked
												})
											end,
											LayoutOrder = 1
										}
									),
									Text = Roact.createElement(
										AutoHeightThemedText,
										{
											width = UDim.new(0, 120),
											TextSize = 18,
											Text = "Reset Settings?",
											Font = Constants.FONT_BOLD,
											LayoutOrder = 2
										}
									),
									HList = Roact.createElement(
										"UIListLayout",
										{
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											FillDirection = Enum.FillDirection.Horizontal
										}
									)
								}
							),
							Sep5 = Roact.createElement(
								VerticalListSeparator,
								{
									height = 32,
									LayoutOrder = generateSequentialLayoutOrder()
								}
							),
							Alert = (function()
								if Constants.PLUGIN_THIS_IS_BETA_CHANNEL then
									return Roact.createElement(
										AutoHeightThemedText,
										{
											BackgroundTransparency = 1,
											Text =  "You are using the beta channel of this plugin. This is updated spontaneously and may be unstable. Get the release verison at www.roblox.com/library/" .. tostring(Constants.PLUGIN_PRODUCT_ID) .. "/Brushtool",
											AnchorPoint = Vector2.new(0.5, 0.5),
											width = UDim.new(1, -32),
											Font = Constants.FONT_BOLD,
											TextSize = 16,
											TextYAlignment = Enum.TextYAlignment.Top,
											TextColor3 = theme.positiveTextColor,
											textStyle = "Warning",
											LayoutOrder = generateSequentialLayoutOrder()
										}
									)								
								else
									return Roact.createElement(
										AutoHeightThemedText,
										{
											BackgroundTransparency = 1,
											Text =  brushtool:IsUpdateAvailable() and "An update is available!\nGo to Plugins -> Manage Plugins and update the plugin!" or
												"The plugin is up to date!",
											AnchorPoint = Vector2.new(0.5, 0.5),
											width = UDim.new(1, -32),
											Font = Constants.FONT_BOLD,
											TextSize = 16,
											TextYAlignment = Enum.TextYAlignment.Top,
											TextColor3 = theme.positiveTextColor,
											textStyle = brushtool:IsUpdateAvailable() and "Warning" or "Positive",
											LayoutOrder = generateSequentialLayoutOrder()
										}
									)
								end
							end)()
						}
					)
				}
			)
		end)
	else
		return withTheme(function(theme)
			return withBrushtool(function(brushtool)
				local props = self.props
				local state = self.state
				
				local appTheme = theme.app
				local brushtoolWidth = state.brushtoolWidth
		
				local saveOverlay = nil
				if brushtool:MustSave() then
					saveOverlay = {
						Save = Roact.createElement(
							"ImageLabel",
							{
								BackgroundTransparency = 1,
								Image = Constants.SAVE_IMAGE,
								ImageColor3 = theme.saveButtonColor,
								BorderSizePixel = 0,
								Size = UDim2.new(0, 16, 0, 16),
								Position = UDim2.new(0, 8, 0, 24)
							}
						)
					}
				end
		
				local app = Roact.createElement(
					"Frame", 
					{
						BackgroundColor3 = appTheme.backgroundColor,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 1, 0),
					}, 
					{
						Tabber = Roact.createElement(
							TabbedMenu,
							{
								tabs = {
									{ id = "Brush", text = "Brush", image = Constants.BRUSH_IMAGE },
									{ id = "Stamp", text = "Stamp", image = Constants.STAMP_IMAGE },
									{ id = "Erase", text = "Erase", image = Constants.ERASE_IMAGE },
									{ id = "Misc", text = "Misc", image = Constants.MISC_IMAGE, overlay = saveOverlay},
--									{ id = "Help", text = "Help", image = Constants.HELP_IMAGE }
								},
								activeId = self.state.currentTab,
								onTabClick = function(tabId)
									if self.state.currentTab ~= tabId then
										self:setState{currentTab = tabId}
										getBrushtool(self):Deactivate()
									end
								end
							},
							{
								BrushPage = self.state.currentTab == "Brush" and Roact.createElement(
									BrushPage
								),
								StampPage = self.state.currentTab == "Stamp" and Roact.createElement(
									StampPage
								),
								ErasePage = self.state.currentTab == "Erase" and Roact.createElement(
									ErasePage
								),
								MiscPage = self.state.currentTab == "Misc" and Roact.createElement(
									MiscPage
								),
--								HelpPage = self.state.currentTab == "Help" and Roact.createElement(
--									HelpPage
--								),
							}
						),
						BrushCursor = Roact.createElement(
							BrushCursor
						),
						EraseCursor = Roact.createElement(
							EraseCursor
						),
						StampCursor = Roact.createElement(
							StampCursor
						)
					}
				)
				
				return app
			end)
		end)
	end
end

local function mapStateToProps(state, props)
	return {
		started = state.stateCopied
	}
end

local function mapDispatchToProps(dispatch)
	return {

	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(Brushtool)
