local Plugin = script.Parent.Parent
local Libs = Plugin.Libs
local t = require(Libs.t)
local Utility = require(Plugin.Core.Util.Utility)
local Constants = require(Plugin.Core.Util.Constants)
local TableStore = require(Libs.TableStore)
local InstanceStore = require(Libs.InstanceStore)
local OLD_TableStore = require(Libs.OLD_TableStore)
local OLD_InstanceStore = require(Libs.OLD_InstanceStore)
local semver = require(Libs.semver)

local Selection = game:GetService("Selection")
local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Actions = Plugin.Core.Actions
local SetBrushedParent = require(Actions.SetBrushedParent)
local SetStampedParent = require(Actions.SetStampedParent)
local AddBrushObject = require(Actions.AddBrushObject)
local AddStampObject = require(Actions.AddStampObject)
local SetBrushObjectBrushEnabled = require(Actions.SetBrushObjectBrushEnabled)
local SetStampCurrentlyStamping = require(Actions.SetStampCurrentlyStamping)

local createSignal = require(Plugin.Core.Util.createSignal)

local Brushtool = {}

local function FindOldestBrushedAncestor(current)
	local oldest = nil
	while current ~= nil do
		if CollectionService:HasTag(current, Constants.BRUSHED_TAG) then
			oldest = current
		end
		
		current = current.Parent
	end
	
	return oldest
end

local function FindYoungestBrushedAncestor(current)
	while current ~= nil do
		if CollectionService:HasTag(current, Constants.BRUSHED_TAG) then
			return current
		end
		
		current = current.Parent
	end
	
	return nil
end

function Brushtool:CreateBrushRayFunction()
	local state = self.store:getState()
	local ignoreWater = state.brush.ignoreWater
	local ignoreInvisible = state.brush.ignoreInvisible
	return function(origin, dir, ignoreList)
		local hit, pos, norm
		local goal = origin+dir
		local ignoreList = ignoreList or {}
		local ray = Ray.new(origin, dir)
		repeat
			local hit, pos, norm = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, ignoreWater)
			
			if hit then
				local brushed = FindYoungestBrushedAncestor(hit) ~= nil
				
				if not brushed then
					if not ignoreInvisible then
						return hit, pos, norm
					elseif hit:IsA("Terrain") then
						return hit, pos, norm
					elseif hit.Transparency < 1 then
						return hit, pos, norm
					else
						table.insert(ignoreList, hit)
					end
				else
					table.insert(ignoreList, hit)
				end
			end
			
			origin = pos - dir*0.00001
		until hit == nil
		
		return nil, goal, nil
	end
end

function Brushtool:CreateEraseRayFunction()
	local state = self.store:getState()
	local ignoreWater = state.erase.ignoreWater
	local ignoreInvisible = state.erase.ignoreInvisible
	return function(origin, dir, ignoreList)
		local hit, pos, norm
		local goal = origin+dir
		local ignoreList = ignoreList or {}
		local ray = Ray.new(origin, dir)
		repeat
			local hit, pos, norm = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, ignoreWater)
			
			if hit then
				local brushed = FindYoungestBrushedAncestor(hit) ~= nil
				
				if not brushed then
					if not ignoreInvisible then
						return hit, pos, norm
					elseif hit:IsA("Terrain") then
						return hit, pos, norm
					elseif hit.Transparency < 1 then
						return hit, pos, norm
					else
						table.insert(ignoreList, hit)
					end
				else
					table.insert(ignoreList, hit)
				end
			end
			
			origin = pos - dir*0.00001
		until hit == nil
		
		return nil, goal, nil
	end
end

function Brushtool:CreateStampRayFunction()
	local state = self.store:getState()
	local ignoreWater = state.stamp.ignoreWater
	local ignoreInvisible = state.stamp.ignoreInvisible
	return function(origin, dir, ignoreList)
		local hit, pos, norm
		local goal = origin+dir
		local ignoreList = ignoreList or {}
		local ray = Ray.new(origin, dir)
		repeat
			local hit, pos, norm = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, ignoreWater)
			
			if hit then
				local brushed = FindYoungestBrushedAncestor(hit) ~= nil
				
				if not brushed then
					if not ignoreInvisible then
						return hit, pos, norm
					elseif hit:IsA("Terrain") then
						return hit, pos, norm
					elseif hit.Transparency < 1 then
						return hit, pos, norm
					else
						table.insert(ignoreList, hit)
					end
				else
					table.insert(ignoreList, hit)
				end
			end
			
			origin = pos - dir*0.00001
		until hit == nil
		
		return nil, goal, nil
	end
end

function Brushtool:GetBrushedObjects()
	if self.brushedCache == nil then
		self.brushedCache = CollectionService:GetTagged(Constants.BRUSHED_TAG)
	end
	
	return self.brushedCache
end

function Brushtool.new(store, plugin)
	local self = setmetatable({}, {__index = Brushtool})
	self._signal = createSignal()
	self.store = store
	self.plugin = plugin
	
	self.selection = Selection:Get()
	self.selectionChangedConn = Selection.SelectionChanged:Connect(function()
		self.hasSelectionChanged = true
	end)
	
	self.brushedAddedConn = CollectionService:GetInstanceAddedSignal(Constants.BRUSHED_TAG):Connect(function()
		self.brushedCache = nil
	end)
	
	self.brushedRemovedConn = CollectionService:GetInstanceRemovedSignal(Constants.BRUSHED_TAG):Connect(function()
		self.brushedCache = nil
	end)
	
	self.ready = false
	self.mode = "None"
	self.lastCf = CFrame.new()
	self.cf = nil
	self.norm = nil
	self.hit = nil
	self.active = false
	self.mouse = plugin:GetMouse()
	self.ignoreList = {}
	
	local brushLengthToGo = 0
	local eraseLengthToGo = 0
	self.shouldMarkWaypointForBrush = false
	self.shouldMarkWaypointForErase = false
	self.shouldMarkWaypointForStamp = false
	local lastMustSave = false
	self.hConn = RunService.Heartbeat:Connect(function(dt)
		if not store:getState().stateCopied then return end
		
		if self:MustSave() then
			self.timeToAutosave = self.timeToAutosave - dt
			if self.timeToAutosave < 0 then
				self:Save()
			end
		else
			self.timeToAutosave = Constants.AUTOSAVE_INTERVAL
		end
		
		if lastMustSave ~= self:MustSave() then
			lastMustSave = self:MustSave()
			self._signal:fire()
		end
		
		local castFunc
		if self.mode == "Brush" then
			castFunc = self:CreateBrushRayFunction()
		elseif self.mode == "Erase" then
			castFunc = self:CreateEraseRayFunction()
		else
			castFunc = self:CreateStampRayFunction()	
		end
		local ray = self.mouse.UnitRay
		local origin, direction = ray.Origin, ray.Direction
		local hit, p, norm = castFunc(origin, direction*1000, self:GetBrushedObjects())
		self.hit = hit
		local cf
		if hit then
			cf = CFrame.new(p, p+norm)
		else
			cf = CFrame.new(p)
		end
		
		self.lastCf = self.cf
		self.cf = cf
		self.norm = norm
		
		if hit and self.isMouseDown then
			if self.mode == "Brush" then
				if brushLengthToGo <= 0 then
					local distanceChecks = 0
					
					local brush = store:getState().brush
					brushLengthToGo = brush.radius/4
					local enabledBrushObjects = self:GetEnabledBrushObjects()
					local radius = brush.radius
					local spacing = brush.spacing
					if #enabledBrushObjects > 0 then
						local pointsToSampleCount = math.clamp((math.pi/4) * (2*radius/spacing)^2, 1, Constants.MAX_PLACED_PER_BRUSH)
						
						-- generate offsets for the raycast
						local samplePoints = {}
						local castCf = cf * CFrame.new(0, 0, -radius/2)
						local x, y
						for i = 1, pointsToSampleCount do
							x, y = Utility.RandomCoordsInCircle(radius)
							samplePoints[i] = castCf * Vector3.new(x, y, 0)
						end
						
						-- cast the rays. If they hit, record them.
						local hitEntries = {}
						local castDir = -norm
						for _, sample in next, samplePoints do
							local hit, p, norm = castFunc(sample, castDir*radius)
							if hit then
								table.insert(hitEntries, {p, norm})
							end
						end
						
						local spacingVec = Vector3.new(spacing, spacing, spacing)
						local spacingSquared = spacing*spacing
						local r = Random.new()
						
						local sweptFirstAlready = false
						
						-- collate a bunch of data for each hit entry
						local rbxObjectsToDraw = {}
						local scales = {}
						local cfs = {}
						local centerModes  = {}
						for i = 1, #hitEntries do
							local hitEntry = hitEntries[i]
							local p, norm = hitEntry[1], hitEntry[2]
							local object = enabledBrushObjects[math.random(#enabledBrushObjects)]
							local rbxObject = object.rbxObject
							local size = object.size
							local verticalOffset do
								local mode = object.verticalOffset.mode
								if mode == "Auto" then
									if object.brushCenterMode == "BoundingBox" then
										verticalOffset = object.size.y/2
									else
										local primaryPart = rbxObject.PrimaryPart
										local min, max = Utility.GetPartAABB(primaryPart)
										verticalOffset = (max-min).y/2
									end
								elseif mode == "Fixed" then
									verticalOffset = object.verticalOffset.fixed
								else
									verticalOffset = r:NextNumber(object.verticalOffset.min, object.verticalOffset.max)
								end
							end 
							
							local scale do
								if object.scale.mode ~= "NoOverride" then
									local mode = object.scale.mode
									if mode == "None" then
										scale = 1
									elseif mode == "Fixed" then
										scale = object.scale.fixed
									else
										scale = r:NextNumber(object.scale.min, object.scale.max)
									end
								else
									local mode = brush.scale.mode
									if mode == "None" then
										scale = 1
									elseif mode == "Fixed" then
										scale = brush.scale.fixed
									else
										scale = r:NextNumber(brush.scale.min, brush.scale.max)
									end
								end
							end
							
							local orientation do
								if object.orientation.mode ~= "NoOverride" then
									local mode = object.orientation.mode
									if mode == "Normal" then
										orientation = norm
									elseif mode == "Up" then
										orientation = Vector3.new(0, 1, 0)
									else
										orientation = object.orientation.custom.unit
									end
								else
									local mode = brush.orientation.mode
									if mode == "Normal" then
										orientation = norm
									elseif mode == "Up" then
										orientation = Vector3.new(0, 1, 0)
									else
										orientation = brush.orientation.custom.unit
									end
								end
							end
							verticalOffset = verticalOffset*scale
							
							local rotation
							if object.rotation.mode ~= "NoOverride" then
								local mode = object.rotation.mode
								if mode == "None" then
									rotation = 0
								elseif mode == "Fixed" then
									rotation = object.rotation.fixed
								else
									rotation = r:NextNumber(object.rotation.min, object.rotation.max)
								end
							else
								local mode = brush.rotation.mode
								if mode == "None" then
									rotation = 0
								elseif mode == "Fixed" then
									rotation = brush.rotation.fixed
								else
									rotation = r:NextNumber(brush.rotation.min, brush.rotation.max)
								end
							end
							
							local wobble
							if object.wobble.mode ~= "NoOverride" then
								local mode = object.wobble.mode
								if mode == "None" then
									wobble = 0
								else
									wobble = r:NextNumber(object.wobble.min, object.wobble.max)
								end
							else
								local mode = brush.wobble.mode
								if mode == "None" then
									wobble = 0
								else
									wobble = r:NextNumber(brush.wobble.min, brush.wobble.max)
								end
							end
							
							do
								if wobble ~= 0 then
									local orientationCf do
										if math.abs(orientation.X) ~= 1 then
											orientationCf = Utility.CFrameFromTopRight(Vector3.new(), orientation, Vector3.new(1, 0, 0))
										else
											orientationCf = Utility.CFrameFromTopRight(Vector3.new(), orientation, Vector3.new(0, 0, 1))	
										end
									end
									orientationCf = orientationCf * CFrame.Angles(0, r:NextNumber(0, math.pi*2), 0) * CFrame.Angles(math.rad(wobble), 0, 0)
									orientation = orientationCf.upVector.unit
								end
							end
							
							local finalP = p+orientation*verticalOffset
							local finalCf
							if orientation ~= Vector3.new(1, 0, 0) and orientation ~= Vector3.new(-1, 0, 0)  then
								finalCf = Utility.CFrameFromTopRight(
									finalP,
									orientation,
									Utility.ProjectVectorToPlane(Vector3.new(1, 0, 0), orientation)
								) * CFrame.Angles(0, math.rad(rotation), 0)
							else
								finalCf = Utility.CFrameFromTopRight(
									finalP,
									orientation,
									Utility.ProjectVectorToPlane(Vector3.new(0, 0, 1).unit, orientation)
								) * CFrame.Angles(0, math.rad(rotation), 0)
							end
							
							rbxObjectsToDraw[i] = rbxObject
							cfs[i] = finalCf
							scales[i] = scale
							centerModes[i] = object.brushCenterMode
						end
						
						local brushedAncestorSet = {}
						local ignoreList = {}
						local centerCache = {}
						local destinedToFail = {}
						local sweptFirstAlready = false
						for i = 1, #hitEntries do
							if not destinedToFail[i] then
								local finalCf = cfs[i]
								local up = finalCf.upVector
								local p = finalCf.p
								
								local region = Region3.new(
									p-spacingVec, 
									p+spacingVec
								)
								
								-- first sweep: find as many parts that we're sure are descendants of (or are themselves) brushed
								local firstSweep
								if not sweptFirstAlready then
									sweptFirstAlready = true
									local firstSweep = workspace:FindPartsInRegion3WithWhiteList(
										region, 
										self:GetBrushedObjects(),
										100
									)
									-- reduce this list to only their oldest brushed ancestors
									for _, v in next, firstSweep do
										local alreadyAncestorFound = false
										local current = v
										while current ~= nil do
											if brushedAncestorSet[current] then
												alreadyAncestorFound = true
												break
											end
											
											current = current.Parent
										end
										
										if not alreadyAncestorFound then
											local oldestBrushedAncestor = FindOldestBrushedAncestor(v)
											if oldestBrushedAncestor then
												table.insert(ignoreList, oldestBrushedAncestor)
												-- nil index can apparently happen at this line? hmm...
												brushedAncestorSet[oldestBrushedAncestor] = true
												
												local brushed = oldestBrushedAncestor
												local center = centerCache[brushed]
												if not center then
													if brushed.ClassName == "Model" then
														if CollectionService:HasTag(brushed, Constants.BRUSHED_PP_AS_CENTER_TAG) and brushed.PrimaryPart then
															center = brushed.PrimaryPart.Position
														else
															local min, max = Utility.GetModelAABBFast(brushed)
															center = (min+max)/2
														end
													elseif brushed:IsA("BasePart") and not brushed:IsA("Terrain") then
														center = brushed.Position
													end
													centerCache[brushed] = center
												end
												
												for testIdx = i, #cfs do
													local cf = cfs[testIdx]
													if not destinedToFail[testIdx] then
														local projectedP = Utility.ProjectPointToPlane(cf.p, center, cf.upVector)
														local distance = (projectedP-center).magnitude
														if distance < spacing then
															destinedToFail[testIdx] = true
--															print(string.format("earlyFail %d, %d", i, testIdx))
														end
														distanceChecks = distanceChecks+1
													end
												end
											else
												table.insert(ignoreList, v)
											end
										end
									end
								end
								
								-- if we reached the limit of the first sweep then perform another sweep
								local nothingLeft = false
								if firstSweep and #firstSweep >= 100 or sweptFirstAlready then
									repeat				
										-- This time we'll be using an ignore list instead of a whitelist.
										-- The ignore list if composed of:
										--  Brushed ancestors
										--  Parts that aren't brushed
										-- This list grows every sweep
										local newSweep = workspace:FindPartsInRegion3WithIgnoreList(
											region, 
											ignoreList,
											100
										)
										
										for _, v in next, newSweep do
											local alreadyAncestorFound = false
											local current = v
											while current ~= nil do
												if brushedAncestorSet[current] then
													alreadyAncestorFound = true
													break
												end
												
												current = current.Parent
											end
											
											if not alreadyAncestorFound then
												local oldestBrushedAncestor = FindOldestBrushedAncestor(v)
												if oldestBrushedAncestor then
													brushedAncestorSet[oldestBrushedAncestor] = true
													table.insert(ignoreList, oldestBrushedAncestor)
													
													local brushed = oldestBrushedAncestor
													local center = centerCache[brushed]
													if not center then
														if brushed.ClassName == "Model" then
															if CollectionService:HasTag(brushed, Constants.BRUSHED_PP_AS_CENTER_TAG) and brushed.PrimaryPart then
																center = brushed.PrimaryPart.Position
															else
																local min, max = Utility.GetModelAABBFast(brushed)
																center = (min+max)/2
															end
														elseif brushed:IsA("BasePart") and not brushed:IsA("Terrain") then
															center = brushed.Position
														end
														centerCache[brushed] = center
													end
															
													for testIdx = i, #cfs do
														local cf = cfs[testIdx]
														if not destinedToFail[testIdx] then
															local projectedP = Utility.ProjectPointToPlane(cf.p, center, cf.upVector)
															local distance = (projectedP-center).magnitude
															if distance < spacing then
																destinedToFail[testIdx] = true
--																print(string.format("lateFail %d, %d", i, testIdx))
															end
															distanceChecks = distanceChecks+1
														end
													end
												else
													table.insert(ignoreList, v)
												end
											end
										end
										nothingLeft = #newSweep < 100
										
									-- keep sweeping until we can't find any more parts
									until nothingLeft
								end
																	
								if not destinedToFail[i] then
									if not self.shouldMarkWaypointForBrush then
										self.shouldMarkWaypointForBrush = true
										ChangeHistoryService:SetWaypoint("Brushed")
									end
									local rbxObject = rbxObjectsToDraw[i]
									local clone = rbxObject:Clone()
									
									local tempModel = Instance.new("Model")
									clone.Parent = tempModel
									local wrapper = Instance.new("Part")
									
									local brushCenterMode = centerModes[i]
									local center
									if clone:IsA("BasePart") then
										center = clone.Position
									else
										if brushCenterMode == "BoundingBox" then
											local min, max = Utility.GetModelAABBFast(clone)
											center = (max+min)/2
										else
											center = clone.PrimaryPart.Position
										end
									end
																	
									wrapper.CFrame = CFrame.new(center)
									wrapper.Parent = tempModel
									tempModel.PrimaryPart = wrapper
									clone.Parent = tempModel
									
									tempModel:SetPrimaryPartCFrame(CFrame.new())
									
									-- scale model
									local scale = scales[i]
									if scale ~= 1 then
										for _, v in next, tempModel:GetDescendants() do
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
											elseif v:IsA("Attachment") then
												v.Position = v.Position*scale
											end
										end
									end
									
									tempModel:SetPrimaryPartCFrame(finalCf)
									
									CollectionService:AddTag(clone, Constants.BRUSHED_TAG)
									if brushCenterMode == "PrimaryPart" then
										CollectionService:AddTag(clone, Constants.BRUSHED_PP_AS_CENTER_TAG)
									end
									clone.Parent = brush.brushedParent
									table.insert(ignoreList, clone) -- Add the clone to the ignore list since we know it was brushed.
									tempModel:Destroy()
									wrapper:Destroy()
									
									for testIdx = i+1, #cfs do
										if not destinedToFail[testIdx] then
											local cf = cfs[testIdx]
											local projectedP = Utility.ProjectPointToPlane(cf.p, finalCf.p, cf.upVector)
											local distance = (projectedP-finalCf.p).magnitude
											if distance < spacing then
												destinedToFail[testIdx] = true
--												print(string.format("veryLateFail %d, %d", i, testIdx))
											end
											distanceChecks = distanceChecks+1
										end
									end
								end
							end
						end
					end
					
--					print(distanceChecks)
				else
					if self.cf and self.lastCf  then
						local dist = (self.cf.p - self.lastCf.p).magnitude
						brushLengthToGo = brushLengthToGo - dist
					end
				end
			elseif self.mode == "Erase" then
				if eraseLengthToGo <= 0 then
					local erase = store:getState().erase
					eraseLengthToGo = erase.radius/4
					-- first sweep: find as many parts that we're sure are descendants of (or are themselves) brushed
					
					local ignoreList = {}
					local brushedAncestors = {}
					local radius = erase.radius
					local radiusVec = Vector3.new(radius, radius, radius)
					local region = Region3.new(
						p-radiusVec, 
						p+radiusVec
					)
					local firstSweep = workspace:FindPartsInRegion3WithWhiteList(
						region, 
						self:GetBrushedObjects(),
						100
					)
					-- reduce this list to only their oldest brushed ancestors
					for _, v in next, firstSweep do
						local alreadyAncestorFound = false
						for _, ancestor in next, brushedAncestors do
							if v:IsDescendantOf(ancestor) then
								alreadyAncestorFound = true
								break
							end
						end
						
						if not alreadyAncestorFound then
							local oldestBrushedAncestor = FindOldestBrushedAncestor(v)
							table.insert(brushedAncestors, oldestBrushedAncestor)
						end
					end
						
					for _, v in next, brushedAncestors do
						table.insert(ignoreList, v)
					end
					
					-- if we reached the limit of the first sweep then perform another sweep
					local nothingLeft = false
					if #firstSweep >= 100 then
						repeat
							local emptyFast = workspace:IsRegion3EmptyWithIgnoreList(
								region,
								ignoreList
							)
							
							if emptyFast then
								nothingLeft = true
							else				
								-- This time we'll be using an ignore list instead of a whitelist.
								-- The ignore list if composed of:
								--  Brushed ancestors
								--  Parts that aren't brushed
								-- This list grows every sweep
								local newSweep = workspace:FindPartsInRegion3WithIgnoreList(
									region, 
									ignoreList,
									100
								)
								
								for _, v in next, newSweep do
									local alreadyAncestorFound = false
									for _, ancestor in next, brushedAncestors do
										if v:IsDescendantOf(ancestor) then
											alreadyAncestorFound = true
											break
										end
									end
									
									if not alreadyAncestorFound then
										local oldestBrushedAncestor = FindOldestBrushedAncestor(v)
										if oldestBrushedAncestor then
											table.insert(brushedAncestors, oldestBrushedAncestor)
											table.insert(ignoreList, oldestBrushedAncestor)
										else
											table.insert(ignoreList, v)
										end
									end
								end
								
								nothingLeft = #newSweep < 100
							end
						-- keep sweeping until we can't find any more parts
						until nothingLeft
					end
					-- very dumb hack to prevent performance from degrading very
					-- badly if something that is selected was erased.
					-- When the selection changes after something was erased, this
					-- means that the thing that was erased was part of the selection.
					-- Immediately deselect everything. After being done with erasing
					-- stuff, re-set the selection to the old selection, sans the things
					-- that were erased.
					local oldSelection = Selection:Get()
					local selectionChanged = false
					local changeListener = Selection.SelectionChanged:Connect(function()
						selectionChanged = true
					end)
					local selectionNulled = false
					local deletedSet = {}
					for _, brushed in next, brushedAncestors do
						local center
						if brushed.ClassName == "Model" then
							if CollectionService:HasTag(brushed, Constants.BRUSHED_PP_AS_CENTER_TAG) and brushed.PrimaryPart then
								center = brushed.PrimaryPart.Position
							else
								local min, max = Utility.GetModelAABBFast(brushed)
								center = (min+max)/2
							end
						elseif brushed:IsA("BasePart") and not brushed:IsA("Terrain") then
							center = brushed.Position
						end
						
						-- project the brush point so that it's level with the center
						-- This is to account for tall objects.
						local projectedP = Utility.ProjectPointToPlane(p, center, norm)
						local distance = (projectedP-center).magnitude
						if distance < radius then
							if not self.shouldMarkWaypointForErase then
								self.shouldMarkWaypointForErase = true
								ChangeHistoryService:SetWaypoint("Erased")
							end
							brushed.Parent = nil
							if not selectionNulled and selectionChanged then
								selectionNulled = true
								Selection:Set({})
							end
							deletedSet[brushed] = true
						end
					end
					
					changeListener:Disconnect()
					
					-- recostruct selection
					if selectionNulled then
						local newSelection = {}
						local i = 1
						for _, v in next, oldSelection do
							if deletedSet[v] == nil then
								newSelection[i] = v
								i = i+1
							end
						end
						
						if #newSelection ~= #oldSelection then
							Selection:Set(newSelection)
						end
					end
					
				else
					if self.cf and self.lastCf  then
						local dist = (self.cf.p - self.lastCf.p).magnitude
						eraseLengthToGo = eraseLengthToGo - dist
					end
				end
			end
		end
		
		if self.hasSelectionChanged then
			self.hasSelectionChanged = false
			self.selection = Selection:Get()
			self._signal:fire()
		end
	end)
	
	self.isMouseDown = false
	self.timeToAutosave = Constants.AUTOSAVE_INTERVAL
	
	self.mouseDownConn = self.mouse.Button1Down:Connect(function()
		self.isMouseDown = true
		self.mouseDownHit = self.hit
		self.mouseDownCf = self.cf
		self.mouseDownNorm = self.norm
	end)
	
	self.mouseUpConn = self.mouse.Button1Up:Connect(function()
		local r = Random.new()
		local state = store:getState()
		local stamp = state.stamp
		local currentlyStamping = stamp.currentlyStamping
		local stampObjects = state.stampObjects
		local object = stampObjects[currentlyStamping]
		if object and
			self.mode == "Stamp" and 
			( 
				(object.rotation.mode == "ClickAndDrag" and self.mouseDownHit) or
				(self.hit)
			) then
			
			local rotationMode = object.rotation.mode
			local cf, norm do
				if rotationMode == "ClickAndDrag" then
					if self.mouseDownHit then
						cf = self.mouseDownCf
						norm = self.mouseDownNorm
					else
						cf = self.cf
						norm = self.norm
					end
				else
					cf = self.cf
					norm = self.norm
				end
			end
			local p = cf.p
			local rbxObject = object.rbxObject
			local size = object.size
			local rotationMode = object.rotation.mode
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
			
						
			local objectWobble = object.wobble
			local wobble do
				local mode = objectWobble.mode
				if mode == "None" then
					wobble = 0
				else
					wobble = r:NextNumber(objectWobble.min, objectWobble.max)
				end
			end
			
			do
				if wobble ~= 0 then
					local orientationCf do
						if math.abs(orientation.X) ~= 1 then
							orientationCf = Utility.CFrameFromTopRight(Vector3.new(), orientation, Vector3.new(1, 0, 0))
						else
							orientationCf = Utility.CFrameFromTopRight(Vector3.new(), orientation, Vector3.new(0, 0, 1))	
						end
					end
					orientationCf = orientationCf * CFrame.Angles(0, r:NextNumber(0, math.pi*2), 0) * CFrame.Angles(math.rad(wobble), 0, 0)
					orientation = orientationCf.upVector.unit
				end
			end
			
			local objectRotation = object.rotation
			local rotation do
				local mode = objectRotation.mode
				if mode == "ClickAndDrag" then
					if self.mouseDownHit then
						local delta = self.mouseDownCf.p - self.cf.p
						if delta.magnitude == 0 then
							rotation = 0
						else
							delta = delta.unit
							if math.abs(orientation.x) ~= 1 then
								rotation = Utility.GetAngleBetweenVectorsSigned(Vector3.new(1, 0, 0), delta, orientation)
								rotation = math.deg(rotation) - 90
							else
								rotation = Utility.GetAngleBetweenVectorsSigned(Vector3.new(0, 0, 1).unit, delta, orientation)
								rotation = math.deg(rotation) - 90	
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
					rotation = r:NextNumber(objectRotation.min, objectRotation.max)
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
					scale = r:NextNumber(objectScale.min, objectScale.max)
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
					verticalOffset = r:NextNumber(objectVerticalOffset.min, objectVerticalOffset.max)
				end
			end 
			
			if not self.shouldMarkWaypointForStamp then
				self.shouldMarkWaypointForStamp = true
				ChangeHistoryService:SetWaypoint("Stamped")
			end
						
			local clone = object.rbxObject:Clone()
			local finalP = p+orientation*verticalOffset*scale
			
			local tempModel = Instance.new("Model")
			clone.Parent = tempModel
			local wrapper = Instance.new("Part")
			wrapper.Size = size
			
			local center
			if clone:IsA("BasePart") then
				center = clone.Position
			else
				if object.stampCenterMode == "BoundingBox" then
					local min, max = Utility.GetModelAABBFast(clone)
					center = (max+min)/2
				else
					center = clone.PrimaryPart.Position
				end
			end
			
			wrapper.CFrame = CFrame.new(center)
			tempModel.PrimaryPart = wrapper
			
			tempModel:SetPrimaryPartCFrame(CFrame.new())
			
			if scale ~= 1 then
				for _, v in next, tempModel:GetDescendants() do
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
					elseif v:IsA("Attachment") then
						v.Position = v.Position*scale
					end
				end
			end
			
			local finalCf
			if orientation ~= Vector3.new(1, 0, 0) and orientation ~= Vector3.new(-1, 0, 0) then
				finalCf = Utility.CFrameFromTopRight(
					finalP,
					orientation,
					Utility.ProjectVectorToPlane(Vector3.new(1, 0, 0), orientation)
				) * CFrame.Angles(0, math.rad(rotation), 0)
			else
				finalCf = Utility.CFrameFromTopRight(
					finalP,
					orientation,
					Utility.ProjectVectorToPlane(Vector3.new(0, 0, 1).unit, orientation)
				) * CFrame.Angles(0, math.rad(rotation), 0)
			end
			
			tempModel:SetPrimaryPartCFrame(finalCf)
			
			CollectionService:AddTag(clone, Constants.BRUSHED_TAG)
			if object.brushCenterMode == "PrimaryPart" then
				CollectionService:AddTag(clone, Constants.BRUSHED_PP_AS_CENTER_TAG)
			end
			clone.Parent = stamp.stampedParent
			tempModel:Destroy()
			wrapper:Destroy()
		end
		
		brushLengthToGo = 0
		eraseLengthToGo = 0
		self.isMouseDown = false
		self:MarkNecessaryWaypoints()
	end)
	
	self.deactivationConn = plugin.Deactivation:Connect(function()
		self.mode = "None"
		self._signal:fire()
	end)
	
	-- On undo or redo, studio selects parts that were added/removed (for whatever reason...)
	-- This can cause a large amount of brushed parts to suddently get selected, which can
	-- lock up studio. So forcibly un-select everything when we undo/redo an action.
	self.undoConn = ChangeHistoryService.OnUndo:Connect(function(wp)
		if wp == "Brushed" or wp == "Erased" then
			Selection:Set({})
		elseif wp == "ClearTags" then
			self._signal:fire()
		end
	end)
	
	self.redoConn = ChangeHistoryService.OnRedo:Connect(function(wp)
		if wp == "Brushed" or wp == "Erased" then
			Selection:Set({})
		elseif wp == "ClearTags" then
			self._signal:fire()
		end
	end)
	
	return self
end

function Brushtool:subscribe(...)
	return self._signal:subscribe(...)
end

function Brushtool:GetEnabledBrushObjects()
	local enabled = {}
	local state = self.store:getState()
	for guid, object in next, state.brushObjects do
		if object.brushEnabled then
			table.insert(enabled, object)
		end
	end
	
	return enabled
end

function Brushtool:GetStorePrefix()
	local prefix
	local localPlayer = game.Players.LocalPlayer
	if localPlayer then
		prefix = tostring(localPlayer.UserId) .. "_"
	else
		prefix = "SOLO_"		
	end
	
	return prefix
end

function Brushtool:_loadStoredState()
	local initialState = {
		brush = {
			selected = "",
			filter = "",
			radius = 16,
			spacing = 8,
			ignoreWater = false,
			ignoreInvisible = false,
			rotation = {
				mode = "None",
				fixed = 0,
				min = 0,
				max = 360
			},
			scale = {
				mode = "None",
				fixed = 1,
				min = 1,
				max = 2
			},
			wobble = {
				mode = "None",
				min = 0,
				max = 30
			},
			orientation = {
				mode  = "Normal",
				custom = Vector3.new(0, 1, 0)
			},
			brushedParent = workspace
		},
		brushObjects = {},
		stamp = {
			currentlyStamping = "",
			deleting = "",
			filter = "",
			ignoreWater = false,
			ignoreInvisible = false,
			stampedParent = workspace
		},
		stampObjects = {},
		erase = {
			radius = 16,
			ignoreWater = false,
			ignoreInvisible = false
		}
	}
	
	local prefix = self:GetStorePrefix()
	self.brushObjectsStore = InstanceStore.new(Constants.PLUGIN_STORAGE_SCOPE, prefix .. "BrushtoolBrushObjects")
	self.stampObjectsStore = InstanceStore.new(Constants.PLUGIN_STORAGE_SCOPE, prefix .. "BrushtoolStampObjects")
	self.referenceStore = InstanceStore.new(Constants.PLUGIN_STORAGE_SCOPE, prefix .. "BrushtoolReferences")
	self.tableStore = TableStore.new(Constants.PLUGIN_STORAGE_SCOPE, prefix .. "BrushtoolTable")
	
	local brushState = initialState.brush do
		(function()
			local storedBrush = self.tableStore:ReadTable("brush")
			if storedBrush == nil then
				return
			end
			
			local radius = storedBrush.radius
			local spacing = storedBrush.spacing
			local ignoreWater = storedBrush.ignoreWater
			local ignoreInvisible = storedBrush.ignoreInvisible
			local rotation = storedBrush.rotation
			local scale = storedBrush.scale
			local wobble = storedBrush.wobble
			local orientation = storedBrush.orientation
			
			if t.numberConstrained(Constants.MIN_RADIUS, Constants.MAX_RADIUS)(radius) then
				brushState.radius = radius
			end
			
			if t.numberConstrained(Constants.MIN_SPACING, Constants.MAX_SPACING)(spacing) then
				brushState.spacing = spacing
			end
			
			if t.boolean(ignoreWater) then
				brushState.ignoreWater = ignoreWater
			end
			
			if t.boolean(ignoreInvisible) then
				brushState.ignoreInvisible = ignoreInvisible
			end
			
			local rotInterface = t.strictInterface{
				mode = t.union(t.literal"None", t.literal"Random", t.literal"Fixed"),
				fixed = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
				min = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
				max = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION)
			}
			
			local scaleInterface = t.strictInterface{
				mode = t.union(t.literal"None", t.literal"Random", t.literal"Fixed"),
				fixed = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
				min = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
				max = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE)
			}
			
			local wobbleInterface = t.strictInterface{
				mode = t.union(t.literal"None", t.literal"Random"),
				min = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE),
				max = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE)
			}
			
			local orientationInterface = t.strictInterface{
				mode = t.union(t.literal"Normal", t.literal"Up", t.literal"Custom"),
				custom = t.interface{ x = t.number, y = t.number, z = t.number },
			}
			
			if rotInterface(rotation) and rotation.min <= rotation.max then
				brushState.rotation = rotation
			end
			
			if scaleInterface(scale) and scale.min <= scale.max then
				brushState.scale = scale
			end
			
			if wobbleInterface(wobble) and wobble.min <= wobble.max then
				brushState.wobble = wobble
			end
			
			if orientationInterface(orientation) and (orientation.custom.x ~= 0 or orientation.custom.y ~= 0 or orientation.custom.z ~= 0) then
				brushState.orientation = {
					mode = orientation.mode,
					custom = Vector3.new(orientation.custom.x, orientation.custom.y, orientation.custom.z)
				}
			end
			
			local brushedParentRefObject = self.referenceStore:ReadInstance("brushedParent")
			if brushedParentRefObject ~= nil and 
				brushedParentRefObject:IsA("ObjectValue") and 
				brushedParentRefObject.Archivable == true and 
				brushedParentRefObject.Value ~= nil and
				brushedParentRefObject.Value:IsDescendantOf(workspace) then
				brushState.brushedParent = brushedParentRefObject.Value
			end
		end)()
	end
	
	local brushObjectsState = initialState.brushObjects do
		(function()
			local storedObjects = self.tableStore:ReadTable("brushObjects")
			if storedObjects == nil then
				return
			end
			
			for guid, objectDecoded in next, storedObjects do
				if t.string(guid) then
					local rbxObject = self.brushObjectsStore:ReadInstance(guid)
					if rbxObject and self:IsValidBrushCandidate(rbxObject) then
						local newEntry = {
							rbxObject = rbxObject:Clone(),
							-- attempt at adding sub-seconds.
							-- Objects may be added in the same second.
							-- This can mess up ordering later on.
							name = rbxObject.Name,
							-- warning: models with 0 parts will return an invalid size.
							-- make sure beforehand that all models have at least one part!
							size = (function()
								if rbxObject:IsA("Model") then
									local min, max = Utility.GetModelAABBFast(rbxObject) 
									local size =(max-min)
									return size
								else
									local min, max = Utility.GetPartAABB(rbxObject) 
									local size =(max-min)
									return size
								end
							end)(), 
							timeAdded = os.time(os.date("!*t")) + tick()%1, 
							brushEnabled = true,
							brushCenterMode = "BoundingBox",
							rotation = {
								mode = "NoOverride",
								fixed = 0,
								min = 0,
								max = 360
							},
							scale = {
								mode = "NoOverride",
								fixed = 1,
								min = 1,
								max = 2
							},
							wobble = {
								mode = "NoOverride",
								min = 0,
								max = 30
							},
							verticalOffset = {
								mode = "Auto",
								fixed = 0,
								min = 0,
								max = 1
							},
							orientation = {
								mode  = "NoOverride",
								custom = Vector3.new(0, 1, 0)
							}
						}
						
						local timeAdded = objectDecoded.timeAdded
						local brushEnabled = objectDecoded.brushEnabled
						local brushCenterMode = objectDecoded.brushCenterMode
						local rotation = objectDecoded.rotation
						local scale = objectDecoded.scale
						local wobble = objectDecoded.wobble
						local verticalOffset = objectDecoded.verticalOffset
						local orientation = objectDecoded.orientation
						
						if t.number(timeAdded) then
							newEntry.timeAdded = timeAdded
						end
						
						-- brushEnabled may only be a boolean
						if t.boolean(brushEnabled) then
							newEntry.brushEnabled = brushEnabled
						end
						
						-- make sure that brushCenterMode is valid
						if t.union(t.literal("BoundingBox"), t.literal("PrimaryPart"))(brushCenterMode) then
							-- and if it's a model
							if rbxObject:IsA("Model") then
								-- and that if it has a primary part, then allow either value
								if rbxObject.PrimaryPart ~= nil then
									newEntry.brushCenterMode = brushCenterMode
								else
									-- otherwise, it can't use PrimaryPart center mode.
									if brushCenterMode ~= "PrimaryPart" then
										newEntry.brushCenterMode = brushCenterMode
									end
								end
							else
								-- and if it's a part, then it can only use the bounding box
								if brushCenterMode == "BoundingBox" then
									newEntry.brushCenterMode = "BoundingBox"
								end
							end
						end
								
						local rotInterface = t.strictInterface{
							mode = t.union(t.literal"NoOverride", t.literal"None", t.literal"Random", t.literal"Fixed"),
							fixed = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
							min = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
							max = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION)
						}
						
						local scaleInterface = t.strictInterface{
							mode = t.union(t.literal"NoOverride", t.literal"None", t.literal"Random", t.literal"Fixed"),
							fixed = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
							min = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
							max = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE)
						}
						
						local wobbleInterface = t.strictInterface{
							mode = t.union(t.literal"NoOverride", t.literal"None", t.literal"Random"),
							min = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE),
							max = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE)
						}
						
						local verticalOffsetInterface = t.strictInterface{
							mode = t.union(t.literal"Auto", t.literal"Random", t.literal"Fixed"),
							fixed = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
							min = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
							max = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET)
						}
						
						local orientationInterface = t.strictInterface{
							mode = t.union(t.literal"NoOverride", t.literal"Normal", t.literal"Up", t.literal"Custom"),
							custom = t.interface{ x = t.number, y = t.number, z = t.number },
						}
						
						if rotInterface(rotation) and rotation.min <= rotation.max then
							newEntry.rotation = rotation
						end
						
						if scaleInterface(scale) and scale.min <= scale.max then
							newEntry.scale = scale
						end
						
						if wobbleInterface(wobble) and wobble.min <= wobble.max then
							newEntry.wobble = wobble
						end
						
						if verticalOffsetInterface(verticalOffset) and verticalOffset.min <= verticalOffset.max then
							newEntry.verticalOffset = verticalOffset
						end
						
						if orientationInterface(orientation) and (orientation.custom.x ~= 0 or orientation.custom.y ~= 0 or orientation.custom.z ~= 0) then
							newEntry.orientation = {
								mode = orientation.mode,
								custom = Vector3.new(orientation.custom.x, orientation.custom.y, orientation.custom.z)
							}
						end
						
						brushObjectsState[guid] = newEntry
					end
				end
			end
		end)()
	end

	local stampState = initialState.stamp do
		(function()
			local storedStamp = self.tableStore:ReadTable("stamp")
			if storedStamp == nil then
				return
			end
			
			local ignoreWater = storedStamp.ignoreWater
			local ignoreInvisible = storedStamp.ignoreInvisible
			local currentlyStamping = storedStamp.currentlyStamping
			
			if t.boolean(ignoreWater) then
				stampState.ignoreWater = ignoreWater
			end
			
			if t.boolean(ignoreInvisible) then
				stampState.ignoreInvisible = ignoreInvisible
			end
			
			local stampedParentRefObject = self.referenceStore:ReadInstance("stampedParent")
			if stampedParentRefObject ~= nil and 
				stampedParentRefObject:IsA("ObjectValue") and 
				stampedParentRefObject.Archivable == true and 
				stampedParentRefObject.Value ~= nil and
				stampedParentRefObject.Value:IsDescendantOf(workspace) then
				stampState.stampedParent = stampedParentRefObject.Value
			end
			
			if t.string(currentlyStamping) then
				stampState.currentlyStamping = currentlyStamping
			end
		end)()
	end
	
	local stampObjectsState = initialState.stampObjects do
		(function()
			local storedObjects = self.tableStore:ReadTable("stampObjects")
			if storedObjects == nil then
				return
			end
			
			for guid, objectDecoded in next, storedObjects do
				if t.string(guid) then
					local rbxObject = self.stampObjectsStore:ReadInstance(guid)
					if rbxObject and self:IsValidStampCandidate(rbxObject) then
						local newEntry = {
							rbxObject = rbxObject:Clone(),
							-- attempt at adding sub-seconds.
							-- Objects may be added in the same second.
							-- This can mess up ordering later on.
							name = rbxObject.Name,
							-- warning: models with 0 parts will return an invalid size.
							-- make sure beforehand that all models have at least one part!
							size = (function()
								if rbxObject:IsA("Model") then
									local min, max = Utility.GetModelAABBFast(rbxObject) 
									local size =(max-min)
									return size
								else
									local min, max = Utility.GetPartAABB(rbxObject) 
									local size =(max-min)
									return size
								end
							end)(), 
							timeAdded = os.time(os.date("!*t")) + tick()%1, 
							stampCenterMode = "BoundingBox",
							rotation = {
								mode = "None",
								fixed = 0,
								min = 0,
								max = 360
							},
							scale = {
								mode = "None",
								fixed = 1,
								min = 1,
								max = 2
							},
							wobble = {
								mode = "None",
								min = 0,
								max = 30
							},
							verticalOffset = {
								mode = "Auto",
								fixed = 0,
								min = 0,
								max = 1
							},
							orientation = {
								mode  = "Normal",
								custom = Vector3.new(0, 1, 0)
							}
						}
						
						local timeAdded = objectDecoded.timeAdded
						local stampCenterMode = objectDecoded.stampCenterMode
						local rotation = objectDecoded.rotation
						local scale = objectDecoded.scale
						local wobble = objectDecoded.wobble
						local verticalOffset = objectDecoded.verticalOffset
						local orientation = objectDecoded.orientation
						
						if t.number(timeAdded) then
							newEntry.timeAdded = timeAdded
						end
						
						-- make sure that stampCenterMode is valid
						if t.union(t.literal("BoundingBox"), t.literal("PrimaryPart"))(stampCenterMode) then
							-- and if it's a model
							if rbxObject:IsA("Model") then
								-- and that if it has a primary part, then allow either value
								if rbxObject.PrimaryPart ~= nil then
									newEntry.stampCenterMode = stampCenterMode
								else
									-- otherwise, it can't use PrimaryPart center mode.
									if stampCenterMode ~= "PrimaryPart" then
										newEntry.stampCenterMode = stampCenterMode
									end
								end
							else
								-- and if it's a part, then it can only use the bounding box
								if stampCenterMode == "BoundingBox" then
									newEntry.stampCenterMode = "BoundingBox"
								end
							end
						end
								
						local rotInterface = t.strictInterface{
							mode = t.union(t.literal"None", t.literal"ClickAndDrag", t.literal"Random", t.literal"Fixed"),
							fixed = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
							min = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
							max = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION)
						}
						
						local scaleInterface = t.strictInterface{
							mode = t.union(t.literal"None", t.literal"Random", t.literal"Fixed"),
							fixed = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
							min = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
							max = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE)
						}
						
						local wobbleInterface = t.strictInterface{
							mode = t.union(t.literal"None", t.literal"Random"),
							min = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE),
							max = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE)
						}
						
						local verticalOffsetInterface = t.strictInterface{
							mode = t.union(t.literal"Auto", t.literal"Random", t.literal"Fixed"),
							fixed = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
							min = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
							max = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET)
						}
						
						local orientationInterface = t.strictInterface{
							mode = t.union(t.literal"Normal", t.literal"Up", t.literal"Custom"),
							custom = t.interface{ x = t.number, y = t.number, z = t.number },
						}
						
						if rotInterface(rotation) and rotation.min <= rotation.max then
							newEntry.rotation = rotation
						end
						
						if scaleInterface(scale) and scale.min <= scale.max then
							newEntry.scale = scale
						end
						
						if wobbleInterface(wobble) and wobble.min <= wobble.max then
							newEntry.wobble = wobble
						end
						
						if verticalOffsetInterface(verticalOffset) and verticalOffset.min <= verticalOffset.max then
							newEntry.verticalOffset = verticalOffset
						end
						
						if orientationInterface(orientation) and (orientation.custom.x ~= 0 or orientation.custom.y ~= 0 or orientation.custom.z ~= 0) then
							newEntry.orientation = {
								mode = orientation.mode,
								custom = Vector3.new(orientation.custom.x, orientation.custom.y, orientation.custom.z)
							}
						end
						
						stampObjectsState[guid] = newEntry
					end
				end
			end
		end)()
	end

	local eraseState = initialState.erase do
		(function()
			local storedErase = self.tableStore:ReadTable("erase")
			if storedErase == nil then
				return
			end
			
			local radius = storedErase.radius
			local ignoreWater = storedErase.ignoreWater
			local ignoreInvisible = storedErase.ignoreInvisible
			
			if t.numberConstrained(Constants.MIN_RADIUS, Constants.MAX_RADIUS)(radius) then
				eraseState.radius = radius
			end
			
			if t.boolean(ignoreWater) then
				eraseState.ignoreWater = ignoreWater
			end
			
			if t.boolean(ignoreInvisible) then
				eraseState.ignoreInvisible = ignoreInvisible
			end
		end)()
	end
	
	local store = self.store
	store:dispatch({
		type = "_CopyFromState",
		init = initialState
	})
end

function Brushtool:_beginSerializingState()
	local store = self.store
	
	local function serializeBrushState()
		local state = store:getState()
		local brush = state.brush
		
		local toSerialize = {
			radius = brush.radius,
			spacing = brush.spacing,
			ignoreWater = brush.ignoreWater,
			ignoreInvisible = brush.ignoreInvisible,
			rotation = brush.rotation,
			scale = brush.scale,
			wobble = brush.wobble,
			orientation = {
				mode = brush.orientation.mode,
				custom = {
					x = brush.orientation.custom.x,
					y = brush.orientation.custom.y,
					z = brush.orientation.custom.z
				}
			}
		}
		
		self.tableStore:WriteTable("brush", toSerialize)
		
		local oldBrushedParentInstance = self.referenceStore:ReadInstance("brushedParent")
		if oldBrushedParentInstance == nil or oldBrushedParentInstance and oldBrushedParentInstance.Value ~= brush.brushedParent then
			local newStampedParentObject = Instance.new("ObjectValue")
			newStampedParentObject.Value = brush.brushedParent		
			self.referenceStore:WriteInstance("brushedParent", newStampedParentObject)
		end
	end
	
	local function serializeBrushObjectsState()
		local state = store:getState()
		local objects = state.brushObjects
		
		local toSerialize = {}
		
		for guid, stats in next, objects do
			toSerialize[guid] = {
				rotation = stats.rotation,
				scale = stats.scale,
				wobble = stats.wobble,
				verticalOffset = stats.verticalOffset,
				orientation = {
					mode = stats.orientation.mode,
					custom = {
						x = stats.orientation.custom.x,
						y = stats.orientation.custom.y,
						z = stats.orientation.custom.z
					}
				},
				brushEnabled = stats.brushEnabled,
				brushCenterMode = stats.brushCenterMode,
				timeAdded = stats.timeAdded
			}
		end
		
		self.tableStore:WriteTable("brushObjects", toSerialize)
	end
	
	local function serializeStampState()
		local state = store:getState()
		local stamp = state.stamp
		
		local toSerialize = {
			ignoreWater = stamp.ignoreWater,
			ignoreInvisible = stamp.ignoreInvisible,
			currentlyStamping = stamp.currentlyStamping
		}
		
		self.tableStore:WriteTable("stamp", toSerialize)
		
		local oldStampedParentInstance = self.referenceStore:ReadInstance("stampedParent")
		if oldStampedParentInstance == nil or oldStampedParentInstance and oldStampedParentInstance.Value ~= stamp.stampedParent then
			local newStampedParentObject = Instance.new("ObjectValue")
			newStampedParentObject.Value = stamp.stampedParent		
			self.referenceStore:WriteInstance("stampedParent", newStampedParentObject)
		end
	end

	local function serializeStampObjectsState()
		local state = store:getState()
		local objects = state.stampObjects
		
		local toSerialize = {}
		
		for guid, stats in next, objects do
			toSerialize[guid] = {
				rotation = stats.rotation,
				scale = stats.scale,
				wobble = stats.wobble,
				verticalOffset = stats.verticalOffset,
				orientation = {
					mode = stats.orientation.mode,
					custom = {
						x = stats.orientation.custom.x,
						y = stats.orientation.custom.y,
						z = stats.orientation.custom.z
					}
				},
				stampCenterMode = stats.stampCenterMode,
				timeAdded = stats.timeAdded
			}
		end
		
		self.tableStore:WriteTable("stampObjects", toSerialize)
	end
	
	local function serializeEraseState()
		local state = store:getState()
		local erase = state.erase
		
		local toSerialize = {
			radius = erase.radius,
			ignoreWater = erase.ignoreWater,
			ignoreInvisible = erase.ignoreInvisible
		}
		
		self.tableStore:WriteTable("erase", toSerialize)
	end
	
	local function refreshStoredBrushObjects(state)
		local objects = state.brushObjects
		local brushObjectsStore = self.brushObjectsStore
		
		for guid, object in next, objects do
			local rbxObject = object.rbxObject
			if not brushObjectsStore:HasInstance(guid) then
				brushObjectsStore:WriteInstance(guid, rbxObject)
			end
		end
		
		for _, guid in next, brushObjectsStore:GetInstanceIds() do
			if not objects[guid] then
				brushObjectsStore:DeleteInstance(guid)
			end
		end
	end
	
	local function refreshStoredStampObjects(state)
		local objects = state.stampObjects
		local stampObjectsStore = self.stampObjectsStore
		
		for guid, object in next, objects do
			local rbxObject = object.rbxObject
			if not stampObjectsStore:HasInstance(guid) then
				stampObjectsStore:WriteInstance(guid, rbxObject)
			end
		end
		
		for _, guid in next, stampObjectsStore:GetInstanceIds() do
			if not objects[guid] then
				stampObjectsStore:DeleteInstance(guid)
			end
		end
	end
	
	refreshStoredBrushObjects(store:getState())		
	refreshStoredStampObjects(store:getState())		
	serializeBrushState()
	serializeBrushObjectsState()
	serializeStampState()
	serializeStampObjectsState()
	serializeEraseState()
		
	self.storeChangedConn = store.changed:connect(function(newState, oldState)
		refreshStoredBrushObjects(newState)		
		refreshStoredStampObjects(newState)		
		serializeBrushState()
		serializeBrushObjectsState()
		serializeStampState()
		serializeStampObjectsState()
		serializeEraseState()
		
		if #self:GetEnabledBrushObjects() <= 0 and self.mode == "Brush" then
			self:Deactivate()
		end
		
--		if #self:GetEnabledBrushObjects() <= 0 and self.mode == "Stamp" then
--			self:Deactivate()
--		end
		
		if oldState.brush and oldState.brush.brushedParent ~= newState.brush.brushedParent then
			if self.brushedParentConn then
				self.brushedParentConn:Disconnect()
			end
			
			local brushedParent = newState.brush.brushedParent
			self.brushedParentConn = RunService.Heartbeat:Connect(function()
				if not brushedParent:IsDescendantOf(workspace) and brushedParent ~= workspace then
					warn("Brush.Parent has been moved or deleted. Resetting it to workspace.")
					store:dispatch(
						SetBrushedParent(workspace)
					)
				end
			end)
		end
		
		if oldState.stamp and oldState.stamp.stampedParent ~= newState.stamp.stampedParent then
			if self.stampedParentConn then
				self.stampedParentConn:Disconnect()
			end
			local stampedParent = newState.stamp.stampedParent
			self.stampedParentConn = RunService.Heartbeat:Connect(function()
				if not stampedParent:IsDescendantOf(workspace) and stampedParent ~= workspace then
					warn("Stamp.Parent has been moved or deleted. Resetting it to workspace.")
					store:dispatch(
						SetStampedParent(workspace)
					)
				end
			end)
		end
	end)
end

function Brushtool:_stopSerializingState()
	
end

function Brushtool:start()
	local loadedAtLeastOnce = self:HasLoadedAtLeastOnce()
	
	self:_loadStoredState()
	self:_beginSerializingState()
	ChangeHistoryService:ResetWaypoints()
	self.ready = true
	
	if not loadedAtLeastOnce then
		for i, brush in next, Constants.STARTER_BRUSHES do
			local model, guid, enabled = brush.model, brush.guid, brush.enabled
			self.store:dispatch(
				AddBrushObject(model, guid)
			)
			self.store:dispatch(
				SetBrushObjectBrushEnabled(guid, enabled)
			)
		end
		
		for _, stamp in next, Constants.STARTER_STAMPS do
			local model, guid, enabled = stamp.model, stamp.guid, stamp.enabled
			self.store:dispatch(
				AddStampObject(model, guid)
			)
			if enabled then
				self.store:dispatch(
					SetStampCurrentlyStamping(guid)
				)
			end
		end
	end
	
	self:PortOldDataToCurrentVersion()
end

local RunService = game:GetService("RunService")
function Brushtool:IsInEditMode()
	if RunService:IsStudio() and RunService:IsEdit() then
		return true
	else
		return false
	end
end

function Brushtool:MarkNecessaryWaypoints()
	if self.shouldMarkWaypointForBrush then
		self.shouldMarkWaypointForBrush = false
		ChangeHistoryService:SetWaypoint("Brushed")
	end
	if self.shouldMarkWaypointForErase then
		self.shouldMarkWaypointForErase = false
		ChangeHistoryService:SetWaypoint("Erased")
	end
	if self.shouldMarkWaypointForStamp then
		self.shouldMarkWaypointForStamp = false
		ChangeHistoryService:SetWaypoint("Stamped")
	end
end

function Brushtool:destroy()
	self.selectionChangedConn:Disconnect()
	if self.storeChangedConn then
		self.storeChangedConn:disconnect()
	end
	
	if self.brushObjectsStore then
		if self.brushObjectsStore:MustSave() then
			self.brushObjectsStore:Save()
		end
		self.brushObjectsStore:Destroy()
	end
	
	if self.stampObjectsStore then
		if self.stampObjectsStore:MustSave() then
			self.stampObjectsStore:Save()
		end
		self.stampObjectsStore:Destroy()
	end
	
	if self.referenceStore then
		if self.referenceStore:MustSave() then
			self.referenceStore:Save()
		end
		self.referenceStore:Destroy()
	end
	
	if self.tableStore then
		if self.tableStore:MustSave() then
			self.tableStore:Save()
		end
		self.tableStore:Destroy()
	end
	
	if self.mouseDownConn then
		self.mouseDownConn:Disconnect()
	end
	
	if self.mouseUpConn then
		self.mouseUpConn:Disconnect()
	end
	
	if self.undoConn then
		self.undoConn:Disconnect()
	end
	
	if self.redoConn then
		self.redoConn:Disconnect()
	end
	
	if self.brushedParentConn then
		self.brushedParentConn:Disconnect()
	end
	
	if self.stampedParentConn then
		self.stampedParentConn:Disconnect()
	end
	
	if self.brushedAddedConn then
		self.brushedAddedConn:Disconnect()
	end
	
	if self.brushedRemovedConn then
		self.brushedRemovedConn:Disconnect()
	end
	
	self.hConn:Disconnect()
	self.deactivationConn:Disconnect()
end

function Brushtool:Activate(mode)
	self.mode = mode
	self.plugin:Activate(true)
	self.active = true
	self:MarkNecessaryWaypoints()
	self._signal:fire()
end

function Brushtool:Deactivate()
	self.mode = "None"
	self.plugin:Deactivate()
	self:MarkNecessaryWaypoints()
	self._signal:fire()
end

function Brushtool:RemoveObjectFromSelection(toRemove)
	local currentSelection = Selection:Get()
	local idxToRemove
	for idx, selected in next, currentSelection do
		if selected == toRemove then
			idxToRemove = idx
			break
		end
	end
	
	table.remove(currentSelection, idxToRemove)
	local newSelection = currentSelection
	Selection:Set(newSelection)
end

function Brushtool:ClearTags()
	ChangeHistoryService:SetWaypoint("ClearTags")
	for _, v in next, CollectionService:GetTagged(Constants.BRUSHED_TAG) do
		CollectionService:RemoveTag(v, Constants.BRUSHED_TAG)
		CollectionService:RemoveTag(v, Constants.BRUSHED_PP_AS_CENTER_TAG)
	end
	ChangeHistoryService:SetWaypoint("ClearTags")
	self.brushedCache = nil
	self._signal:fire()
end

function Brushtool:TimeToAutosave()
	return self.timeToAutosave
end

function Brushtool:MustSave()
	return self.brushObjectsStore:MustSave() or
		self.stampObjectsStore:MustSave() or
		self.referenceStore:MustSave() or
		self.tableStore:MustSave()
end

function Brushtool:Save()
	self.brushObjectsStore:Save()
	self.stampObjectsStore:Save()
	self.referenceStore:Save()
	self.tableStore:Save()
	self.timeToAutosave = Constants.AUTOSAVE_INTERVAL
	
	self._signal:fire()
end

-- https://forum.rainmeter.net/viewtopic.php?t=23486
function ISO8601TimestampToUST(dateStringArg)
	local inYear, inMonth, inDay, inHour, inMinute, inSecond, inZone =	 
		string.match(dateStringArg, '^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)(.-)$')

	local zHours, zMinutes = string.match(inZone, '^(.-):(%d%d)$')

	local returnTime = os.time({year=inYear, month=inMonth, day=inDay, hour=inHour, min=inMinute, sec=inSecond, isdst=false})

	if zHours then
	  returnTime = returnTime - ((tonumber(zHours)*3600) + (tonumber(zMinutes)*60))
	end

	return returnTime
end

function Brushtool:IsUpdateAvailable()
	local cachedUpdate = self.cachedUpdate
	if cachedUpdate == nil then
		local pid = Constants.PLUGIN_THIS_IS_BETA_CHANNEL and Constants.PLUGIN_BETA_CHANNEL_PRODUCT_ID or Constants.PLUGIN_PRODUCT_ID
		local MarketplaceService = game:GetService("MarketplaceService")
		local ok, err = pcall(function()
			local pInfo = MarketplaceService:GetProductInfo(pid)
			local desc = pInfo.Description
			-- Description is empty. Maybe we got cd'ed?
			if not desc then
				warn("[Brushtool] Can't retrieve plugin version. A new update may be available.")
				cachedUpdate = false
				return
			else
				local semverMatch = desc:match("semver ([0-9]+\.[0-9]+\.[0-9]+)")
				if semverMatch then
					local websitePluginVersion = semver(semverMatch)
					local thisPluginVersion = Constants.PLUGIN_VERSION
					if thisPluginVersion < websitePluginVersion then
						cachedUpdate = true
						return
					else
						cachedUpdate = false
						return
					end
				else
					-- Typo, maybe? Accidentally cleared?
					warn("[Brushtool] Can't retrieve plugin version. A new update may be available.")
					cachedUpdate = false
					return
				end
			end
		end)
		
		if not ok then
			warn("[Brushtool] Can't retrieve plugin version. A new update may be available.")
			cachedUpdate = false
		end
		
		self.cachedUpdate = cachedUpdate
	end
	
	return cachedUpdate
end

function Brushtool:clearStoredSettings()
	local prefix = self:GetStorePrefix()	
	local brushObjectsName = prefix .. "BrushtoolBrushObjects"
	local stampObjectsName = prefix .. "BrushtoolStampObjects"
	local referencesName = prefix .. "BrushtoolReferences"
	local tableName = prefix .. "BrushtoolTable"
	
	InstanceStore.ClearStore(Constants.PLUGIN_STORAGE_SCOPE, brushObjectsName)
	InstanceStore.ClearStore(Constants.PLUGIN_STORAGE_SCOPE, stampObjectsName)
	InstanceStore.ClearStore(Constants.PLUGIN_STORAGE_SCOPE, referencesName)
	TableStore.ClearStore(Constants.PLUGIN_STORAGE_SCOPE, tableName)
end

function Brushtool:HasLoadedAtLeastOnce()
	local prefix = self:GetStorePrefix()
	local brushObjectsName = prefix .. "BrushtoolBrushObjects"
	local stampObjectsName = prefix .. "BrushtoolStampObjects"
	local referencesName = prefix .. "BrushtoolReferences"
	local tableName = prefix .. "BrushtoolTable"
	
	return InstanceStore.DoesStoreExist(Constants.PLUGIN_STORAGE_SCOPE, brushObjectsName) or
		InstanceStore.DoesStoreExist(Constants.PLUGIN_STORAGE_SCOPE, stampObjectsName) or
		InstanceStore.DoesStoreExist(Constants.PLUGIN_STORAGE_SCOPE, referencesName) or
		TableStore.DoesStoreExist(Constants.PLUGIN_STORAGE_SCOPE, tableName)
end

local function containsParts(obj)
	for _, v in next, obj:GetDescendants() do
		if v:IsA("BasePart") and not v:IsA("Terrain") then
			return true
		end
	end
	
	return false
end

local function atLeastOneArchivablePart(obj)
	for _, v in next, obj:GetDescendants() do
		if v:IsA("BasePart") and not v:IsA("Terrain") and v.Archivable then
			return true
		end
	end
	
	return false
end

function Brushtool:IsValidBrushCandidate(obj)
	if obj:IsA("BasePart") and not obj:IsA("Terrain") then
		if obj.Archivable then
			return true
		else
			return false, "NotArchivable"
		end
	elseif obj.ClassName == "Model" then
		if obj.Archivable then
			if containsParts(obj) then
				if atLeastOneArchivablePart(obj) then
					return true
				else
					return false, "NoArchivableParts"
				end
			else
				return false, "NoParts"
			end
		else
			return false, "NotArchivable"
		end
	else
		return false, "NotValidObjectType"
	end
end

function Brushtool:IsValidStampCandidate(obj)
	if obj:IsA("BasePart") and not obj:IsA("Terrain") then
		if obj.Archivable then
			return true
		else
			return false, "NotArchivable"
		end
	elseif obj.ClassName == "Model" then
		if obj.Archivable then
			if containsParts(obj) then
				if atLeastOneArchivablePart(obj) then
					return true
				else
					return false, "NoArchivableParts"
				end
			else
				return false, "NoParts"
			end
		else
			return false, "NotArchivable"
		end
	else
		return false, "NotValidObjectType"
	end
end

function Brushtool:PortOldDataToCurrentVersion()
	local initialState = {
		brush = {
			selected = "",
			filter = "",
			radius = 16,
			spacing = 8,
			ignoreWater = false,
			ignoreInvisible = false,
			rotation = {
				mode = "None",
				fixed = 0,
				min = 0,
				max = 360
			},
			scale = {
				mode = "None",
				fixed = 1,
				min = 1,
				max = 2
			},
			wobble = {
				mode = "None",
				min = 0,
				max = 30
			},
			orientation = {
				mode  = "Normal",
				custom = Vector3.new(0, 1, 0)
			},
			brushedParent = workspace
		},
		brushObjects = {},
		stamp = {
			currentlyStamping = "",
			deleting = "",
			filter = "",
			ignoreWater = false,
			ignoreInvisible = false,
			stampedParent = workspace
		},
		stampObjects = {},
		erase = {
			radius = 16,
			ignoreWater = false,
			ignoreInvisible = false
		}
	}
	
	local prefix = self:GetStorePrefix()
	if OLD_InstanceStore.DoesStoreExist(prefix .. "BrushtoolBrushObjects") and
		OLD_InstanceStore.DoesStoreExist(prefix .. "BrushtoolStampObjects") and
		OLD_InstanceStore.DoesStoreExist(prefix .. "BrushtoolReferences") and
		OLD_TableStore.DoesStoreExist(prefix .. "BrushtoolTable") then
		local brushObjectsStore = OLD_InstanceStore.new(prefix .. "BrushtoolBrushObjects")
		local stampObjectsStore = OLD_InstanceStore.new(prefix .. "BrushtoolStampObjects")
		local referenceStore = OLD_InstanceStore.new(prefix .. "BrushtoolReferences")
		local tableStore = OLD_TableStore.new(prefix .. "BrushtoolTable")
		
		local brushState = initialState.brush do
			(function()
				local storedBrush = tableStore:ReadTable("brush")
				if storedBrush == nil then
					return
				end
				
				local radius = storedBrush.radius
				local spacing = storedBrush.spacing
				local ignoreWater = storedBrush.ignoreWater
				local ignoreInvisible = storedBrush.ignoreInvisible
				local rotation = storedBrush.rotation
				local scale = storedBrush.scale
				local wobble = storedBrush.wobble
				local orientation = storedBrush.orientation
				
				if t.numberConstrained(Constants.MIN_RADIUS, Constants.MAX_RADIUS)(radius) then
					brushState.radius = radius
				end
				
				if t.numberConstrained(Constants.MIN_SPACING, Constants.MAX_SPACING)(spacing) then
					brushState.spacing = spacing
				end
				
				if t.boolean(ignoreWater) then
					brushState.ignoreWater = ignoreWater
				end
				
				if t.boolean(ignoreInvisible) then
					brushState.ignoreInvisible = ignoreInvisible
				end
				
				local rotInterface = t.strictInterface{
					mode = t.union(t.literal"None", t.literal"Random", t.literal"Fixed"),
					fixed = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
					min = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
					max = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION)
				}
				
				local scaleInterface = t.strictInterface{
					mode = t.union(t.literal"None", t.literal"Random", t.literal"Fixed"),
					fixed = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
					min = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
					max = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE)
				}
				
				local wobbleInterface = t.strictInterface{
					mode = t.union(t.literal"None", t.literal"Random"),
					min = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE),
					max = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE)
				}
				
				local orientationInterface = t.strictInterface{
					mode = t.union(t.literal"Normal", t.literal"Up", t.literal"Custom"),
					custom = t.interface{ x = t.number, y = t.number, z = t.number },
				}
				
				if rotInterface(rotation) and rotation.min <= rotation.max then
					brushState.rotation = rotation
				end
				
				if scaleInterface(scale) and scale.min <= scale.max then
					brushState.scale = scale
				end
				
				if wobbleInterface(wobble) and wobble.min <= wobble.max then
					brushState.wobble = wobble
				end
				
				if orientationInterface(orientation) and (orientation.custom.x ~= 0 or orientation.custom.y ~= 0 or orientation.custom.z ~= 0) then
					brushState.orientation = {
						mode = orientation.mode,
						custom = Vector3.new(orientation.custom.x, orientation.custom.y, orientation.custom.z)
					}
				end
				
				local brushedParentRefObject = referenceStore:ReadInstance("brushedParent")
				if brushedParentRefObject ~= nil and 
					brushedParentRefObject:IsA("ObjectValue") and 
					brushedParentRefObject.Archivable == true and 
					brushedParentRefObject.Value ~= nil and
					brushedParentRefObject.Value:IsDescendantOf(workspace) then
					brushState.brushedParent = brushedParentRefObject.Value
				end
			end)()
		end
		
		local brushObjectsState = initialState.brushObjects do
			(function()
				local storedObjects = tableStore:ReadTable("brushObjects")
				if storedObjects == nil then
					return
				end
				
				for guid, objectDecoded in next, storedObjects do
					if t.string(guid) then
						local rbxObject = brushObjectsStore:ReadInstance(guid)
						if rbxObject and self:IsValidBrushCandidate(rbxObject) then
							local newEntry = {
								rbxObject = rbxObject:Clone(),
								-- attempt at adding sub-seconds.
								-- Objects may be added in the same second.
								-- This can mess up ordering later on.
								name = rbxObject.Name,
								-- warning: models with 0 parts will return an invalid size.
								-- make sure beforehand that all models have at least one part!
								size = (function()
									if rbxObject:IsA("Model") then
										local min, max = Utility.GetModelAABBFast(rbxObject) 
										local size =(max-min)
										return size
									else
										local min, max = Utility.GetPartAABB(rbxObject) 
										local size =(max-min)
										return size
									end
								end)(), 
								timeAdded = os.time(os.date("!*t")) + tick()%1, 
								brushEnabled = true,
								brushCenterMode = "BoundingBox",
								rotation = {
									mode = "NoOverride",
									fixed = 0,
									min = 0,
									max = 360
								},
								scale = {
									mode = "NoOverride",
									fixed = 1,
									min = 1,
									max = 2
								},
								wobble = {
									mode = "NoOverride",
									min = 0,
									max = 30
								},
								verticalOffset = {
									mode = "Auto",
									fixed = 0,
									min = 0,
									max = 1
								},
								orientation = {
									mode  = "NoOverride",
									custom = Vector3.new(0, 1, 0)
								}
							}
							
							local timeAdded = objectDecoded.timeAdded
							local brushEnabled = objectDecoded.brushEnabled
							local brushCenterMode = objectDecoded.brushCenterMode
							local rotation = objectDecoded.rotation
							local scale = objectDecoded.scale
							local wobble = objectDecoded.wobble
							local verticalOffset = objectDecoded.verticalOffset
							local orientation = objectDecoded.orientation
							
							if t.number(timeAdded) then
								newEntry.timeAdded = timeAdded
							end
							
							-- brushEnabled may only be a boolean
							if t.boolean(brushEnabled) then
								newEntry.brushEnabled = brushEnabled
							end
							
							-- make sure that brushCenterMode is valid
							if t.union(t.literal("BoundingBox"), t.literal("PrimaryPart"))(brushCenterMode) then
								-- and if it's a model
								if rbxObject:IsA("Model") then
									-- and that if it has a primary part, then allow either value
									if rbxObject.PrimaryPart ~= nil then
										newEntry.brushCenterMode = brushCenterMode
									else
										-- otherwise, it can't use PrimaryPart center mode.
										if brushCenterMode ~= "PrimaryPart" then
											newEntry.brushCenterMode = brushCenterMode
										end
									end
								else
									-- and if it's a part, then it can only use the bounding box
									if brushCenterMode == "BoundingBox" then
										newEntry.brushCenterMode = "BoundingBox"
									end
								end
							end
									
							local rotInterface = t.strictInterface{
								mode = t.union(t.literal"NoOverride", t.literal"None", t.literal"Random", t.literal"Fixed"),
								fixed = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
								min = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
								max = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION)
							}
							
							local scaleInterface = t.strictInterface{
								mode = t.union(t.literal"NoOverride", t.literal"None", t.literal"Random", t.literal"Fixed"),
								fixed = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
								min = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
								max = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE)
							}
							
							local wobbleInterface = t.strictInterface{
								mode = t.union(t.literal"NoOverride", t.literal"None", t.literal"Random"),
								min = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE),
								max = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE)
							}
							
							local verticalOffsetInterface = t.strictInterface{
								mode = t.union(t.literal"Auto", t.literal"Random", t.literal"Fixed"),
								fixed = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
								min = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
								max = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET)
							}
							
							local orientationInterface = t.strictInterface{
								mode = t.union(t.literal"NoOverride", t.literal"Normal", t.literal"Up", t.literal"Custom"),
								custom = t.interface{ x = t.number, y = t.number, z = t.number },
							}
							
							if rotInterface(rotation) and rotation.min <= rotation.max then
								newEntry.rotation = rotation
							end
							
							if scaleInterface(scale) and scale.min <= scale.max then
								newEntry.scale = scale
							end
							
							if wobbleInterface(wobble) and wobble.min <= wobble.max then
								newEntry.wobble = wobble
							end
							
							if verticalOffsetInterface(verticalOffset) and verticalOffset.min <= verticalOffset.max then
								newEntry.verticalOffset = verticalOffset
							end
							
							if orientationInterface(orientation) and (orientation.custom.x ~= 0 or orientation.custom.y ~= 0 or orientation.custom.z ~= 0) then
								newEntry.orientation = {
									mode = orientation.mode,
									custom = Vector3.new(orientation.custom.x, orientation.custom.y, orientation.custom.z)
								}
							end
							
							brushObjectsState[guid] = newEntry
						end
					end
				end
			end)()
		end
	
		local stampState = initialState.stamp do
			(function()
				local storedStamp = tableStore:ReadTable("stamp")
				if storedStamp == nil then
					return
				end
				
				local ignoreWater = storedStamp.ignoreWater
				local ignoreInvisible = storedStamp.ignoreInvisible
				local currentlyStamping = storedStamp.currentlyStamping
				
				if t.boolean(ignoreWater) then
					stampState.ignoreWater = ignoreWater
				end
				
				if t.boolean(ignoreInvisible) then
					stampState.ignoreInvisible = ignoreInvisible
				end
				
				local stampedParentRefObject = referenceStore:ReadInstance("stampedParent")
				if stampedParentRefObject ~= nil and 
					stampedParentRefObject:IsA("ObjectValue") and 
					stampedParentRefObject.Archivable == true and 
					stampedParentRefObject.Value ~= nil and
					stampedParentRefObject.Value:IsDescendantOf(workspace) then
					stampState.stampedParent = stampedParentRefObject.Value
				end
				
				if t.string(currentlyStamping) then
					stampState.currentlyStamping = currentlyStamping
				end
			end)()
		end
		
		local stampObjectsState = initialState.stampObjects do
			(function()
				local storedObjects = tableStore:ReadTable("stampObjects")
				if storedObjects == nil then
					return
				end
				
				for guid, objectDecoded in next, storedObjects do
					if t.string(guid) then
						local rbxObject = stampObjectsStore:ReadInstance(guid)
						if rbxObject and self:IsValidStampCandidate(rbxObject) then
							local newEntry = {
								rbxObject = rbxObject:Clone(),
								-- attempt at adding sub-seconds.
								-- Objects may be added in the same second.
								-- This can mess up ordering later on.
								name = rbxObject.Name,
								-- warning: models with 0 parts will return an invalid size.
								-- make sure beforehand that all models have at least one part!
								size = (function()
									if rbxObject:IsA("Model") then
										local min, max = Utility.GetModelAABBFast(rbxObject) 
										local size =(max-min)
										return size
									else
										local min, max = Utility.GetPartAABB(rbxObject) 
										local size =(max-min)
										return size
									end
								end)(), 
								timeAdded = os.time(os.date("!*t")) + tick()%1, 
								stampCenterMode = "BoundingBox",
								rotation = {
									mode = "None",
									fixed = 0,
									min = 0,
									max = 360
								},
								scale = {
									mode = "None",
									fixed = 1,
									min = 1,
									max = 2
								},
								wobble = {
									mode = "None",
									min = 0,
									max = 30
								},
								verticalOffset = {
									mode = "Auto",
									fixed = 0,
									min = 0,
									max = 1
								},
								orientation = {
									mode  = "Normal",
									custom = Vector3.new(0, 1, 0)
								}
							}
							
							local timeAdded = objectDecoded.timeAdded
							local stampCenterMode = objectDecoded.stampCenterMode
							local rotation = objectDecoded.rotation
							local scale = objectDecoded.scale
							local wobble = objectDecoded.wobble
							local verticalOffset = objectDecoded.verticalOffset
							local orientation = objectDecoded.orientation
							
							if t.number(timeAdded) then
								newEntry.timeAdded = timeAdded
							end
							
							-- make sure that stampCenterMode is valid
							if t.union(t.literal("BoundingBox"), t.literal("PrimaryPart"))(stampCenterMode) then
								-- and if it's a model
								if rbxObject:IsA("Model") then
									-- and that if it has a primary part, then allow either value
									if rbxObject.PrimaryPart ~= nil then
										newEntry.stampCenterMode = stampCenterMode
									else
										-- otherwise, it can't use PrimaryPart center mode.
										if stampCenterMode ~= "PrimaryPart" then
											newEntry.stampCenterMode = stampCenterMode
										end
									end
								else
									-- and if it's a part, then it can only use the bounding box
									if stampCenterMode == "BoundingBox" then
										newEntry.stampCenterMode = "BoundingBox"
									end
								end
							end
									
							local rotInterface = t.strictInterface{
								mode = t.union(t.literal"None", t.literal"ClickAndDrag", t.literal"Random", t.literal"Fixed"),
								fixed = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
								min = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION),
								max = t.numberConstrained(Constants.MIN_ROTATION, Constants.MAX_ROTATION)
							}
							
							local scaleInterface = t.strictInterface{
								mode = t.union(t.literal"None", t.literal"Random", t.literal"Fixed"),
								fixed = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
								min = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE),
								max = t.numberConstrained(Constants.MIN_SCALE, Constants.MAX_SCALE)
							}
							
							local wobbleInterface = t.strictInterface{
								mode = t.union(t.literal"None", t.literal"Random"),
								min = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE),
								max = t.numberConstrained(Constants.MIN_WOBBLE, Constants.MAX_WOBBLE)
							}
							
							local verticalOffsetInterface = t.strictInterface{
								mode = t.union(t.literal"Auto", t.literal"Random", t.literal"Fixed"),
								fixed = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
								min = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET),
								max = t.numberConstrained(Constants.MIN_VERTICAL_OFFSET, Constants.MAX_VERTICAL_OFFSET)
							}
							
							local orientationInterface = t.strictInterface{
								mode = t.union(t.literal"Normal", t.literal"Up", t.literal"Custom"),
								custom = t.interface{ x = t.number, y = t.number, z = t.number },
							}
							
							if rotInterface(rotation) and rotation.min <= rotation.max then
								newEntry.rotation = rotation
							end
							
							if scaleInterface(scale) and scale.min <= scale.max then
								newEntry.scale = scale
							end
							
							if wobbleInterface(wobble) and wobble.min <= wobble.max then
								newEntry.wobble = wobble
							end
							
							if verticalOffsetInterface(verticalOffset) and verticalOffset.min <= verticalOffset.max then
								newEntry.verticalOffset = verticalOffset
							end
							
							if orientationInterface(orientation) and (orientation.custom.x ~= 0 or orientation.custom.y ~= 0 or orientation.custom.z ~= 0) then
								newEntry.orientation = {
									mode = orientation.mode,
									custom = Vector3.new(orientation.custom.x, orientation.custom.y, orientation.custom.z)
								}
							end
							
							stampObjectsState[guid] = newEntry
						end
					end
				end
			end)()
		end
	
		local eraseState = initialState.erase do
			(function()
				local storedErase = tableStore:ReadTable("erase")
				if storedErase == nil then
					return
				end
				
				local radius = storedErase.radius
				local ignoreWater = storedErase.ignoreWater
				local ignoreInvisible = storedErase.ignoreInvisible
				
				if t.numberConstrained(Constants.MIN_RADIUS, Constants.MAX_RADIUS)(radius) then
					eraseState.radius = radius
				end
				
				if t.boolean(ignoreWater) then
					eraseState.ignoreWater = ignoreWater
				end
				
				if t.boolean(ignoreInvisible) then
					eraseState.ignoreInvisible = ignoreInvisible
				end
			end)()
		end
		
		-- overwrite save data with ported old data.
		-- this is probably naugty.	
		local store = self.store
		store:dispatch({
			type = "_CopyFromState",
			init = initialState
		})
		
		brushObjectsStore:Destroy()
		stampObjectsStore:Destroy()
		referenceStore:Destroy()
		tableStore:Destroy()
		
		OLD_InstanceStore.ClearStore(prefix .. "BrushtoolBrushObjects")
		OLD_InstanceStore.ClearStore(prefix .. "BrushtoolStampObjects")
		OLD_InstanceStore.ClearStore(prefix .. "BrushtoolReferences")
		OLD_TableStore.ClearStore(prefix .. "BrushtoolTable")
	end
end

return Brushtool
