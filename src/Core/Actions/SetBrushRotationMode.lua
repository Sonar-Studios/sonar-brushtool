local Action = require(script.Parent.Action)

return Action("BrushRotationSet", function(mode)
	return {
		mode = mode
	}
end)