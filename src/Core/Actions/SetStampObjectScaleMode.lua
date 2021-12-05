local Action = require(script.Parent.Action)

return Action("StampObjectScaleSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)