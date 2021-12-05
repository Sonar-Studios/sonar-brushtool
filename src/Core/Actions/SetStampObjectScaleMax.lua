local Action = require(script.Parent.Action)

return Action("StampObjectScaleSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)