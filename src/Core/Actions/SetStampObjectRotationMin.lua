local Action = require(script.Parent.Action)

return Action("StampObjectRotationSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)