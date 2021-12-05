local Action = require(script.Parent.Action)

return Action("BrushObjectWobbleSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)