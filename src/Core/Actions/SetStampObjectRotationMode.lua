local Action = require(script.Parent.Action)

return Action("StampObjectRotationSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)