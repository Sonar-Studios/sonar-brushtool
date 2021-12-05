local Action = require(script.Parent.Action)

return Action("BrushRadiusSet", function(radius)
	return {
		radius = radius
	}
end)