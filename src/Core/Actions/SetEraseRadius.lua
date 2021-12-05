local Action = require(script.Parent.Action)

return Action("EraseRadiusSet", function(radius)
	return {
		radius = radius
	}
end)