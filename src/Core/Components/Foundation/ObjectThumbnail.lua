local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local RoactRodux = require(Libs.RoactRodux)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local ObjectThumbnail = Roact.PureComponent:extend("ObjectThumbnail")

local fov = 1
local defaultLook = Vector3.new(-0.5, -0.4, -0.5)
local cameraBase = Instance.new("Camera")
cameraBase.FieldOfView = fov

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

local function moveObjectToCenter(object)
	if #object:GetChildren() == 0 and object:IsA("Model") then
		return
	end
	
	if object:IsA("Model") then
		local min, max = Utility.GetModelAABBFast(object)
		local boundingBox = Instance.new("Part")
		boundingBox.Size = max-min
		boundingBox.CFrame = CFrame.new((min+max)/2)
		local originalPrimaryPart = object.PrimaryPart
		object.PrimaryPart = boundingBox
		object:SetPrimaryPartCFrame(CFrame.new())
		object.PrimaryPart = originalPrimaryPart
	else
		object.CFrame = object.CFrame - object.Position
	end
end

local function GetZoomOffset(fov, aspectRatio, targetSize, percentOfScreen)
	local x, y, z = targetSize.x, targetSize.y, targetSize.Z
	local maxSize = math.sqrt(x^2 + y^2 + z^2)
	local heightFactor = math.tan(math.rad(fov)/2)
	local widthFactor = aspectRatio*heightFactor

	local depth = 0.5*maxSize/(percentOfScreen.x*widthFactor)
	local depthTwo = 0.5*maxSize/(percentOfScreen.y*heightFactor)

	return math.max(depth, depthTwo)+maxSize/2
end

local thumbCache = {}
setmetatable(thumbCache, { __mode = "k" })

local function getThumbEntry(object, fromCache)
	local thumbEntry = thumbCache[object]
	if thumbEntry == nil or fromCache == false then
		local ok, err = pcall(function()
			local copy = object:Clone()
			copy = prepareForThumbnail(copy)
			moveObjectToCenter(copy)
			local min, max
			if copy:IsA("Model") then
				min, max = Utility.GetModelAABBFast(copy)
			else
				min, max = Utility.GetPartAABB(copy)
			end
			
			local dist = GetZoomOffset(fov, 1, (max-min), Vector2.new(1, 1))
			
			thumbEntry = { copy, dist }
			thumbCache[object] = thumbEntry
		end)
		
		if not ok then
			thumbEntry = { Instance.new("Model"), 0 }
			thumbCache[object] = thumbEntry			
		end
	end
	
	return thumbEntry
end

function ObjectThumbnail:init()
	self.boxRef = Roact.createRef()
end

function ObjectThumbnail:render()
	local props = self.props
	local object = props.object
	local BackgroundColor3 = props.BackgroundColor3
	local ImageTransparency = props.ImageTransparency or 0
	local ImageColor3 = props.ImageColor3
	assert(object == nil or (object:IsA("BasePart") or object.ClassName == "Model" or object:IsA("Folder")))
	
	return Roact.createElement(
		"ViewportFrame",
		{
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = BackgroundColor3,
			BackgroundTransparency = 1,
			ImageColor3 = ImageColor3,
			ImageTransparency = ImageTransparency,
			ZIndex = props.ZIndex,
			[Roact.Ref] = self.boxRef
		}
	)
end

function ObjectThumbnail:didMount()
	local props = self.props
	local viewportFrame = self.boxRef.current
	local object = props.object
	if object then
		local thumbEntry = getThumbEntry(object, self.props.cached)
		local objectClone, dist = thumbEntry[1]:Clone(), thumbEntry[2]
		self.dist = dist
		local cam = cameraBase:Clone()
		local look = CFrame.Angles(0, props.yRotation or 0, 0):vectorToWorldSpace(defaultLook)
		cam.CFrame = CFrame.new(Vector3.new(), look) * CFrame.new(0, 0, dist)
	
		objectClone.Parent = viewportFrame
		cam.Parent = viewportFrame
		viewportFrame.CurrentCamera = cam
		self.objectClone, self.cam = objectClone, cam
	end
end

function ObjectThumbnail:willUnmount()
	if self.objectClone then
		self.objectClone:Destroy()
		self.cam:Destroy()
	end
end

function ObjectThumbnail:didUpdate(oldProps)
	local newProps = self.props
	local newObject, oldObject = newProps.object, oldProps.object
	if newObject ~= oldObject then
		if newObject ~= nil then
			if self.objectClone then
				self.objectClone:Destroy()
				self.objectClone = nil
			end
			
			local viewportFrame = self.boxRef.current
			local thumbEntry = getThumbEntry(newObject)
			local objectClone, dist = thumbEntry[1]:Clone(), thumbEntry[2]
			self.dist = dist
			objectClone.Parent = viewportFrame
			
			local cam = self.cam
			if not cam then
				cam = cameraBase:Clone()
				self.cam = cam
			end
			local look = CFrame.Angles(0, newProps.yRotation or 0, 0):vectorToWorldSpace(defaultLook)
			cam.CFrame = CFrame.new(Vector3.new(), look) * CFrame.new(0, 0, dist)
			cam.Parent = viewportFrame
			self.objectClone = objectClone
		else
			if self.objectClone then
				self.objectClone:Destroy()
				self.objectClone = nil
			end
		end
	end
	
	if oldProps.yRotation ~= newProps.yRotation then
		local cam = self.cam
		local look = CFrame.Angles(0, newProps.yRotation or 0, 0):vectorToWorldSpace(defaultLook)
		cam.CFrame = CFrame.new(Vector3.new(), look) * CFrame.new(0, 0, self.dist)
	end
end

return ObjectThumbnail