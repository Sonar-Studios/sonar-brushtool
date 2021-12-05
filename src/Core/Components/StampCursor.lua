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

local StampCursor = Roact.PureComponent:extend("StampCursor")

function StampCursor:init(props)
	self.StampCursorModel = nil
	self.lastCurrentlyStamping = nil
	self.objectFrameRef = Roact.createRef()
	self.axisFrameRef = Roact.createRef()
	self.arcFrameRef = Roact.createRef()
end

function StampCursor:render()
	local props = self.props
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
							BackgroundColor3 = Color3.new(0, 1, 0),
							ImageColor3 = Color3.new(0, 1, 0),
							CurrentCamera = workspace.CurrentCamera,
							ImageTransparency = 0.5,
							[Roact.Ref] = self.objectFrameRef,
							ZIndex = 2
						}
					),
					AxisFrame = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.new(0, 0, 0),
							ImageColor3 = Color3.new(1, 1, 1),
							CurrentCamera = workspace.CurrentCamera,
							ImageTransparency = 0,
							[Roact.Ref] = self.axisFrameRef,
							ZIndex = 3
						},
						{
						}
					),
					ArcFrame = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.new(1, 1, 0),
							ImageColor3 = Color3.new(1, 1, 0),
							CurrentCamera = workspace.CurrentCamera,
							ImageTransparency = 0.5,
							[Roact.Ref] = self.arcFrameRef,
							ZIndex = 1
						},
						{
						}
					)
				}
			)
		}
	)
end

local function isVisual(object, isRoot)
	if not isRoot then
		return (object:IsA("BasePart") or
			object:IsA("Decal") or
			object:IsA("Texture") or
			object:IsA("Model") or
			object:IsA("DataModelMesh")
		)
	else
		return object:IsA("BasePart") or
			object:IsA("Model")
	end
end

local function prepareForThumbnail(object, _isRoot)
	local _isRoot = _isRoot == nil
	
	for _, child in next, object:GetChildren() do
		prepareForThumbnail(child, false)
	end
	
	if not isVisual(object, _isRoot) then
		local children = object:GetChildren()
		if #children == 0 and not _isRoot then
			object:Destroy()
			return
		end
		
		local model = Instance.new("Model")
		for _, child in next, children do
			child.Parent = model
		end
		model.Name = object.Name
		model.Parent = object.Parent
		object:Destroy()
		
		return model
	end
	
	return object
end

local CollectionService = game:GetService("CollectionService")

function StampCursor:RefreshStampCursorModel(object)
	if self.stampCursorModel then
		self.stampCursorModel:Destroy()
		self.stampCursorModel = nil
	end
	
	local objectFrame = self.objectFrameRef.current
	local rbxObject = object.rbxObject
	local objectClone = prepareForThumbnail(rbxObject:Clone())
	objectClone.Parent = objectFrame
	local stampCursorModel = Instance.new("Model")
	objectClone.Parent = stampCursorModel
	local wrapper = Instance.new("Part")
	wrapper.Size = Vector3.new(0, 0, 0)
	wrapper.Transparency = 1
	wrapper.Anchored = true
	wrapper.Parent = stampCursorModel

	local center do
		if rbxObject:IsA("BasePart") then
			center = rbxObject.Position
		else
			if object.stampCenterMode == "BoundingBox" then
				local min, max = Utility.GetModelAABBFast(rbxObject)
				center = (max+min)/2
			else
				center = rbxObject.PrimaryPart.Position
			end
		end
	end
	
	wrapper.CFrame = CFrame.new(center)
	stampCursorModel.PrimaryPart = wrapper
	stampCursorModel.Parent = objectFrame
	
	local objectScale = object.scale
	local scale do
		local mode = objectScale.mode
		if mode == "None" then
			scale = 1
		elseif mode == "Fixed" then
			scale = objectScale.fixed
		else
			scale = (objectScale.min+objectScale.max)/2
		end
	end
	
	if scale ~= 1 then
		for _, v in next, stampCursorModel:GetDescendants() do
			if v:IsA("BasePart") then
				v.Size = v.Size*scale
				v.Position = v.Position*scale
			elseif v:IsA("JointInstance") then
				local C0, C1 = v.C0, v.C1
				v.C0 = C0 + (C0.p*(scale-1))
				v.C1 = C1 + (C1.p*(scale-1))
			elseif v:IsA("DataModelMesh") then
				if v:IsA("SpecialMesh") and v.MeshType == Enum.MeshType.FileMesh then
					v.Scale = v.Scale*scale
				end
				v.Offset = v.Offset*scale
			end
		end
	end
	
	self.stampCursorModel = stampCursorModel
end

function StampCursor:RefreshArcModel(object)
	if self.arcModel then
		self.arcModel:Destroy()
		self.arcModel = nil
	end
		
	local min = object.rotation.min
	local max = object.rotation.max
	local delta = max-min
	
	local soFar = 0
	local remaining = delta
	
	local arcs = {
		128, 64, 32, 16, 8, 4, 2, 1
	}
	
	local arcParts = {
		Constants.ARC_128_PART,
		Constants.ARC_64_PART,
		Constants.ARC_32_PART,
		Constants.ARC_16_PART,
		Constants.ARC_8_PART,
		Constants.ARC_4_PART,
		Constants.ARC_2_PART,
		Constants.ARC_1_PART,
	}
	
	local arcModel = Instance.new("Model")
	
	while remaining > 0 do
		local chosenArc
		for arcIdx, arcSize in next, arcs do
			if remaining >= arcSize then
				remaining = remaining-arcSize
				chosenArc = arcIdx
				break
			end
		end
		
		if chosenArc == nil then
			chosenArc = 8
		end
		
		local arcPart = arcParts[chosenArc]:Clone()
		
		arcPart.CFrame = Utility.CFrameFromTopRight(Vector3.new(), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0)) * CFrame.Angles(0, math.rad(delta/2-soFar+180), 0)
		arcPart.Parent = arcModel
		
		soFar = soFar + arcs[chosenArc]
	end
	
	local handle = Instance.new("Part")
	handle.Transparency = 1
	handle.CFrame = Utility.CFrameFromTopRight(Vector3.new(), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0))
	handle.Parent = arcModel
	arcModel.PrimaryPart = handle
	arcModel.Parent = self.arcFrameRef.current
	self.arcModel = arcModel
end

function StampCursor:didMount()
	local props = self.props
	local stamp = props.stamp
	local objectFrame = self.objectFrameRef.current
	local axisFrame = self.axisFrameRef.current
	local arcFrame = self.arcFrameRef.current
	local axis = Constants.TINYAXIS_MODEL:Clone()
	axis.Parent = axisFrame
	self.axis = axis
	local stampObjects = props.stampObjects
	local currentlyStamping = stamp.currentlyStamping
	local object = stampObjects[currentlyStamping]
	if object then
		self:RefreshStampCursorModel(object)
		
		if object.rotation.mode == "Random" then
			self:RefreshArcModel(object)
		end
	end

	self.hConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
		local props = self.props
		local stamp = props.stamp
		local stampObjects = props.stampObjects
		local currentlyStamping = stamp.currentlyStamping
		local object = stampObjects[currentlyStamping]
		
		local brushtool = getBrushtool(self)
		local prog = tick()%0.7 / 0.7
		local progQuad = prog^2
		local cursorColor
		if brushtool.isMouseDown then
			objectFrame.ImageTransparency = 0.2
			cursorColor = Color3.new(0.5, 1, 0.5)
		else
			objectFrame.ImageTransparency = Utility.LerpClamped(0.2, 0.8, progQuad)	
			cursorColor = Color3.new(0, 1, 0)
		end
		objectFrame.ImageColor3 = cursorColor
		objectFrame.BackgroundColor3 = cursorColor
		axisFrame.BackgroundColor3 = cursorColor
		if object and 
			brushtool.mode == "Stamp" and 
			( 
				(brushtool.isMouseDown and object.rotation.mode == "ClickAndDrag" and brushtool.mouseDownHit) or
				(brushtool.hit)
			) and 
			self.stampCursorModel then
			
			local rotationMode = object.rotation.mode
			local cf, norm do
				if rotationMode == "ClickAndDrag" then
					if brushtool.isMouseDown and brushtool.mouseDownHit then
						cf = brushtool.mouseDownCf
						norm = brushtool.mouseDownNorm
					else
						cf = brushtool.cf
						norm = brushtool.norm
					end
				else
					cf = brushtool.cf
					norm = brushtool.norm
				end
			end
			local p = cf.p
			local stamp = props.stamp
			local stampObjects = props.stampObjects
			local currentlyStamping = stamp.currentlyStamping
			local object = stampObjects[currentlyStamping]
			
			local objectOrientation = object.orientation
			local orientation do
				local mode = objectOrientation.mode
				if mode == "Normal" then
					orientation = norm
				elseif mode == "Up" then
					orientation = Vector3.new(0, 1, 0)
				else
					orientation = objectOrientation.custom.unit
				end
			end
			
			local objectRotation = object.rotation
			local rotation do
				local mode = objectRotation.mode
				if mode == "ClickAndDrag" then
					if brushtool.mouseDownHit and brushtool.isMouseDown then
						local delta = brushtool.mouseDownCf.p - brushtool.cf.p
						if delta.magnitude == 0 then
							rotation = 0
						else
							delta = delta.unit
							if math.abs(orientation.x) ~= 1 then
								rotation = Utility.GetAngleBetweenVectorsSigned(Vector3.new(1, 0, 0), delta, orientation)
								rotation = math.deg(rotation) - 90
							else
								rotation = Utility.GetAngleBetweenVectorsSigned(Vector3.new(0, 0, 1).unit, delta, orientation)
								rotation = math.deg(rotation) - 180
							end
						end
					else
						rotation = 0
					end
				elseif mode == "None" then
					rotation = 0
				elseif mode == "Fixed" then
					rotation = objectRotation.fixed
				else
					rotation = (objectRotation.min+objectRotation.max)/2
				end
			end
			
			local objectScale = object.scale
			local scale do
				local mode = objectScale.mode
				if mode == "None" then
					scale = 1
				elseif mode == "Fixed" then
					scale = objectScale.fixed
				else
					scale = (objectScale.min+objectScale.max)/2
				end
			end
			
			local verticalOffset do
				local objectVerticalOffset = object.verticalOffset
				local mode = objectVerticalOffset.mode
				if mode == "Auto" then
					if object.stampCenterMode == "BoundingBox" then
						verticalOffset = object.size.y/2
					else
						local primaryPart = object.rbxObject.PrimaryPart
						local min, max = Utility.GetPartAABB(primaryPart)
						verticalOffset = (max-min).y/2
					end
				elseif mode == "Fixed" then
					verticalOffset = objectVerticalOffset.fixed
				else
					verticalOffset = (objectVerticalOffset.min+objectVerticalOffset.max)/2
				end
			end 
			
			verticalOffset = verticalOffset*scale
			
			local p = cf.p
			local size = object.size
			local finalP = p+orientation*verticalOffset
			local finalCf
			local xVec
			if math.abs(orientation.x) ~= 1 then
				xVec = Vector3.new(1, 0, 0)
			else
				xVec = Vector3.new(0, 0, 1)
			end
			
			local finalCf = Utility.CFrameFromTopRight(
				finalP,
				orientation,
				Utility.ProjectVectorToPlane(xVec, orientation)
			) * CFrame.Angles(0, math.rad(rotation), 0)
			local stampCursorModel = self.stampCursorModel
			stampCursorModel:SetPrimaryPartCFrame(finalCf)
			
			local axisCf = Utility.CFrameFromTopRight(
				cf.p,
				orientation,
				Utility.ProjectVectorToPlane(xVec, orientation)
			) * CFrame.Angles(0, math.rad(rotation), 0)
			axis:SetPrimaryPartCFrame(axisCf)
			if self.arcModel then
				self.arcModel:SetPrimaryPartCFrame(axisCf)
			end
			objectFrame.Visible = true
			axisFrame.Visible = true
			arcFrame.Visible = true
		else
			objectFrame.Visible = false
			axisFrame.Visible = false
			arcFrame.Visible = false
		end
	end)
end

function StampCursor:didUpdate(oldProps)
	local newProps = self.props
	
	local newObject, oldObject = newProps.object, oldProps.object
	
	if newObject ~= nil and newObject.rotation.mode == "Random" then
		if oldObject == nil or
			oldObject.rotation.mode ~= "Random" or
			oldObject.rotation.min ~= newObject.rotation.min or 
			oldObject.rotation.max ~= newObject.rotation.max then
			
			
			self:RefreshArcModel(newObject)			
		end
	elseif self.arcModel then
		self.arcModel:Destroy()
		self.arcModel = nil
	end
		
	if newObject ~= nil then
		if oldObject == nil or
			oldObject.rbxObject ~= newObject.rbxObject or
			oldObject.scale.min ~= newObject.scale.min or
			oldObject.scale.max ~= newObject.scale.max or
			oldObject.scale.fixed ~= newObject.scale.fixed or
			oldObject.stampCenterMode ~= newObject.stampCenterMode or
			oldObject.scale.mode ~= newObject.scale.mode then
				
			self:RefreshStampCursorModel(newObject)
		end
	else
		if self.stampCursorModel then
			self.stampCursorModel:Destroy()
			self.stampCursorModel = nil
		end
	end
end

function StampCursor:willUnmount()
	self.hConn:Disconnect()
	
	if self.stampCursorModel then
		self.stampCursorModel:Destroy()
	end
	
	if self.axis then
		self.axis:Destroy()
	end
	
	if self.arcModel then
		self.arcModel:Destroy()
	end
end

local function mapStateToProps(state, props)
	local stamp = state.stamp
	local stampObjects = state.stampObjects
	local currentlyStamping = stamp.currentlyStamping
	local object = stampObjects[currentlyStamping]
	return {
		stamp = stamp,
		stampObjects = stampObjects,
		currentlyStamping = currentlyStamping,
		object = object
	}
end

local function mapDispatchToProps(dispatch)
	return {

	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(StampCursor)
