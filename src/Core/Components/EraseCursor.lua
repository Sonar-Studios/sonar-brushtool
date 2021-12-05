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
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local withBrushtool = ContextHelper.withBrushtool
local getBrushtool = ContextGetter.getBrushtool

local EraseCursor = Roact.PureComponent:extend("EraseCursor")

function EraseCursor:init(props)
	self.axisFrameRef = Roact.createRef()
	self.cursorRef = Roact.createRef()
	self.cursorFrameRef = Roact.createRef()
end

function EraseCursor:render()
	local props = self.props
	local radius = props.radius
	local brushtool = getBrushtool(self)
	return Roact.createElement(
		Roact.Portal,
		{
			target = game:GetService("CoreGui")
		},
		{
			ScreenGui = Roact.createElement(
				"ScreenGui",
				{
					
				},
				{
					ViewportFrame = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.new(1, 0, 0),
							ImageColor3 = Color3.new(1, 0, 0),
							CurrentCamera = workspace.CurrentCamera,
							ImageTransparency = 0.5,
							[Roact.Ref] = self.cursorFrameRef
						},
						{
							Cursor = Roact.createElement(
								"Part",
								{
									Anchored = true,
									Size = Vector3.new(0.05, radius*2, radius*2),
									Transparency = 0,
									Shape = Enum.PartType.Cylinder,
									Archivable = false,
									Material = Enum.Material.SmoothPlastic,
									Color = Color3.new(1, 1, 1),
									Locked = true,
									[Roact.Ref] = self.cursorRef
								}
							)
						}
					),
					AxisFrame = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.new(1, 0, 0),
							ImageColor3 = Color3.new(1, 1, 1),
							CurrentCamera = workspace.CurrentCamera,
							ImageTransparency = 0,
							[Roact.Ref] = self.axisFrameRef,
							ZIndex = 2,
							Visible = false -- Hidden for now. Probably indefinitely.
						},
						{
						}
					)
				}
			)
		}
	)
end

function EraseCursor:didMount()
	local axisFrame = self.axisFrameRef.current
	local cursorFrame = self.cursorFrameRef.current
	local axis = Constants.TINYAXIS_MODEL:Clone()
	local cursor = self.cursorRef.current
	axis.Parent = axisFrame
	self.axis = axis
	
	self.hConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
		local brushtool = getBrushtool(self)
		local prog = tick()%0.7 / 0.7
		local progQuad = prog^2
		local cursorColor
		if brushtool.isMouseDown then
			cursorFrame.ImageTransparency = 0.2
			cursorColor = Color3.new(1, 0.5, 0.5)
		else
			cursorFrame.ImageTransparency = Utility.LerpClamped(0.2, 0.8, progQuad)
			cursorColor = Color3.new(1, 0, 0)
		end
		cursorFrame.ImageColor3 = cursorColor
		cursorFrame.BackgroundColor3 = cursorColor
		axisFrame.BackgroundColor3 = cursorColor
		
		if brushtool.mode == "Erase" and brushtool.hit then
			local orientation = brushtool.norm
			local p = brushtool.cf.p
			
			local finalCf
			if orientation ~= Vector3.new(1, 0, 0) and orientation ~= Vector3.new(-1, 0, 0) then
				finalCf = Utility.CFrameFromTopRight(
					p,
					orientation,
					Utility.ProjectVectorToPlane(Vector3.new(1, 0, 0), orientation)
				)
			else
				finalCf = Utility.CFrameFromTopRight(
					p,
					orientation,
					Utility.ProjectVectorToPlane(Vector3.new(0, 0, 1).unit, orientation)
				)
			end
			axis:SetPrimaryPartCFrame(finalCf)
			
			cursor.CFrame = brushtool.cf * CFrame.Angles(0, math.pi/2, 0)
			cursorFrame.Visible = true
--			axisFrame.Visible = true
		else
			cursorFrame.Visible = false
--			axisFrame.Visible = false
		end
	end)
end

function EraseCursor:willUnmount()
	self.hConn:Disconnect()
	self.axis:Destroy()
end

local function mapStateToProps(state, props)
	return {
		started = state.stateCopied,
		radius = state.erase.radius
	}
end

local function mapDispatchToProps(dispatch)
	return {

	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(EraseCursor)
