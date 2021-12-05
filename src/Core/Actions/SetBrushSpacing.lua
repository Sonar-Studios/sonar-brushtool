local Action = require(script.Parent.Action)

return Action("BrushSpacingSet", function(spacing)
	return {
		spacing = spacing
	}
end)