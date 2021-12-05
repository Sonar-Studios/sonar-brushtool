local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getBrushtool = ContextGetter.getBrushtool

local BrushtoolConsumer = Roact.PureComponent:extend("BrushtoolConsumer")

function BrushtoolConsumer:init()
	local brushtool = getBrushtool(self)

	self:setState{
		selection = brushtool.selection
	}

	self.brushtool = brushtool
end

function BrushtoolConsumer:render()
	return self.props.render(self.brushtool)
end

function BrushtoolConsumer:didMount()
	self.disconnectModalListener = self.brushtool:subscribe(function()
		self:setState{
			selection = self.brushtool.selection
		}
	end)
end

function BrushtoolConsumer:start()
	
end

function BrushtoolConsumer:willUnmount()
	self.disconnectModalListener()
end

return BrushtoolConsumer
