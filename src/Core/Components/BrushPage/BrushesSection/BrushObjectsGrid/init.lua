local Plugin = script.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Funcs = require(Plugin.Core.Util.Funcs)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local withBrushtool = ContextHelper.withBrushtool
local getModal = ContextGetter.getModal

local Actions = Plugin.Core.Actions
local SetBrushFilter = require(Actions.SetBrushFilter)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local ThemedCheckbox = require(Foundation.ThemedCheckbox)
local BrushObjectEntry = require(script.BrushObjectEntry)
local BrushObjectAddEntry = require(script.BrushObjectAddEntry)
local BrushNote = require(script.BrushNote)
local ScrollingVerticalList = require(Foundation.ScrollingVerticalList)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local VerticalList = require(Foundation.VerticalList)

local BrushObjectsGrid = Roact.PureComponent:extend("BrushObjectsGrid")

function BrushObjectsGrid:init()

end

function BrushObjectsGrid:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local objects = props.objects
	local filter = props.filter

	return withTheme(function(theme)
		return withBrushtool(function(brushtool)
			local gridPadding = Constants.BRUSH_GRID_PADDING
			local cellSize = Constants.BRUSH_GRID_CELL_SIZE
			local boxPadding = Constants.INPUT_FIELD_BOX_PADDING
			local gridTheme = theme.objectGrid
			local gridBackgroundColor = gridTheme.backgroundColor
			local gridBorderColor = gridTheme.borderColor
			
			local upperFilter = filter:upper()
			local objectList = {}
			local filterCount = 0
			local objectCount = 0
			for guid, object in next, objects do
				objectCount = objectCount+1
				local name = object.name
				local timeAdded = object.timeAdded
				local visible = false
				if string.upper(object.name):find(upperFilter) ~= nil then
					filterCount = filterCount+1
					table.insert(objectList, {guid, name, timeAdded})
				end
			end
						
			table.sort(
				objectList,
				function(a, b)
					local guidA = a[1]
					local guidB = a[2]
					local nameA = a[2]
					local nameB = b[2]
					local addedA = a[3]
					local addedB = b[3]
					
					if nameA < nameB then
						return true
					elseif nameA == nameB and addedA < addedB then
						return true
					else -- if they somehow were added in the same moment, default of comparing their guid.
						return guidA < guidB
					end
				end
			)
			
			local gridChildren = {}
			local overlay
			local totalLayoutOrder = 0
			for i, entry in next, objectList do
				local guid = entry[1]
				gridChildren[guid] = Roact.createElement(
					BrushObjectEntry,
					{
						LayoutOrder = totalLayoutOrder,
						guid = guid
					}
				)
				
				totalLayoutOrder = totalLayoutOrder+1
			end
			
			local bottomPadded = false
			if filter == "" then
				if #brushtool.selection == 0 then
					overlay = Roact.createElement(
						BrushNote,
						{
							noteType = "Info",
							Text = "Select parts or models to add them here.",
							Position = UDim2.new(0, 0, 1, 0),
							AnchorPoint = Vector2.new(0, 1)
						}
					)
					bottomPadded = true
				elseif #brushtool.selection <= 10 then
					local candidates = {}
					local rejectionRanking = {
						NotValidObjectType = 0,
						NotArchivable = 1,
						NoParts = 2,
						NoArchivableParts = 3
					}
					local rejectionReason = nil
					for _, v in next, brushtool.selection do
						local valid, currentRejectReason = brushtool:IsValidBrushCandidate(v)
						if valid then
							table.insert(candidates, v)
						else
							if rejectionReason == nil then
								rejectionReason = currentRejectReason
							elseif rejectionRanking[currentRejectReason] > rejectionRanking[rejectionReason] then
								rejectionReason = currentRejectReason
							end
						end
					end
					
					if #candidates > 0 then
						for _, v in next, candidates do
							gridChildren[totalLayoutOrder] = Roact.createElement(
								BrushObjectAddEntry,
								{
									Text = v.Name,
									LayoutOrder = totalLayoutOrder,
									rbxObject = v
								}
							)
							
							totalLayoutOrder = totalLayoutOrder+1
						end
					else
						local warningTextMapping = {
							NotValidObjectType = "Only parts or models may be added.",
							NotArchivable = "Objects must be archivable.",
							NoParts = "Models must contain at least one part.",
							NoArchivableParts = "At least one part in the model must be archivable."
						}
						
						overlay = Roact.createElement(
							BrushNote,
							{
								noteType = "Warning",
								Text = warningTextMapping[rejectionReason],
								Position = UDim2.new(0, 0, 1, 0),
								AnchorPoint = Vector2.new(0, 1)
							}
						)
						bottomPadded = true
					end
				else
					overlay = Roact.createElement(
						BrushNote,
						{
							noteType = "Warning",
							Text = "Too many object selected.",
							Position = UDim2.new(0, 0, 1, 0),
							AnchorPoint = Vector2.new(0, 1)
						}
					)
					bottomPadded = true
				end
			end
			
			local entryHeight = Constants.ENTRY_NOTE_HEIGHT
			if bottomPadded then
				gridChildren.BottomPadding = Roact.createElement(
					"Frame",
					{
						BackgroundTransparency = 1,
						Size = UDim2.new(0, entryHeight, 0, entryHeight),
						LayoutOrder = 9999
					}
				)
			end
			
			return Roact.createElement( 
				BorderedFrame,
				{
					Size = UDim2.new(1, 0, 0, 60*5),
					BackgroundColor3 = gridBackgroundColor,
					BorderColor3 = gridBorderColor,
					BorderThicknessRight = 0,
					LayoutOrder = LayoutOrder							
				},
				{
					Grid = Roact.createElement(
						ScrollingVerticalList,
						{
							Size = UDim2.new(1, -1, 1, -2),
							Position = UDim2.new(0, 1, 0, 1),
							CellSize = UDim2.new(0, cellSize, 0, cellSize),
							CellPadding = UDim2.new(0, gridPadding, 0, gridPadding),
							PaddingLeftPixel = gridPadding,
							PaddingRightPixel = gridPadding,
							PaddingBottomPixel = gridPadding,
							PaddingTopPixel = gridPadding,
							skipPercent = 0,
							skipPixel = cellSize+gridPadding,
							overlay = overlay
						},
						{
							List = Roact.createElement(
								VerticalList,
								{
									PaddingTopPixel = 4,
									PaddingBottomPixel = 4,
									PaddingLeftPixel = 4,
									PaddingRightPixel = 4,
									ElementPaddingPixel = 4,
									width = UDim.new(1, 0)
								},
								gridChildren
							)
						}
					),
					NoResultsFoundFrame = Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(1, -Constants.SCROLL_BAR_THICKNESS, 1, 0),
							Visible = filterCount == 0 and filter ~= "",
							BackgroundTransparency = 1
						},
						{
							NoResultsLabel = Roact.createElement(
								"TextLabel",
								{
									BackgroundTransparency = 1,
									Text = string.format("No results found for \"%s\".", filter),
									TextColor3 = gridTheme.noResultsColor,
									Font = Enum.Font.SourceSans,
									TextSize = Constants.FONT_SIZE_MEDIUM,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Size = UDim2.new(1, -20, 0, -Constants.FONT_SIZE_MEDIUM*2),
									Position = UDim2.new(0.5, 0, 0.5, -Constants.BUTTON_HEIGHT/2-Constants.FONT_SIZE_MEDIUM),
									TextTruncate = Enum.TextTruncate.AtEnd,
									TextWrapped = true,
									TextYAlignment = Enum.TextYAlignment.Bottom
								}
							),
							EnableButton = Roact.createElement(
								ThemedTextButton,
								{
									Size = UDim2.new(0, 100, 0, Constants.BUTTON_HEIGHT),
									Position = UDim2.new(0.5, 0, 0.5, Constants.BUTTON_HEIGHT/2),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Text = "Clear Filter",
									onClick = props.clearFilter
								}
							),
						}
					)
				}
			)
		end)
	end)
end

local function mapStateToProps(state, props)
	return {
		objects = state.brushObjects,
		selected = state.brush.selected,
		filter = state.brush.filter
	}
end

local function mapDispatchToProps(dispatch)
	return {
		clearFilter = function() dispatch(SetBrushFilter("")) end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BrushObjectsGrid)