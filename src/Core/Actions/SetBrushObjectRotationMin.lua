local Action = require(script.Parent.Action)

return Action("BrushObjectRotationSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)