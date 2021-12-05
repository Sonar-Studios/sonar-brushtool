local Action = require(script.Parent.Action)

return Action("BrushObjectWobbleSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)