local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local ExternalServicesWrapper = require(Plugin.Core.Components.ExternalServicesWrapper)
local DockWidget = require(Foundation.DockWidget)
local BrushtoolApp = require(Components.BrushtoolApp)

local BrushtoolPlugin = Roact.PureComponent:extend("BrushtoolPlugin")

function BrushtoolPlugin:init(props)
	self.plugin = props.plugin
	if not self.plugin then
		error("BrushtoolPlugin component requires plugin to be passed as prop")
	end

	self.state = {
		enabled = true,

		-- Put the plugin gui in the state so that once its loaded, we
		-- trigger a rerender
		pluginGui = nil,

		brushtoolTitle = "Brushtool",
	}

	if Constants.PLUGIN_THIS_IS_BETA_CHANNEL then
		self.toolbar = self.plugin:CreateToolbar("Brushtool [BETA CHANNEL]")
	else
		self.toolbar = self.plugin:CreateToolbar("Brushtool [SONAR CHANNEL]")
	end
	self.brushtoolButton = self.toolbar:CreateButton("Brushtool",
		"Insert items from the brushtool", Constants.TOOLBAR_ICON)

	self.brushtoolButton:SetActive(self.state.enabled)

	self.brushtoolButton.Click:connect(function()
		self:setState(function(state)
			return {
				enabled = not state.enabled,
			}
		end)
	end)

	self.onDockWidgetEnabledChanged = function(rbx)
		if self.state.enabled == rbx.Enabled then
			return
		end

		self:setState({
			enabled = rbx.Enabled,
		})
	end

	self.onAncestryChanged = function(rbx, child, parent)
		if not parent and self.props.onPluginWillDestroy then
			self.props.onPluginWillDestroy()
		end
	end

	self.dockWidgetRefFunc = function(ref)
		self.dockWidget = ref
	end
end

function BrushtoolPlugin:didMount()
	self.onDockWidgetEnabledChanged(self.dockWidget)

	-- Now we have the dock widget, trigger a rerender
	self:setState({
		pluginGui = self.dockWidget,
	})
end

function BrushtoolPlugin:willUnmount()

end

function BrushtoolPlugin:didUpdate()
	self.brushtoolButton:SetActive(self.state.enabled)
end

function BrushtoolPlugin:render()
	local enabled = self.state.enabled

	local store = self.props.store
	local plugin = self.props.plugin
	local pluginGui = self.state.pluginGui
	local theme = self.props.theme
	local brushtool = self.props.brushtool

	local initialWidth = pluginGui and pluginGui.AbsoluteSize.x or Constants.BRUSHTOOL_MIN_WIDTH

	local pluginGuiLoaded = pluginGui ~= nil

	local brushtoolTitle = self.state.brushtoolTitle

	return Roact.createElement(DockWidget, {
		plugin = plugin,

		Title = brushtoolTitle,
		Name = Constants.PLUGIN_THIS_IS_BETA_CHANNEL and "Brushtool [BETA CHANNEL]" or "Brushtool",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		InitialDockState = Enum.InitialDockState.Left,
		InitialEnabled = true,
		InitialEnabledShouldOverrideRestore = false,
		FloatingXSize = 0,
		FloatingYSize = 0,
		MinWidth = Constants.BRUSHTOOL_MIN_WIDTH,
		MinHeight = Constants.BRUSHTOOL_MIN_HEIGHT,

		Enabled = enabled,

		[Roact.Ref] = self.dockWidgetRefFunc,
		[Roact.Change.Enabled] = self.onDockWidgetEnabledChanged,
		[Roact.Event.AncestryChanged] = self.onAncestryChanged,
	}, {
		Brushtool = pluginGuiLoaded and Roact.createElement(ExternalServicesWrapper, {
			store = store,
			plugin = plugin,
			pluginGui = pluginGui,
			theme = theme,
			brushtool = brushtool
		}, {
			Roact.createElement(BrushtoolApp, {
				initialWidth = initialWidth
			})
		})
	})
end

return BrushtoolPlugin
