local Action = require(script.Parent.Action)

return Action("BrushFilterSet", function(filter)
	return {
		filter = filter
	}
end)