local Action = require(script.Parent.Action)

return Action("BrushRotationSet", function(max)
	return {
		max = max
	}
end)