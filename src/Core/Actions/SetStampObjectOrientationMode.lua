local Action = require(script.Parent.Action)

return Action("StampObjectOrientationSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)