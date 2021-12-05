local Action = require(script.Parent.Action)

return Action("BrushOrientationSet", function(mode)
	return {
		mode = mode
	}
end)