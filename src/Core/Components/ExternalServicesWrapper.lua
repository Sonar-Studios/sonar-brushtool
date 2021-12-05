local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)

local ModalProvider = require(Plugin.Core.Providers.ModalProvider)
local PluginProvider = require(Plugin.Core.Providers.PluginProvider)
local ThemeProvider = require(Plugin.Core.Providers.ThemeProvider)
local BrushtoolProvider = require(Plugin.Core.Providers.BrushtoolProvider)

local ExternalServicesWrapper = Roact.PureComponent:extend("ExternalServicesWrapper")

function ExternalServicesWrapper:shouldUpdate()
	return false
end

function ExternalServicesWrapper:render()
	local props = self.props
	local store = props.store
	local plugin = props.plugin
	local pluginGui = props.pluginGui
	local brushtool = props.brushtool
	local theme = props.theme

	return Roact.createElement(
		RoactRodux.StoreProvider, 
		{
			store = store
		}, 
		{
			Roact.createElement(
				PluginProvider, 
				{
					plugin = plugin,
					pluginGui = pluginGui,
				}, 
				{
					Roact.createElement(
						ThemeProvider, 
						{
							theme = theme,
						}, 
						{
							Roact.createElement(
								BrushtoolProvider, 
								{
									brushtool = brushtool
								}, 
								{
									Roact.createElement(
										ModalProvider, 
										{}, 
										props[Roact.Children]
									)
								}
							),
						}
					),
				}
			),
		}
	)
end

return ExternalServicesWrapper
