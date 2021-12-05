local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local withBrushtool = ContextHelper.withBrushtool
local getModal = ContextGetter.getModal
local getBrushtool = ContextGetter.getBrushtool

local Actions = Plugin.Core.Actions
local AddBrushObject = require(Actions.AddBrushObject)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local ThemedCheckbox = require(Foundation.ThemedCheckbox)
local ObjectThumbnail = require(Foundation.ObjectThumbnail)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local PreciseButton = require(Foundation.PreciseButton)
local BorderedVerticalList = require(Foundation.BorderedVerticalList)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)

local BrushObjectAddEntry = Roact.PureComponent:extend("BrushObjectAddEntry")

function BrushObjectAddEntry:init()
end

local function hasTooManyParts(object)
	local count = 0
	if object:IsA("BasePart") then
		count = count+1
	end

	for _, v in next, object:GetDescendants() do
		if v:IsA("BasePart") then
			count = count+1
		end
		
		if count > 100 then
			return true
		end
	end
	
	return false
end

function BrushObjectAddEntry:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local rbxObject = props.rbxObject
	local name = rbxObject.name
	local Visible = props.Visible

	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end
	
	return withTheme(function(theme)
		return withBrushtool(function(brushtool)
			local buttonTheme = theme.button
			local entryTheme = theme.objectGridEntry

			local entryHeight = 60
			local entryPadding = 5
			local modal = getModal(self)
			local bgColors = entryTheme.backgroundColor
			local tooManyParts = hasTooManyParts(rbxObject)
			local buttonHeight = Constants.BUTTON_HEIGHT
			
			return Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, entryHeight),
					BackgroundTransparency = 1,
					Visible = Visible,
					LayoutOrder = LayoutOrder
				},
				{
					Border = Roact.createElement(
						RoundedBorderedFrame,
						{
							Size = UDim2.new(1, 0, 0, entryHeight),
							BackgroundColor3 = theme.mainBackgroundColor,
							BorderColor3 = theme.borderColor,
							LayoutOrder = props.LayoutOrder
						}
					),
					ImageFrame = Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(0, entryHeight-entryPadding*2, 0, entryHeight-entryPadding*2),
							Position = UDim2.new(0, entryPadding, 0, entryPadding),
							BackgroundColor3 = theme.mainBackgroundColor,
							BorderColor3 = theme.borderColor,
							ZIndex = 2
						},
						{
							Image = not tooManyParts and Roact.createElement(
								ObjectThumbnail,
								{
									object = rbxObject,
									BackgroundColor3 = theme.mainBackgroundColor,
									ImageTransparency = 0,
									ImageColor3 = Color3.new(1, 1, 1),
									cached = false
								}
							),
--									Text = tooManyParts and Roact.createElement(
--										"TextLabel",
--										{
--											Size = UDim2.new(1, 0, 1, 0),
--											BackgroundTransparency = 1,
--											TextColor3 = theme.mainTextColor,
--											Font = Constants.FONT,
--											TextSize = Constants.FONT_SIZE_MEDIUM,
--											Text = "too big to show"
--										}
--									)
						}
					),
					ContentFrame = Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -(entryHeight + entryPadding*3), 1, -entryPadding*2),
							Position = UDim2.new(0, entryHeight+entryPadding*2, 0, entryPadding),
							ZIndex = 2
						},
						{
							TextLabel = Roact.createElement(
								"TextLabel",
								{
									BackgroundTransparency = 1,
									Font = Constants.FONT_BOLD,
									TextColor3 = entryTheme.textColorEnabled,
									Size = UDim2.new(1, 0, 0, Constants.FONT_SIZE_MEDIUM),
									Position = UDim2.new(0, 0, 0, 0),
									Text = string.format("Add %s to brushes?", name),
									TextSize = Constants.FONT_SIZE_MEDIUM,
									TextXAlignment = Enum.TextXAlignment.Center,
									TextTruncate = Enum.TextTruncate.AtEnd,
									ZIndex = 2
								}
							),
							AddButton = Roact.createElement(
								ThemedTextButton,
								{
									Text = "Add",
									buttonStyle = "Add",
									Size = UDim2.new(0, 80, 0, buttonHeight),
									AnchorPoint = Vector2.new(0.5, 1),
									Position = UDim2.new(0.5, 0, 1, 0),
									ZIndex = 2,
									TextTruncate = Enum.TextTruncate.AtEnd,
									onClick = function()
										if brushtool:IsValidBrushCandidate(rbxObject) then
											props.addBrushObject(rbxObject)
											brushtool:RemoveObjectFromSelection(rbxObject)
										end
									end
								}
							),
						}
					)
				}
			)
		end)
	end)
end

function mapStateToProps(state, props)
end

function mapDispatchToProps(dispatch)
	return {
		addBrushObject = function(obj) dispatch(AddBrushObject(obj)) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BrushObjectAddEntry)