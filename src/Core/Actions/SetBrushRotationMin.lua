local Action = require(script.Parent.Action)

return Action("BrushRotationSet", function(min)
	return {
		min = min
	}
end)