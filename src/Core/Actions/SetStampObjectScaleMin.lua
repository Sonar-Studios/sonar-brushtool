local Action = require(script.Parent.Action)

return Action("StampObjectScaleSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)