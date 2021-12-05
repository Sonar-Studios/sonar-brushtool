local Action = require(script.Parent.Action)

return Action("StampObjectRotationSet", function(guid, fixed)
	return {
		guid = guid,
		fixed = fixed
	}
end)