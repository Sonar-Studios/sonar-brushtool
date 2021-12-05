local Action = require(script.Parent.Action)

return Action("StampObjectWobbleSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)