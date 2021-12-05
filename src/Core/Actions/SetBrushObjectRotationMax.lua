local Action = require(script.Parent.Action)

return Action("BrushObjectRotationSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)