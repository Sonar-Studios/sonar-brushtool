-- InstanceStore
-- Makes sure that plugin data sticks with the place file.

-- we need to parent the thing under a service that can't be deleted.
local PluginStorageRoot = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local JSON_ROOT_NAME = "jsonRoot"
local INSTANCE_ROOT_NAME = "instanceRoot"

local InstanceStore = {}
InstanceStore.__index = InstanceStore
InstanceStore.StorageRoot = PluginStorageRoot

local function doesScopeRootExist(scope)
	local scopeRoot = PluginStorageRoot:FindFirstChild(scope)
	return scopeRoot ~= nil
end

local function getScopeRoot(scope)
	local scopeRoot = PluginStorageRoot:FindFirstChild(scope)
	if not scopeRoot or scopeRoot.Archivable == false  then
		scopeRoot = Instance.new("Folder")
		scopeRoot.Name = scope
		scopeRoot.Parent = PluginStorageRoot
	end
	
	return scopeRoot
end

function InstanceStore.new(scope, name)
	local self = setmetatable({}, InstanceStore)
	self.scope = scope
	
	local storedRoot = getScopeRoot(scope):FindFirstChild(name)
	local root
	if not storedRoot or storedRoot.Archivable == false then
		if storedRoot then
			storedRoot:Destroy()
		end
		root = Instance.new("Folder")
		root.Name = name
	else
		root = storedRoot:Clone()
		storedRoot:Destroy()
	end
	
	local foundKeys = {}
	for _, v in next, root:GetChildren() do
		-- ensure that all instances are archivable
		if not v.Archivable then
			v:Destroy()
		-- and that there are no duplicates
		elseif foundKeys[v.Name] then
			v:Destroy()
		-- and that there are exactly one children
		elseif #v:GetChildren() > 1 then
			v:Destroy()
		-- and that the only child is archivable
		elseif not v:GetChildren()[1].Archivable then
			v:Destroy()
		else
			foundKeys[v.Name] = true
		end
	end
	
	self.root = root
	self.mountedRoot = root:Clone()
	self.mountedRoot.Parent = getScopeRoot(scope)
	self.instanceIdsToRemount = {}
	self.mountedInstances = {}
	self.instanceCache = {}

	self.remountDetectionBlock = false
	local function initializeMountedInstance(instanceFolder)
		local id = instanceFolder.Name
		--print(id .. " instance initialized")
		instanceFolder.ChildAdded:Connect(function()
			if self.remountDetectionBlock then return end
			self.instanceIdsToRemount[id] = true
		end)
		
		instanceFolder.ChildRemoved:Connect(function()
			if self.remountDetectionBlock then return end
			self.instanceIdsToRemount[id] = true
		end)
		
		instanceFolder.Changed:Connect(function()
			if self.remountDetectionBlock then return end
			self.instanceIdsToRemount[id] = true
		end)
		
		for _, v in next, instanceFolder:GetDescendants() do
			if not v:IsA("ValueBase") then
				-- Waaay too buggy.
				-- Things such as joint updates and absolute size of UIs can
				-- trigger this.
				--v.Changed:Connect(function(prop)
				--	print(prop)
				--	if self.remountDetectionBlock then return end
				--	self.instanceIdsToRemount[id] = true
				--end)
				v:GetPropertyChangedSignal("Archivable"):Connect(function()
					if self.remountDetectionBlock then return end
					self.instanceIdsToRemount[id] = true
				end)
			else
				-- The changed signal for values only fires when it's Value is changed.
				v:GetPropertyChangedSignal("Value"):Connect(function()
					if self.remountDetectionBlock then return end
					self.instanceIdsToRemount[id] = true
				end)
				
				v:GetPropertyChangedSignal("Name"):Connect(function()
					if self.remountDetectionBlock then return end
					self.instanceIdsToRemount[id] = true
				end)
				
				v:GetPropertyChangedSignal("Archivable"):Connect(function()
					if self.remountDetectionBlock then return end
					self.instanceIdsToRemount[id] = true
				end)
			end
			
			v.ChildAdded:Connect(function()
				if self.remountDetectionBlock then return end
				self.instanceIdsToRemount[id] = true
			end)
			
			v.ChildRemoved:Connect(function()
				if self.remountDetectionBlock then return end
				self.instanceIdsToRemount[id] = true
			end)
		end
		
		self.mountedInstances[id] = 
			{
				instanceFolder, 
				instanceFolder:GetChildren()[1]
			}
	end
	
	local function initializeMountedRoot(root)
		--print("instance root initialized")
		root.Changed:Connect(function()
			if self.remountDetectionBlock then return end
			self.rootMustRemount = true
		end)
		
		root.ChildAdded:Connect(function()
			if self.remountDetectionBlock then return end
			self.rootMustRemount = true
		end)
		
		root.ChildRemoved:Connect(function()
			if self.remountDetectionBlock then return end
			self.rootMustRemount = true
		end)
		
		root.AncestryChanged:Connect(function()
			if self.remountDetectionBlock then return end
			self.rootMustRemount = true
		end)
		
		self.mountedInstances = {}
		
		for _, instanceFolder in next, root:GetChildren() do
			initializeMountedInstance(instanceFolder)
		end
	end
	
	initializeMountedRoot(self.mountedRoot)
	
	local function mustSave()
		return self.rootMustRemount or
			next(self.instanceIdsToRemount) ~= nil
	end
	
	local function save()
		self.remountDetectionBlock = true
		
		if self.rootMustRemount then
			self.mountedRoot:Destroy()
			for _, instanceEntry in next, self.mountedInstances do
				instanceEntry[1]:Destroy()
				instanceEntry[2]:Destroy()
			end
			
			self.rootMustRemount = false
			self.instanceIdsToRemount = {}
			
			self.mountedRoot = root:Clone()
			self.mountedRoot.Parent = getScopeRoot(scope)
			initializeMountedRoot(self.mountedRoot)
		else
			for id, _ in next, self.instanceIdsToRemount do
				local instanceEntry = self.mountedInstances[id]
				if instanceEntry then
					instanceEntry[1]:Destroy()
					instanceEntry[2]:Destroy()
				end
				
				local originalInstanceFolder = self.root:FindFirstChild(id)
				-- The instance to remount may have been deleted.
				if originalInstanceFolder then
					local mountedInstance = originalInstanceFolder:Clone()
					mountedInstance.Parent = self.mountedRoot
					initializeMountedInstance(mountedInstance)
				end
			end
			self.instanceIdsToRemount = {}
		end
		
		self.remountDetectionBlock = false
	end
	
	self.mustSave = mustSave
	self.save = save
	
	return self
end

-- stolen from the lua website
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    
	return copy
end

function InstanceStore:MustSave()
	return self.mustSave()
end

function InstanceStore:Save()
	self.save()
end

function InstanceStore:WriteInstance(id, instance)
	assert(typeof(id) == "string")
	assert(typeof(instance) == "Instance")
	assert(instance.Archivable)
	
	local instanceFolder = self.root:FindFirstChild(id)
	if instanceFolder then
		instanceFolder:ClearAllChildren()
	else
		instanceFolder = Instance.new("Folder")
		instanceFolder.Parent = self.root
		instanceFolder.Name = id
	end
	
	local instanceClone = instance:Clone()
	instanceClone.Parent = instanceFolder
	self.instanceCache[id] = instanceClone
	
	self.instanceIdsToRemount[id] = true
end

function InstanceStore:ReadInstance(id)
	assert(typeof(id) == "string")
	
	local cached = self.instanceCache[id]
	if cached then
		return cached:Clone()
	else
		local instanceFolder = self.root:FindFirstChild(id)
		if not instanceFolder then
			return nil
		end
		
		local instance = instanceFolder:GetChildren()[1]
		self.instanceCache[id] = instance
		
		return instance:Clone()
	end
end

function InstanceStore:DeleteInstance(id)
	assert(typeof(id) == "string")

	local instanceFolder = self.root:FindFirstChild(id)
	if not instanceFolder then
		return
	end
	
	instanceFolder:Destroy()
	self.instanceCache[id] = nil
	
	local instanceEntry = self.mountedInstances[id]
	if instanceEntry then
		self.remountDetectionBlock = true
		instanceEntry[1]:Destroy()
		instanceEntry[2]:Destroy()
		self.mountedInstances[id] = nil
		self.remountDetectionBlock = false
	end
end

function InstanceStore:GetInstanceIds()
	local ids = {}
	for _, instanceFolder in next, self.root:GetChildren() do
		table.insert(ids, instanceFolder.Name)
	end
	
	return ids
end

function InstanceStore:HasInstance(id)
	assert(typeof(id) == "string")	
	return self.instanceCache[id] ~= nil or self.root:FindFirstChild(id) ~= nil
end

function InstanceStore:Destroy()
	-- Disconnect all connections by re-creating the mounted root lol.
	local clone = self.mountedRoot:Clone()
	self.mountedRoot:Destroy()
	clone.Parent = getScopeRoot(self.scope)
end

function InstanceStore.ClearStore(scope, name)
	if not doesScopeRootExist(scope) then return end
	
	while true do
		local store = getScopeRoot(scope):FindFirstChild(name)
		if store then
			store:Destroy()
		else
			break
		end
	end
end

function InstanceStore.DoesStoreExist(scope, name)
	if not doesScopeRootExist(scope) then return false end

	return getScopeRoot(scope):FindFirstChild(name) ~= nil
end

return InstanceStore
