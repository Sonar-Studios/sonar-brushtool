-- Written by XAXA from Roblox, MIT Licence.

local Utility = {}

local CollectionService = game:GetService("CollectionService")

-- Standard map function.
function Utility.Map(a, func)
	local mapped = {}
	for i, v in pairs(a) do
		mapped[i] = func(v)
	end
	
	return mapped
end

function Utility.Average(a)
	local count = #a
	if count == 0 then return nil end
	
	local avg = a[1]/count
	for i = 2, count do
		avg = avg + a[i]/count
	end
	
	return avg
end

function Utility.Sum(a)
	if #a == 0 then return nil end
	local sum = a[1]
	for i = 2, #a do
		sum = sum + a[i]
	end
	
	return sum
end

-- Standard filter function.
function Utility.Filter(a, func)
	local filtered = {}
	for _, v in pairs(a) do
		if func(v) then
			table.insert(filtered, v)
		end
	end
	
	return filtered
end

local function prev(a, i)
	local i = i - 1
	local v = a[i]
	if v then
		return i, v
	end
end

-- Reverse iterator for ipairs.
function Utility.rpairs(a)
	return prev, a, #a+1
end

-- Copies a table without exploring any subtables.
function Utility.ShallowCopy(a)
	local copy = {}
	for i, v in pairs(a) do
		copy[i] = v
	end
	
	return copy
end

-- Converts the table's values into an array.
-- Order is undefined.
function Utility.ToArray(a)
	local arr = {}
	for _, v in pairs(a) do
		table.insert(arr, v)
	end
	
	return arr
end

function Utility.KeysAsArray(a)
	local arr = {}
	for v, _ in pairs(a) do
		table.insert(arr, v)
	end
	
	return arr
end

function Utility.ProjectVector(vecA, vecB)
	return vecB:Dot(vecA) / vecB:Dot(vecB) * vecB
end

function Utility.ProjectVectorToPlane(vec, plane)
	local project = Utility.ProjectVector(vec, plane)
	return vec - project
end

function Utility.GetAngleBetweenVectors(start, goal)
	local dot = start:Dot(goal)
	local angle = math.acos( math.clamp(dot/(start.magnitude * goal.magnitude), -1, 1) )
	return angle
end

function Utility.GetAngleBetweenVectorsSigned(start, goal, norm)
	return math.atan2((start:Cross(goal)):Dot(norm), start:Dot(goal))
end

function Utility.GetAngleBetweenCFrames(start, goal)
	return Utility.GetAngleBetweenVectors(start.lookVector, goal.lookVector)
end

function Utility.GetCFrameLerpAlphaForConstantTurnRate(start, goal, rate)
	local angle = Utility.GetAngleBetweenCFrames(start, goal)
	return math.min(1, rate/angle)
end

function Utility.Lerp(start, goal, alpha)
	return start + (goal - start) * alpha
end

function Utility.LerpClamped(start, goal, alpha)
	return start + (goal - start) * math.clamp(alpha, 0, 1)
end


function Utility.LerpDeltaTimed(start, goal, rate, m, dt)
	return start + (goal - start) * (1 - (1-rate)^(dt/m))
end

function Utility.PreloadHierarchy(root, hierarchy)
	for name, children in pairs(hierarchy) do
		local newRoot = root:WaitForChild(name)
		Utility.PreloadHierarchy(newRoot, children)
	end
end

function Utility.QuickSet(obj, propertyList)
	for propertyName, value in pairs(propertyList) do
		obj[propertyName] = value
	end
	
	return obj
end

-- Similar to RbxUtil's Create.
-- Creates an instance of className with given properties.
function Utility.Create(className, propertyList)
	propertyList = propertyList or {}
--	print(className)
	local i = Instance.new(className)
	
	Utility.QuickSet(i, propertyList)
	
	return i
end

-- Above, but ordered. PropertyList
-- is an array of lists.
function Utility.CreateOrdered(className, propertyList)
	propertyList = propertyList or {}
--	print(className)
	local i = Instance.new(className)
	
	for _, p in pairs(propertyList) do
		local pName, pValue = next(p)
		i[pName] = pValue
	end
	
	return i
end

function Utility.Round(n, multiple)
	multiple = multiple or 1
	return (math.floor(n/multiple + 1/2) * multiple)
end

function Utility.RoundTowards(n, goal, multiple)
	if n < goal then
		return Utility.Round(n+multiple/2, multiple)
	elseif n > goal then
		return Utility.Round(n-multiple/2, multiple)
	else
		return n
	end
end

function Utility.RoundDown(n, multiple)
	return Utility.Round(n-multiple/2, multiple)
end

function Utility.RoundUp(n, multiple)
	return Utility.Round(n+multiple/2, multiple)
end

function Utility.CFrameFromTopRight(p, top, right, front)
	if not front then
		front = top:Cross(right).unit
	end
	local top = top.unit
	local right = right.unit
	return CFrame.new(
		p.X, p.Y, p.Z,
		right.X, top.X, -front.X,
		right.Y, top.Y, -front.Y,
		right.Z, top.Z, -front.Z
	)
end

function Utility.PointToLocalNormal(part, v)
	local size = part.Size
	local xSizeHalf, ySizeHalf, zSizeHalf = size.X/2, size.Y/2, size.Z/2
	
	local oSpace = part.CFrame:pointToObjectSpace(v)
	local x, y, z = oSpace.X, oSpace.Y, oSpace.Z
		
	local proportionalDiff = Vector3.new(
		math.abs(oSpace.X) / xSizeHalf,
		math.abs(oSpace.Y) / ySizeHalf,
		math.abs(oSpace.Z) / zSizeHalf
	)
	
	local max = math.max(proportionalDiff.X, proportionalDiff.Y, proportionalDiff.Z)
	
	if max == proportionalDiff.X then
		return Vector3.new(1*math.sign(x), 0, 0)
	elseif max == proportionalDiff.Y then
		return Vector3.new(0, 1*math.sign(y), 0)
	else
		return Vector3.new(0, 0, 1*math.sign(z))
	end
end

function Utility.PointToLocalFaces(part, v)
	local size = part.Size
	local xSizeHalf, ySizeHalf, zSizeHalf = size.X/2, size.Y/2, size.Z/2
	
	local oSpace = part.CFrame:pointToObjectSpace(v)
	local x, y, z = oSpace.X, oSpace.Y, oSpace.Z
		

	local face = Vector3.new()
	if math.abs(x)/xSizeHalf > 0.99 then
		face = face + Vector3.new(math.sign(x), 0, 0)
	end
	
	if math.abs(y)/ySizeHalf > 0.99 then
		face = face + Vector3.new(0, math.sign(y), 0)
	end
	
	if math.abs(z)/zSizeHalf > 0.99 then
		face = face + Vector3.new(0, 0, math.sign(z))
	end
	
	return face
end

function Utility.ProjectPointToPartFace(part, v, face)
	local oSpace = part.CFrame:pointToObjectSpace(v)
	local sizeHalf = part.Size/2
	local v
	if face.X > 0 then
		v = Vector3.new(sizeHalf.X, oSpace.Y, oSpace.Z)
	elseif face.X < 0 then
		v = Vector3.new(-sizeHalf.X, oSpace.Y, oSpace.Z)
	elseif face.Y > 0 then
		v = Vector3.new(oSpace.X, sizeHalf.Y, oSpace.Z)
	elseif face.Y < 0 then
		v = Vector3.new(oSpace.X, -sizeHalf.Y, oSpace.Z)
	elseif face.Z > 0 then
		v = Vector3.new(oSpace.X, oSpace.Y, sizeHalf.Z)
	else
		v = Vector3.new(oSpace.X, oSpace.Y, -sizeHalf.Z)
	end
	
	return part.CFrame:pointToWorldSpace(v)
end

function Utility.ProjectPointToPlane(p, planePos, planeNorm)
	local cf = CFrame.new(planePos, planePos + planeNorm)
	local oSpace = cf:pointToObjectSpace(p)
	return cf:pointToWorldSpace(Vector3.new(oSpace.x, oSpace.y, 0))
end

function Utility.PointToWorldNormal(part, v)
	return part.CFrame:vectorToWorldSpace(Utility.PointToLocalNormal(part, v))
end

function Utility.ProjectPointToPart(part, v)
	local oSpace = part.CFrame:pointToObjectSpace(v)
	local size = part.Size
	local xSizeHalf, ySizeHalf, zSizeHalf = size.X/2, size.Y/2, size.Z/2
	local norm = Utility.PointToLocalNormal(part, v)

	if math.abs(norm.X) == 1 then
		return part.CFrame:pointToWorldSpace( oSpace * Vector3.new(0, 1, 1) + Vector3.new(xSizeHalf*norm.X, 0, 0))
	elseif math.abs(norm.Y) == 1 then
		return part.CFrame:pointToWorldSpace( oSpace * Vector3.new(1, 0, 1) + Vector3.new(0, ySizeHalf*norm.Y, 0))
	else
		return part.CFrame:pointToWorldSpace( oSpace * Vector3.new(1, 1, 0) + Vector3.new(0, 0, zSizeHalf*norm.Z))
	end
end

-- https://en.wikipedia.org/wiki/Circular_segment
function Utility.CalculateChordLength(theta, radius)
	radius = radius or 1
	
	return 2*radius * math.sin(theta/2)
end

function Utility.CastRayWithIgnoreList(origin, dir, ignoreList)
	ignoreList = ignoreList or {}
	
	local ray = Ray.new(origin, dir)
	return workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
end

function Utility.CastRayWithTagWhitelistAndIgnoreList(origin, dir, tagWhitelist, ignoreList, ignoreTransparent)
	debug.profilebegin("CastRayWithTagWhitelistAndIgnoreList")
	
	local ignoreTransparent = ignoreTransparent or false
	local tagWhitelist = tagWhitelist or {}
	
	local hit, pos, norm
	local ignoreList = ignoreList or {}
	local attempts = 0
	local ray = Ray.new(origin, dir)
	repeat
		attempts = attempts+1
		local hit, pos, norm = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
		
		if hit then
			local isOk = false
			for _, tag in next, tagWhitelist do
				if tag and CollectionService:HasTag(hit, tag) then
					isOk = true
					break
				end
			end
			
			if isOk and ((not ignoreTransparent) or (hit.Transparency < 1 and hit.LocalTransparencyModifier < 1))  then
				debug.profileend()
				return hit, pos, norm
			else
				table.insert(ignoreList, hit)
			end
		end
		
		origin = pos - dir*0.00001
	until hit == nil
	
	debug.profileend()
	local goal = origin + dir
	return nil, goal, nil
end

function Utility.CastRayWithWhitelist(origin, dir, whitelist)
	local ray = Ray.new(origin, dir)
	local hit, pos, norm = workspace:FindPartOnRayWithWhitelist(ray, whitelist)
	
	return hit, pos, norm
end

function Utility.Color3ToVertexColor(color3)
	return Vector3.new(color3.r, color3.g, color3.b)
end

function Utility.Region3FromVectors(v1, v2)
	local min = Vector3.new(
		math.min(v1.X, v2.X),
		math.min(v1.Y, v2.Y),
		math.min(v1.Z, v2.Z)
	)
	
	local max = Vector3.new(
		math.max(v1.X, v2.X),
		math.max(v1.Y, v2.Y),
		math.max(v1.Z, v2.Z)
	)
	
	return Region3.new(min, max)
end

function Utility.Region3FromAAPart(part)
	local sizeHalf = part.Size/2
	local p1 = (part.CFrame * CFrame.new(sizeHalf)).p
	local p2 = (part.CFrame * CFrame.new(-sizeHalf)).p
	
	return Utility.Region3FromVectors(p1, p2)
end

function Utility.IsPartInAAPart(part, regionPart)
	local region = Utility.Region3FromAAPart(regionPart)
	local inside = workspace:FindPartsInRegion3WithWhiteList(region, {part})
	
	return #inside == 1
end

function Utility.PickRandom(t)
	local size = #t
	if size == 0 then return nil end
	local r = Random.new()
	local index = r:NextInteger(1, size)
	return t[index]
end

function Utility.Vector2ToScaleUDim2(v2)
	return Utility.UDim2OffsetToScale(UDim2.new(0, v2.X, 0, v2.Y))
end

function Utility.ColorDistance(c1, c2)
	return math.sqrt(
		(c1.r - c2.r)^2 +
		(c1.g - c2.g)^2 +
		(c1.b - c2.b)^2
	)
end

function Utility.SpawnNow(func)
	local ev = Instance.new('BindableEvent')
	ev.Event:connect(func)
	ev:Fire()
	ev:Destroy()
end

function Utility.SmoothStep(x)
	if x <= 0 then return 0 end
	if x >= 1 then return 1 end
	
	return 3*x^2 - 2*x^3
end

function Utility.Shuffle(l, seed)
	local r
	if seed then
		r = Random.new(seed)
	else
		r = Random.new()
	end

	local size = #l
	for i = size, 1, -1 do
		local rand = r:NextInteger(1, size)
		l[i], l[rand] = l[rand], l[i]
	end
end

function Utility.GetFullAssembly(originPart)
	local result = {}
	local queue = {originPart}
	local touched = {[originPart] = true}
	local connectionChecked = {}
	local currentPart = originPart
	repeat
		-- Initialize surface joints.
		currentPart = table.remove(queue)
		currentPart:MakeJoints()
		table.insert(result, currentPart)
		for _, joint in pairs(currentPart:GetJoints()) do
			local part0, part1
			if joint:IsA("Constraint") then
				local attachment0 = joint.Attachment0
				local attachment1 = joint.Attachment1
				part0 = attachment0.Parent
				part1 = attachment1.Parent
			else
				part0 = joint.Part0
				part1 = joint.Part1
			end

			if not touched[part0] then
				touched[part0] = true
				table.insert(queue, part0)
			end
				
			if not touched[part1] then
				touched[part1] = true
				table.insert(queue, part1)
			end
		end	
		
		if not connectionChecked[currentPart] then
			connectionChecked[currentPart] = true
			for _, connectedPart in pairs(currentPart:GetConnectedParts(true)) do
				if not touched[connectedPart] then
					touched[connectedPart] = true
					connectionChecked[connectedPart] = true
					table.insert(queue, connectedPart)
				end
			end
		end
	until #queue <= 0

	return result
end

function Utility.GetTextLabelSize(label)
	local TextService = game:GetService("TextService")
	local text = label.Text
	local font = label.Font
	local size = label.TextSize
	return TextService:GetTextSize(text, size, font, Vector2.new(9999, 9999))
end

function Utility.DistributePointsOnUnitSphere(n)
	local pi, sqrt, sin, cos = math.pi, math.sqrt, math.sin, math.cos
	local Round = Utility.Round
	local a = 4*pi/n
	local d = sqrt(a)
	local M_theta = Round(pi/d)
	local d_theta = pi/M_theta
	local d_phi = a/d_theta
	local pts = {}
	for m = 0, M_theta-1 do
		local theta = pi*(m+0.5)/M_theta
		local M_phi = Round(2*pi*sin(theta)/d_phi)
		for n = 0, M_phi-1 do
			local phi = 2*pi*n/M_phi
			local x = sin(theta)*cos(phi)
			local y = sin(theta)*sin(phi)
			local z = cos(theta)
			table.insert(pts, Vector3.new(x, y, z))
		end
	end
	
	return pts
end

function Utility.GetWorldPointClosestToPart(part, point)
	local isPart = part:IsA("Part")

--	if not isPart or (isPart and part.Shape == Enum.PartType.Block) then
		local oSpace = part.CFrame:pointToObjectSpace(point)
		local x, y, z = oSpace.X, oSpace.Y, oSpace.Z
		local sizeHalf = part.Size/2
		local sX, sY, sZ = sizeHalf.X, sizeHalf.Y, sizeHalf.Z
		local oSpaceClamped = Vector3.new(
			math.clamp(x, -sX, sX),
			math.clamp(y, -sY, sY),
			math.clamp(z, -sZ, sZ)
		)
		
		return part.CFrame:pointToWorldSpace(oSpaceClamped)
--	else
--		local pos = part.Position
--		local rad = part.Size.X/2
--		local dir = (point-pos).unit
--		local dist = (point-pos).magnitude
--		if dist < rad then
--			return point
--		else
--			return pos + dir*rad
--		end
--	end
end

-- https://devforum.roblox.com/t/making-a-camera-transition-to-a-new-spot/119222/4
function Utility.CFrameSlerp(c0, c1, t)
	t = math.clamp(t,0,1)

	-- Lerp position:
	local p = c0.p:Lerp(c1.p, t)
	
	-- Slerp look-vector:
	local omega = math.acos(c0.lookVector:Dot(c1.lookVector))
	local v
	if omega < 0.0001 then
		-- Difference in rotation is negligible:
		v = c0.lookVector
	else
		-- Slerp formula to interpolate uniformly between the two look-vectors:
		v = math.sin((1 - t)*omega)/math.sin(omega)*c0.lookVector + math.sin(t*omega)/math.sin(omega)*c1.lookVector
	end
	
	-- Construct new cframe from these two components:
	return CFrame.new(p, p + v)
	
end

function Utility.Vector3Slerp(v1, v2, alpha)
	if v1 == v2 then return v1 end
	
	local dot = math.clamp(v1:Dot(v2), -1, 1)
	local theta = math.acos(dot)*alpha
	local relativeVec = (v2 - v1*dot).unit
	return v1*math.cos(theta) + relativeVec*math.sin(theta)
end

function Utility.Vector3SlerpClamped(v1, v2, alpha)
	alpha = math.clamp(alpha, 0, 1)
	return Utility.Vector3Slerp(v1, v2, alpha)
end

-- slerps `step` degrees.
function Utility.Vector3SlerpStep(v1, v2, step)
	if v1 == v2 then return v1 end
	
	local dot = math.clamp(v1:Dot(v2), -1, 1)
	local thetaTotal = math.acos(dot)
	local theta = math.min(step, thetaTotal)
	local relativeVec = (v2 - v1*dot).unit
	return v1*math.cos(theta) + relativeVec*math.sin(theta)
end

function Utility.Diagonal(a, ...)
	local sum = a^2
	for _, v in pairs({...}) do
		sum = sum + v^2
	end
	
	return math.sqrt(sum)
end

function Utility.CastRayWithCallbackAndIgnoreList(origin, dir, callback, ignoreList, attemptLimit)
	debug.profilebegin("CastRayWithCallbackAndIgnoreList")
	ignoreList = ignoreList or {}
	attemptLimit = attemptLimit or 20
	
	local goal = origin + dir
	local ignoreList = ignoreList or {}
	for i = 1, attemptLimit do
		local hit, pos, norm = workspace:FindPartOnRayWithIgnoreList(Ray.new(origin, goal-origin), ignoreList)
		
		if hit and callback(hit, pos, norm) then
			debug.profileend()
			return hit, pos, norm, false
		elseif hit == nil then
			return nil, goal, false
		else
			table.insert(ignoreList, hit)
		end
				
		origin = pos - dir*0.00001
	end

	debug.profileend()
	return nil, goal, nil, true
end
	
function Utility.FindPartsInRegion3WithCallbackAndIgnoreList(region, callback, ignoreList)
	ignoreList = ignoreList or {}
	
	local parts = nil
	local foundParts = {}
	repeat
		foundParts = workspace:FindPartsInRegion3WithIgnoreList(region, ignoreList, 100)
		for _, part in pairs(foundParts) do
			table.insert(ignoreList, part)
		end
		local filteredParts = Utility.Filter(
			foundParts, callback
		)
		
		if parts ~= nil then
			for _, part in pairs(filteredParts) do
				table.insert(parts, part)
			end
		else
			parts = filteredParts
		end
	until #foundParts < 100
	
	return parts
end

function Utility.FindPartsInSphereWithIgnoreList(origin, radius, ignoreList)
	local GetWorldPointClosestToPart = Utility.GetWorldPointClosestToPart
	local Filter = Utility.Filter
	
	local region = Region3.new(
		origin - Vector3.new(radius, radius, radius),
		origin + Vector3.new(radius, radius, radius)
	)
	ignoreList = ignoreList or {}
	local newParts = {}
	local finalParts = {}
	local foundParts = 0
	local filterFunc = function(p)
		local p = GetWorldPointClosestToPart(p, origin)
		local dist = (origin-p).magnitude
		return dist <= radius
	end
	repeat		
		newParts = workspace:FindPartsInRegion3WithIgnoreList(region, ignoreList, 100)
		foundParts = #newParts
		for _, part in pairs(newParts) do
			table.insert(ignoreList, part)
		end
		
		local filteredParts = Filter(newParts, filterFunc)
		
		for _, part in pairs(filteredParts) do
			table.insert(finalParts, part)
		end
	until foundParts < 100
	
	return finalParts
end

local VECTOR3_ZERO = Vector3.new()
function Utility.RotateVector(v, x, y)
	if v.Magnitude <= 0 then 
		return Vector3.new()
	end

	local startCFrame = CFrame.new(VECTOR3_ZERO, v)
	local resultCFrame = (CFrame.Angles(0, x, 0) * startCFrame * CFrame.Angles(y,0,0))
	return resultCFrame.lookVector * resultCFrame.magnitude
end

function Utility.TestPointIsInsidePart(part, point)
	local cf = part.CFrame
	local size = part.Size
	local sizeHalf = size/2
	local oSpace = cf:pointToObjectSpace(point)
	local x, y, z = oSpace.X, oSpace.Y, oSpace.Z
	if part.Shape == Enum.PartType.Block then
		if x > -sizeHalf.X and x < sizeHalf.X and
			y > -sizeHalf.Y and y < sizeHalf.Y and
			z > -sizeHalf.Z and z < sizeHalf.Z then
			return true
		else
			return false			
		end
	else
		return false
	end
end

function Utility.WeldInPlace(p0, p1)
	local weld = Instance.new("Weld")
	weld.Part0 = p0
	weld.Part1 = p1
	weld.C0 = p0.CFrame:inverse()
	weld.C1 = p1.CFrame:inverse()
	weld.Parent = p0
	
	return weld
end

function Utility.GetDigit(n, d)
	return math.floor((n%(10^(d+1))) / (10^d))
end

function Utility.HashColor(color)
	local r, g, b  = Utility.Round(color.r*255), Utility.Round(color.g*255), Utility.Round(color.b*255)
	return string.char(r) .. string.char(g) .. string.char(b)
end

function Utility.RandomCoordsInCircle(radius, seed)
	local r
	if seed then
		r = Random.new(seed)
	else
		r = Random.new()
	end
	
	local x, y = r:NextNumber(-radius, radius), r:NextNumber(-radius, radius)
	while Utility.Diagonal(x, y) > radius do
		x, y = r:NextNumber(-radius, radius), r:NextNumber(-radius, radius)
	end
	
	return x, y
end

function Utility.RandomCoordsInSphere(radius, seed)
	local r
	if seed then
		r = Random.new(seed)
	else
		r = Random.new()
	end
	
	local x, y, z = r:NextNumber(-radius, radius), r:NextNumber(-radius, radius), r:NextNumber(-radius, radius)
	while Utility.Diagonal(x, y, z) > radius do
		x, y, z = r:NextNumber(-radius, radius), r:NextNumber(-radius, radius), r:NextNumber(-radius, radius)
	end
	
	return x, y, z
end

function Utility.RandomUnitVector3(seed)
	local v = Vector3.new(Utility.RandomCoordsInSphere(1, seed))
	while v.magnitude < 0.001 do
		v = Vector3.new(Utility.RandomCoordsInSphere(1, seed))
	end
	
	return v.unit
end

function Utility.SphereVolume(radius)
	return 4/3*math.pi*radius^3
end

function Utility.EllipsoidVolume(a, b, c)
	return 4/3*math.pi*a*b*c
end

function Utility.SphereRadiusFromVolume(volume)
	return ((3*volume)/(4*math.pi))^(1/3)
end

function radius(k,n,b)
	if k>n-b then
		return 1
	else
		return math.sqrt(k-1/2)/math.sqrt(n-(b+1)/2)
	end
end

local Round = Utility.Round
function Utility.DistributePointsSunflower(n, alpha, rad, rotOffset)
	rad = rad or 1
	alpha = alpha or 0
	rotOffset = rotOffset or 0
	local pts = {}
	local b = Round(alpha*math.sqrt(n))
	local phi = (math.sqrt(5)+1)/2
	for k = 1, n do
		local r = radius(k,n,b);
		local theta = 2*math.pi*k/phi^2 + rotOffset;
		local x = r*math.cos(theta)
		local y = r*math.sin(theta)
		pts[k] = Vector2.new(x, y) * rad
	end

	return pts
end

-- http://geomalgorithms.com/a02-_lines.html
function Utility.GetPointClosestToLineSegment(p, p0, p1)
	local v = p1 - p0
	local w = p - p0
	
	local c1 = w:Dot(v)
	if c1 <= 0 then
		return p0, (p - p0).magnitude
	end
	
	local c2 = v:Dot(v)
	if c2 <= c1 then
		return p1, (p - p1).magnitude
	end

	local b = c1 / c2
	local pb = p0 + b*v
	return pb, (p-pb).magnitude
end

function Utility.GetLerpFactor(v, a, b)
	local delta = b - a
	return (v - a)/delta
end

local coreCall do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService('StarterGui')
	local RunService = game:GetService('RunService')

	function Utility.CoreCall(method, ...)
		local result = {}
		local timeout = 5
		while timeout > 0 do
			print(method, ...)
			result = {pcall(StarterGui[method], StarterGui, ...)}
			if result[1] then
				break
			end
			local _, dt = RunService.Stepped:Wait()
			timeout = timeout - dt
		end
		return unpack(result)
	end
end

function Utility.DeepCompareTables(t1, t2, ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
	local v2 = t2[k1]
	if v2 == nil or not Utility.DeepCompareTables(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
	local v1 = t1[k2]
	if v1 == nil or not Utility.DeepCompareTables(v1,v2) then return false end
	end
	return true
end

function Utility.FuzzyEquals(a, b, tolerance)
	tolerance = tolerance or 0.001
	return math.abs(a - b) <= tolerance
end

function Utility.GetTextSize(...)
	return game:GetService("TextService"):GetTextSize(...)
end

function Utility.GetModelAABB(model)
	local abs = math.abs
	local inf = math.huge
	
	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = -inf, -inf, -inf

	for _,obj in pairs(model:GetDescendants()) do -- model:GetDescendants has to marshal an array of instances to Lua which is pretty expensive but there's no way around it
		if obj:IsA("BasePart") then -- this uses Roblox __namecall optimization - no point caching IsA, it's fast enough (although does involve LuaBridge invocation)
			local cf = obj.CFrame -- this causes a LuaBridge invocation + heap allocation to create CFrame object - expensive! - but no way around it. we need the cframe
			local size = obj.Size -- this causes a LuaBridge invocation + heap allocation to create Vector3 object - expensive! - but no way around it
			local sx, sy, sz = size.X, size.Y, size.Z -- this causes 3 Lua->C++ invocations

			local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() -- this causes 1 Lua->C++ invocations and gets all components of cframe in one go, with no allocations

			-- https://zeuxcg.org/2010/10/17/aabb-from-obb-with-component-wise-abs/
			local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz) -- this requires 3 Lua->C++ invocations to call abs, but no hash lookups since we cached abs value above; otherwise this is just a bunch of local ops
			local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz) -- same
			local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz) -- same
			
			-- just a bunch of local ops
			if minx > x - wsx then minx = x - wsx end
			if miny > y - wsy then miny = y - wsy end
			if minz > z - wsz then minz = z - wsz end		   

			if maxx < x + wsx then maxx = x + wsx end
			if maxy < y + wsy then maxy = y + wsy end
			if maxz < z + wsz then maxz = z + wsz end		   
		end
	end 
   
	return Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
end

function Utility.GetPartAABB(obj)
	local abs = math.abs

	local cf = obj.CFrame -- this causes a LuaBridge invocation + heap allocation to create CFrame object - expensive! - but no way around it. we need the cframe
	local size = obj.Size -- this causes a LuaBridge invocation + heap allocation to create Vector3 object - expensive! - but no way around it
	local sx, sy, sz = size.X, size.Y, size.Z -- this causes 3 Lua->C++ invocations

	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() -- this causes 1 Lua->C++ invocations and gets all components of cframe in one go, with no allocations

	-- https://zeuxcg.org/2010/10/17/aabb-from-obb-with-component-wise-abs/
	local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz) -- this requires 3 Lua->C++ invocations to call abs, but no hash lookups since we cached abs value above; otherwise this is just a bunch of local ops
	local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz) -- same
	local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz) -- same
	
	-- just a bunch of local ops
	local minx = x - wsx
	local miny = y - wsy
	local minz = z - wsz

	local maxx = x + wsx
	local maxy = y + wsy
	local maxz = z + wsz
   
	local minv, maxv = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return minv, maxv
end

function Utility.GetModelAABBFast(model)
	local originalPrimaryPart = model.PrimaryPart
	local fakeCenter = Instance.new("Part")
	fakeCenter.Size = Vector3.new(0, 0, 0)
	local center, extents
	if originalPrimaryPart then
		fakeCenter.CFrame = CFrame.new(originalPrimaryPart.Position)
		fakeCenter.Parent = model
		model.PrimaryPart = fakeCenter
		center = model:GetModelCFrame().p
		extents = model:GetExtentsSize()
		model.PrimaryPart = originalPrimaryPart
	else
		local calcCenter = model:GetModelCFrame()
		fakeCenter.CFrame = CFrame.new(calcCenter.p)
		fakeCenter.Parent = model
		model.PrimaryPart = fakeCenter
		center = model:GetModelCFrame().p
		extents = model:GetExtentsSize()
		model.PrimaryPart = nil
	end
	
	fakeCenter:Destroy()
	local min, max = center-extents/2, center+extents/2
	
	return min, max
end

-- https://gist.github.com/andybons/3737860
-- Modified by XAXA for utf8 compatibility.
-- Returns the Levenshtein distance between the two given strings
function Utility.UTF8Levenshtein(str1, str2)
	local len1 = utf8.len(str1)
	local len2 = utf8.len(str2)
	local matrix = {}
	local cost = 0
	
	-- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end
	
	-- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end
		
	-- actual Levenshtein algorithm
	local i = 0
	local j = 0
	for _, code1 in utf8.codes(str1) do
		i = i+1
		j = 0
		for _, code2 in utf8.codes(str2) do
			j = j+1
			if code1 == code2 then
				cost = 0
			else
				cost = 1
			end
			
			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end
	
	-- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end

return Utility
