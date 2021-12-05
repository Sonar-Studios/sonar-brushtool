local Plugin = script.Parent.Parent
local Libs = Plugin.Libs
local Cryo = require(Libs.Cryo)
local Roact = require(Libs.Roact)
local Rodux = require(Libs.Rodux)

local Constants = require(Plugin.Core.Util.Constants)
local BrushtoolTheme = require(Plugin.Core.Util.BrushtoolTheme)

local ExternalServicesWrapper = require(Plugin.Core.Components.ExternalServicesWrapper)
local BrushtoolPlugin = require(Plugin.Core.Components.BrushtoolPlugin)

local BrushtoolReducer = require(Plugin.Core.Reducers.BrushtoolReducer)

local Brushtool = require(Plugin.Core.Brushtool)

local LocalizationService = game:GetService("LocalizationService")
local HttpService = game:GetService("HttpService")

local function createTheme()
	return BrushtoolTheme.new({
		getTheme = function()
			return settings().Studio.Theme
		end,
		isDarkerTheme = function(theme)
			-- Assume "darker" theme if the average main background colour is darker
			local mainColour = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
			return (mainColour.r + mainColour.g + mainColour.b) / 3 < 0.5
		end,
		themeChanged = settings().Studio.ThemeChanged,
	})
end

local function main()
	local pluginFolder
	
	local store = Rodux.Store.new(
		BrushtoolReducer
	)

	local theme = createTheme()

	local brushtoolHandle

	local function onPluginWillDestroy()
		if brushtoolHandle then
			Roact.unmount(brushtoolHandle)
		end
	end
	
	local brushtool = Brushtool.new(store, plugin)

	local brushtoolComponent = Roact.createElement(BrushtoolPlugin, {
		plugin = plugin,
		store = store,
		theme = theme,
		brushtool = brushtool,
		onPluginWillDestroy = onPluginWillDestroy,
	})
	
	brushtoolHandle = Roact.mount(brushtoolComponent)
end

main()
