local Action = require(script.Parent.Action)

return Action("StampObjectWobbleSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)