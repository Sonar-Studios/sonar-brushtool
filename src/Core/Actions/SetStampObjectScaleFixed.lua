local Action = require(script.Parent.Action)

return Action("StampObjectScaleSet", function(guid, fixed)
	return {
		guid = guid,
		fixed = fixed
	}
end)