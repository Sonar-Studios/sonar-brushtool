local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withBrushtool = ContextHelper.withBrushtool

local Actions = Plugin.Core.Actions
local SetStampIgnoreWater = require(Actions.SetStampIgnoreWater)
local SetStampIgnoreInvisible = require(Actions.SetStampIgnoreInvisible)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local CheckboxField = require(Foundation.CheckboxField)
local DropdownField = require(Foundation.DropdownField)
local TextField = require(Foundation.TextField)

local StampSettingsSection = Roact.PureComponent:extend("StampSettingsSection")

function StampSettingsSection:render()
	local props = self.props
	local Visible = props.Visible
	
	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end

	local labelWidth = Constants.FIELD_LABEL_WIDTH
	
	return Roact.createElement(
		VerticalList,
		{
			width = UDim.new(1, 0),
			LayoutOrder = props.LayoutOrder,
			Visible = Visible,
			PaddingTopPixel = 4,
			PaddingBottomPixel = 4,
			ElementPaddingPixel = 4			
		},
		{
			IgnoreWater = Roact.createElement(
				CheckboxField,
				{
					label = "Ignore Water",
					indentLevel = 0,
					labelWidth = labelWidth,
					checked = props.ignoreWater,
					LayoutOrder = generateSequentialLayoutOrder(),
					onToggle = function() props.setIgnoreWater(not props.ignoreWater) end
				}
			),
			IgnoreInvisible = Roact.createElement(
				CheckboxField,
				{
					label = "Ignore Invisible",
					indentLevel = 0,
					labelWidth = labelWidth,
					checked = props.ignoreInvisible,
					LayoutOrder = generateSequentialLayoutOrder(),
					onToggle = function() props.setIgnoreInvisible(not props.ignoreInvisible) end
				}
			)
		}
	)
end

local function mapStateToProps(state, props)
	local stamp = state.stamp
	return {
		ignoreWater = stamp.ignoreWater,
		ignoreInvisible = stamp.ignoreInvisible
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setIgnoreWater = function(ignoreWater) dispatch(SetStampIgnoreWater(ignoreWater)) end,
		setIgnoreInvisible = function(ignoreInvisible) dispatch(SetStampIgnoreInvisible(ignoreInvisible)) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(StampSettingsSection)