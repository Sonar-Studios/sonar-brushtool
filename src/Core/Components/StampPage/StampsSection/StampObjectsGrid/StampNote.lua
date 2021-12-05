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
local AddStampObject = require(Actions.AddStampObject)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local ThemedCheckbox = require(Foundation.ThemedCheckbox)
local ObjectThumbnail = require(Foundation.ObjectThumbnail)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local PreciseButton = require(Foundation.PreciseButton)
local BorderedVerticalList = require(Foundation.BorderedVerticalList)

local StampNote = Roact.PureComponent:extend("StampNote")

function StampNote:init()
end

function StampNote:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local Visible = props.Visible
	local Text = props.Text
	local noteType = props.noteType
	local Position = props.Position
	local AnchorPoint = props.AnchorPoint
	
	local layoutOrder = 0
	local function generateSequentialLayoutOrder()
		layoutOrder = layoutOrder+1
		return layoutOrder
	end
	
	return withTheme(function(theme)
		return withBrushtool(function(brushtool)
			local buttonTheme = theme.button
			local entryTheme = theme.objectGridEntry
	
			local imagePadding = 1
			local entryHeight = Constants.ENTRY_NOTE_HEIGHT
			local entryPadding = Constants.ENTRY_NOTE_PADDING
			local modal = getModal(self)
			local bgColors = entryTheme.backgroundColor
			local buttonHeight = Constants.BUTTON_HEIGHT
			local imageHeight = (entryHeight-entryPadding*2)
			return Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, 0, 0, entryHeight),
					BackgroundTransparency = 1,
					Visible = Visible,
					LayoutOrder = LayoutOrder,
					Position = Position,
					AnchorPoint = AnchorPoint
				},
				{
					DShadow = Roact.createElement(
						"ImageLabel",
						{
							Size = UDim2.new(1, 0, 0, -8),
							Image = Constants.DROP_SHADOW_TOP_IMAGE,
							BackgroundTransparency = 1,
							ImageTransparency = 0.5
						}
					),
					Border = Roact.createElement(
						BorderedFrame,
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundColor3 = bgColors.Default,
							BorderColor3 = theme.borderColor,
							BorderThicknessLeft = 0,
							BorderThicknessRight = 0,
							BorderThicknessTop = 1,
							BorderThicknessBottom = 0
						}
					),
					Image = Roact.createElement(
						"ImageLabel",
						{
							Size = UDim2.new(0, imageHeight, 0, imageHeight),
							Position = UDim2.new(0, entryPadding, 0, entryPadding),
							BackgroundTransparency = 1,
							ZIndex = 2,
							Image = noteType == "Warning" and Constants.WARNING_IMAGE or Constants.INFO_IMAGE,
							ImageColor3 = theme.mainTextColor
						}
					),
					ContentFrame = Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -(imageHeight + entryPadding*3), 1, -entryPadding*2),
							Position = UDim2.new(0, imageHeight+entryPadding*2, 0, entryPadding),
							ZIndex = 2
						},
						{
							TextLabel = Roact.createElement(
								"TextLabel",
								{
									BackgroundTransparency = 1,
									Font = Constants.FONT_BOLD,
									TextColor3 = entryTheme.textColorEnabled,
									Size = UDim2.new(1, 0, 1, 0),
									Position = UDim2.new(0, 0, 0, 0),
									Text = Text,
									TextWrapped = true,
									TextSize = Constants.FONT_SIZE_MEDIUM,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextTruncate = Enum.TextTruncate.AtEnd,
									ZIndex = 2
								}
							)
						}
					)
				}
			)
		end)
	end)
end

return StampNote