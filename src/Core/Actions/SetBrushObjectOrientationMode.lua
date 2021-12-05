local Action = require(script.Parent.Action)

return Action("BrushObjectOrientationSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)