local Action = require(script.Parent.Action)

return Action("BrushObjectRotationSet", function(guid, fixed)
	return {
		guid = guid,
		fixed = fixed
	}
end)