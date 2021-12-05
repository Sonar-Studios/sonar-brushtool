local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Keys = require(Plugin.Core.Util.Keys)

local BrushtoolProvider = Roact.Component:extend("BrushtoolProvider")

function BrushtoolProvider:init()
	self._context[Keys.brushtool] = self.props.brushtool
end

function BrushtoolProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

function BrushtoolProvider:willUnmount()
	local brushtool = self._context[Keys.brushtool]
	if brushtool then
		brushtool:destroy()
	end
end

return BrushtoolProvider
