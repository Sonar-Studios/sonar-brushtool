local Action = require(script.Parent.Action)

return Action("StampObjectRotationSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)