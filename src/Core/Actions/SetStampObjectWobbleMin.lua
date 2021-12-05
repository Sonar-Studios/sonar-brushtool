local Action = require(script.Parent.Action)

return Action("StampObjectWobbleSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)