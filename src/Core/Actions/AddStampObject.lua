local HttpService = game:GetService("HttpService")

local Action = require(script.Parent.Action)

return Action("StampObjectNew", function(rbxObject, guid)
	if not guid then
		guid = HttpService:GenerateGUID()
	end
	assert(rbxObject.Archivable)
	
	return {
		guid = guid,
		rbxObject = rbxObject:Clone()
	}
end)